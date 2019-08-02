function SingleRunResult = reconstruct(Params, Links)
import com.comsol.model.*
import com.comsol.model.util.*
eps = 1e-10;
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid] = Links{1:end};
BaseParams = Params{2};
DefectParams = Params{1};
[DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC] = DefectParams{1:end};

for i = 1:size(DefectParams,2)
    model.param.set(DefectParams{i}.name,[num2str(DefectParams{i}.value) DefectParams{i}.unit], ...
        DefectParams{i}.comment);
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
[BaseParams, Basenames] = unitcellgeom(wp1, DefectParams);
Positions = zeros(1, NumofUC.value*2);
for i = 1:NumofUC.value
    Positions(i) = (i-0.5-NumofUC.value)*BaseParams{1}.value-0.5*DL.value;
    Positions(NumofUC.value+i) = (i-0.5)*BaseParams{1}.value+0.5*DL.value;
end
[AllUCParams, AllUCnames, coords] = UCarrayfromsingle(wp1, Basenames, BaseParams, Positions, Links, DefectParams);
for i = 1:size(Basenames,2)
    wp1.geom.feature(Basenames(i)).active(false);
end

ls1 = wp1.geom.create('ls1','LineSegment');
ls1.set('specify1', 'coord');
ls1.set('specify2', 'coord');
ls1.set('coord1', coords{5});
ls1.set('coord2', [0,0]);

ls2 = wp1.geom.create('ls2','LineSegment');
ls2.set('specify1', 'coord');
ls2.set('specify2', 'coord');
ls2.set('coord1', [0,0]);
ls2.set('coord2', coords{6});


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
Uni.selection('input').set({'Uni_small', 'ls1', 'ls2'});

%extrude
ext1.set('workplane', 'wp1');
ext1.selection('input').set({'wp1.Uni'});
ext1.set('distance', {'DH'});
geom1.run;

%prestress condiciton
iss1.set('Sil', {'1e9' '0' '0' '0' '1e9' '0' '0' '0' '0'});

%study node
eig.set('neigs', 50);

%extra control for obtaining localmode through symmetry
difblock = geom1.create('difblock','Block');
difblock.set('size',[coords{6}(1)-coords{5}(1) DW.value*10 DH.value]);
difblock.set('pos',[0 DW.value*5 DH.value/2]);
difblock.set('base','center');
dif1 = geom1.create('dif1', 'Difference');
dif1.selection('input').set({'ext1'});
dif1.selection('input2').set({'difblock'});
geom1.run;
sym1 = solid.create('sym1','SymmetrySolid',2);
symmetryface = mphselectbox(model,'geom1',[coords{5}(1)-eps,coords{6}(1)+eps;-eps,eps;-eps,DH.value+eps],'boundary');
sym1.selection.set(symmetryface);
idx_bnd1 = mphselectbox(model,'geom1', coords{1}, 'boundary');
idx_bnd2 = mphselectbox(model,'geom1', coords{2}, 'boundary');
idx_ftri = mphselectbox(model,'geom1', coords{3}, 'boundary');
idx_sweldestiface = mphselectbox(model,'geom1', coords{4}, 'boundary');
fix1.selection.set([idx_bnd1 idx_bnd2]);
Msize.set('hmax', 'MS');
Msize.set('hmin', 'MS/4');
Msize.set('hcurve', '0.2');
ftri.selection.set(idx_ftri);
ref1 = mesh.create('ref1','Refine');
ref1.set('rmethod', 'regular');
ref1.set('numrefine', 5);
ref1.selection.geom('geom1', 2);
ref1.selection.set([idx_bnd1 idx_bnd2]);
swel.selection('sourceface').set(idx_ftri);
swel.selection('targetface').set(idx_sweldestiface);
mesh.run;
std.run;
[localmodefreq, localmodeEffMass] = Localmode(Links,coords);

%{
...

The following code do the calculation without symmetrizing the geom

geom1.feature.remove('difblock');
geom1.feature.remove('dif1');
solid.feature.remove('sym1');
geom1.run;

%get indicies
idx_bnd1 = mphselectbox(model,'geom1', coords{1}, 'boundary');
idx_bnd2 = mphselectbox(model,'geom1', coords{2}, 'boundary');
idx_ftri = mphselectbox(model,'geom1', coords{3}, 'boundary');
idx_sweldestiface = mphselectbox(model,'geom1', coords{4}, 'boundary');
%physics interface
fix1.selection.set([idx_bnd1 idx_bnd2]);

%meshing
Msize.set('hmax', 'MS');
Msize.set('hmin', 'MS/4');
Msize.set('hcurve', '0.2');
ftri.selection.set(idx_ftri);
swel.selection('sourceface').set(idx_ftri);
swel.selection('targetface').set(idx_sweldestiface);
mesh.run;
eig.set('neigs', 100);
eig.set('shift',[num2str(localmodefreq) '[Hz]']);
tic;
std.run;
toc;
...
...
%}

%export data
Eigenfreq = mphglobal(model,'solid.freq');
plotgraph = figure;
plot(real(Eigenfreq),'*');
c=clock;
saveas(plotgraph,['snapshot\test', num2str(c(4)), num2str(c(5)), num2str(round(c(6))), '.png']);
close(plotgraph);
SingleRunResult = evaluategeom(Links,localmodefreq, localmodeEffMass);

end