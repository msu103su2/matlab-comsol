function SingleRunResult = realconstruct(Params, Links, cutoffLength)
import com.comsol.model.*
import com.comsol.model.util.*
eps = 1e-10;
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref] = Links{1:end};
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
[BaseParams, Basenames] = unitcellgeom(wp1, DefectParams, BaseParams);
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
iss1.set('Sil', {'1.173779132614756e9' '0' '0' '0' '1.173779132614756e9' '0' '0' '0' '0'});

%study node
eig.set('neigs', 50);

%extra control for obtaining localmode through symmetry
temp = zeros(1,size(AllUCParams,2));
for i = 1:size(AllUCParams,2)
    temp(i) = AllUCParams{i}{8}.value;
maxWidth = max(temp);
interblock = geom1.create('interblock','Block');
interblock.set('size',[cutoffLength maxWidth+200*eps DH.value]);
interblock.set('pos',[0 0 DH.value/2]);
interblock.set('base','center');
inter1 = geom1.create('inter1', 'Intersection');
inter1.selection('input').set({'ext1','interblock'});
geom1.run;

coords{1}(1,:) = coords{1}(1,:) - ((coords{1}(1,1)+coords{1}(1,2))/2 + cutoffLength/2);
coords{1}(2,1) = -(maxWidth/2+eps); coords{1}(2,2) = maxWidth/2+eps;
coords{2}(1,:) = coords{2}(1,:) - ((coords{2}(1,1)+coords{2}(1,2))/2 - cutoffLength/2);
coords{2}(2,1) = -(maxWidth/2+eps); coords{2}(2,2) = maxWidth/2+eps;

idx_bnd1 = mphselectbox(model,'geom1', coords{1}, 'boundary');
idx_bnd2 = mphselectbox(model,'geom1', coords{2}, 'boundary');
idx_ftri = mphselectbox(model,'geom1', coords{3}, 'boundary');
idx_sweldestiface = mphselectbox(model,'geom1', coords{4}, 'boundary');
fix1.selection.set([idx_bnd1 idx_bnd2]);
Msize.set('hmax', 'MS');
Msize.set('hmin', 'MS/4');
Msize.set('hcurve', '0.2');
ftri.selection.set(idx_ftri);

ref{1}.set('rmethod', 'regular');
ref{1}.set('numrefine', 3);
ref{1}.set('boxcoord', true);
ref{1}.set('xmax', coords{1}(1,1)+MS.value);
ref{1}.set('xmin', coords{1}(1,1));
ref{1}.set('ymax', coords{1}(2,2));
ref{1}.set('ymin', coords{1}(2,1));
ref{1}.set('zmax', coords{1}(3,2));
ref{1}.set('zmin', coords{1}(3,1));
ref{1}.selection.geom('geom1', 2);
ref{1}.selection.set(idx_ftri);

ref{2}.set('rmethod', 'regular');
ref{2}.set('numrefine', 1);
ref{2}.set('boxcoord', true);
ref{2}.set('xmax', coords{1}(1,1)+MS.value/3);
ref{2}.set('xmin', coords{1}(1,1));
ref{2}.set('ymax', coords{1}(2,2));
ref{2}.set('ymin', coords{1}(2,1));
ref{2}.set('zmax', coords{1}(3,2));
ref{2}.set('zmin', coords{1}(3,1));
ref{2}.selection.geom('geom1', 2);
ref{2}.selection.set(idx_ftri);

ref{3}.set('rmethod', 'regular');
ref{3}.set('numrefine', 3);
ref{3}.set('boxcoord', true);
ref{3}.set('xmax', coords{2}(1,2));
ref{3}.set('xmin', coords{2}(1,2)-MS.value);
ref{3}.set('ymax', coords{2}(2,2));
ref{3}.set('ymin', coords{2}(2,1));
ref{3}.set('zmax', coords{2}(3,2));
ref{3}.set('zmin', coords{2}(3,1));
ref{3}.selection.geom('geom1', 2);
ref{3}.selection.set(idx_ftri);

ref{4}.set('rmethod', 'regular');
ref{4}.set('numrefine', 1);
ref{4}.set('boxcoord', true);
ref{4}.set('xmax', coords{2}(1,2));
ref{4}.set('xmin', coords{2}(1,2)-MS.value/3);
ref{4}.set('ymax', coords{2}(2,2));
ref{4}.set('ymin', coords{2}(2,1));
ref{4}.set('zmax', coords{2}(3,2));
ref{4}.set('zmin', coords{2}(3,1));
ref{4}.selection.geom('geom1', 2);
ref{4}.selection.set(idx_ftri);

swel.selection('sourceface').set(idx_ftri);
swel.selection('targetface').set(idx_sweldestiface);
swel.create('dis1', 'Distribution');
swel.feature('dis1').set('numelem', 4);
mesh.run;
std.run;
[localmodefreq, localmodeEffMass] = Localmode_center_tilt(Links,coords);
%{
...

The following code do the calculation without symmetrizing the geom
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
SingleRunResult = evaluategeom(Links,Params,localmodefreq, localmodeEffMass);
SingleRunResult.EffMass = localmodeEffMass;
SingleRunResult.Eigenfreq = Eigenfreq;
geom1.feature.remove('interblock');
geom1.feature.remove('inter1');
swel.feature.remove('dis1');
end