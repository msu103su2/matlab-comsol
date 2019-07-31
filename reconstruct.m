function SingleRunResult = reconstruct(Params, Links)
import com.comsol.model.*
import com.comsol.model.util.*
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig] = Links{1:end};
BaseParams = Params{2};
Params = Params{1};
[DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC] = Params{1:end};

for i = 1:size(Params,2)
    model.param.set(Params{i}.name,[num2str(Params{i}.value) Params{i}.unit], ...
        Params{i}.comment);
end

geom1.feature.remove('wp1');
wp1 = geom1.feature.create('wp1', 'WorkPlane');
geom1.feature.move('wp1',0);
wp1.set('quickplane', 'xy');
defect = wp1.geom.feature.create('defect', 'Rectangle');
defect.set('size', [DL.value DW.value]);
defect.set('base', 'center');
defect.set('pos', [Dx.value Dy.value]);

%deal with the geomtry array
[BaseParams, Basenames] = unitcellgeom(wp1);
Positions = zeros(1, NumofUC.value*2);
for i = 1:NumofUC.value
    Positions(i) = (i-0.5-NumofUC.value)*BaseParams{1}.value-0.5*DL.value;
    Positions(NumofUC.value+i) = (i-0.5)*BaseParams{1}.value+0.5*DL.value;
end
[AllUCParams, AllUCnames, coords] = UCarrayfromsingle(wp1, Basenames, BaseParams, Positions, Links);
for i = 1:size(Basenames,2)
    wp1.geom.feature(Basenames(i)).active(false);
end

ls1 = wp1.geom.create('ls1','LineSegment');
ls1.set('specify1', 'coord');
ls1.set('specify2', 'coord');
ls1.set('coord1', coords{5});
ls1.set('coord2', coords{6});

%create union
Uni_small = wp1.geom.feature.create('Uni_small', 'Union');
for i = 1:size(AllUCnames,2)
    temp{i} = AllUCnames{i}{end};
end
temp{size(AllUCnames,2)+1} = 'defect';
Uni_small.selection('input').set(temp);
Uni_small.set('intbnd', false);
Uni = wp1.geom.feature.create('Uni', 'Union');
Uni.set('intbnd', true);
Uni.selection('input').set({'Uni_small', 'ls1'});
%extrude
ext1.set('workplane', 'wp1');
ext1.selection('input').set({'wp1.Uni'});
ext1.set('distance', {'DH'});
geom1.run;

%get indicies
idx_bnd1 = mphselectbox(model,'geom1', coords{1}, 'boundary');
idx_bnd2 = mphselectbox(model,'geom1', coords{2}, 'boundary');
idx_ftri = mphselectbox(model,'geom1', coords{3}, 'boundary');
idx_sweldestiface = mphselectbox(model,'geom1', coords{4}, 'boundary');
%physics interface
fix1.selection.set([idx_bnd1 idx_bnd2]);

%fetching the entities

%meshing
Msize.set('hmax', 'MS');
Msize.set('hmin', 'MS/4');
Msize.set('hcurve', '0.2');
ftri.selection.set(idx_ftri);
swel.selection('sourceface').set(idx_ftri);
swel.selection('targetface').set(idx_sweldestiface);
mesh.run;

%prestress condiciton
iss1.set('Sil', {'1e9' '0' '0' '0' '1e9' '0' '0' '0' '0'});

%study node
eig.set('neigs', 100);

tic;
std.run;
toc;

%export data
Eigenfreq = mphglobal(model, 'solid.freq');
Eigenfreq = Eigenfreq(Eigenfreq == real(Eigenfreq));
plotgraph = figure;
plot(Eigenfreq,'*');
c=clock;
saveas(plotgraph,['snapshot\test', num2str(c(4)), num2str(c(5)), num2str(round(c(6))), '.png']);
close(plotgraph);
%in Eigenfreq find the local mode
SingleRunResult = Localmode(Eigenfreq);

end