function SingleRunResult = reconstruct(Params, Links)
import com.comsol.model.*
import com.comsol.model.util.*
[model, geom1, wp1, Uni, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, defect, LeftUCs, RightUCs] = Links{1:end};
[DL, DW, DH, Dx, Dy, Dz, UL, UW, UH, Ux, Uy, Uz, kx, MS, NumofUC, ucindex] = Params{1:end};
Params = [DL, DW, DH, Dx, Dy, Dz, UL, UW, UH, Ux, Uy, Uz, kx, MS, NumofUC, ucindex];
BaseParams = [ucindex UL, UW, UH, Ux, Uy, Uz];
RightArrayParams = repmat(BaseParams, NumofUC.value, 1);
LeftArrayParams = repmat(BaseParams, NumofUC.value, 1);

for i = 1:size(Params,2)
    model.param.set(Params(i).name,[num2str(Params(i).value) Params(i).unit], ...
        Params(i).comment);
end

defect.set('size', [DL.value DW.value]);%defect.set('size', {Params(1).name Params(2).name});
defect.set('pos', [Dx.value Dy.value]);%defect.set('pos', {Params(4).name Params(5).name});

LeftArrayParams(1,5).value = -LeftArrayParams(1,5).value;
for i = 1 : NumofUC.value
    if i>1
    RightArrayParams(i,:) = UCP_byIndex(i, RightArrayParams, 1);
    LeftArrayParams(i,:) = UCP_byIndex(i, LeftArrayParams, -1);
    end
end

for i = 1 : NumofUC.value
    SetElement(i, RightArrayParams, RightUCs);
    SetElement(i, LeftArrayParams, LeftUCs);
end

%create union
strofobj{NumofUC.value*2+1} = 'defect';
for i = 1 : NumofUC.value
    strofobj{2*i-1} = ['RightUC_' num2str(i)];
    strofobj{2*i} = ['LeftUC_' num2str(i)];
end
Uni.selection('input').set(strofobj);

%extrude
ext1.set('distance', {'DH'});
geom1.run;

%physics interface
fix1.selection.set([1 72]);

%fetching the entities

%meshing
Msize.set('hmax', 'MS');
Msize.set('hmin', 'MS/4');
Msize.set('hcurve', '0.2');
ftri.selection.set([4 10 17 24 31 37 42 47 54 61 68]);
swel.selection('sourceface').set([4 10 17 24 31 37 42 47 54 61 68]);
swel.selection('targetface').set([3 9 16 23 30 36 41 46 53 60 67]);
mesh.run;

%prestress condiciton
iss1.set('Sil', {'1e9' '0' '0' '0' '1e9' '0' '0' '0' '0'});

%study node
eig.set('neigs', 50);

std.run;

%export data
Eigenfreq = mphglobal(model, 'solid.freq');

%in Eigenfreq find the local mode
SingleRunResult = Localmode(Eigenfreq);

end