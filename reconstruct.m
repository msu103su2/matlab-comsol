function SingleRunResult = reconstruct(params, links)
import com.comsol.model.*
import com.comsol.model.util.*
eps = 1e-10;

% reset defect params and others
model.param.set('DL',[num2str(params.defect.length) '[m]']);
model.param.set('DW',[num2str(params.defect.width) '[m]']);
model.param.set('DH',[num2str(params.defect.height) '[m]']);
model.param.set('Dx',[num2str(params.defect.x) '[m]']);
model.param.set('Dy',[num2str(params.defect.y) '[m]']);
model.param.set('Dz',[num2str(params.defect.z) '[m]']);
model.param.set('MS',[num2str(params.MS) '[m]']);
model.param.set('NumofUC',[num2str(params.NumofUC) '[1]']);

%recreate workplane, recreate defect
links.geom1.feature.remove('wp1');
links.wp1 = geom1.feature.create('wp1', 'WorkPlane');
links.geom1.feature.move('wp1',0);
links.wp1.set('quickplane', 'xy');
unitcellgeom(links.wp1, defect);

%deal with the geomtry array
for i = 1 : 2*params.NumofUC
    unitcellgeom(links.wp1, defect);
end

leftEndCoord = [params.UCs(2*params.NumofUC).x - ...
    params.UCs(2*params.NumofUC).length/2 0];
rightEndCoord = [params.UCs(2*params.NumofUC-1).x + ...
    params.UCs(2*params.NumofUC-1).length/2 0];

ls1 = links.wp1.geom.create('ls1','LineSegment');
ls1.set('specify1', 'coord');
ls1.set('specify2', 'coord');
ls1.set('coord1', leftEndCoord);
ls1.set('coord2', [0,0]);

ls2 = links.wp1.geom.create('ls2','LineSegment');
ls2.set('specify1', 'coord');
ls2.set('specify2', 'coord');
ls2.set('coord1', [0,0]);
ls2.set('coord2', rightEndCoord);

%count how many extrusions are needed

%extrude
%it seems from comsol, for 2D object on wp1, there only being 1 face with
%indice 1
links.ext1.set('workplane', 'wp1');
links.ext1.set('distance', params.defect.B.height);
links.geom1.run;

%prestress condiciton
links.iss1.set('Sil', {'1e9' '0' '0' '0' '1e9' '0' '0' '0' '0'});

%study node
links.eig.set('neigs', 50);

%extra control for obtaining localmode through symmetry
difblock = links.geom1.create('difblock','Block');
difblock.set('size',[rightEndCoord(1)-leftEndCoord(1) ...
    params.defect.B.width*10 params.defect.B.height]);
difblock.set('pos',[0 params.defect.B.width*5 params.defect.B.height/2]);
difblock.set('base','center');
dif1 = links.geom1.create('dif1', 'Difference');
dif1.selection('input').set({'ext1'});
dif1.selection('input2').set({'difblock'});
geom1.run;
sym1 = links.solid.create('sym1','SymmetrySolid',2);
symmetryface = mphselectbox(links.model,'geom1',[leftEndCoord(1)-eps,...
    rightEndCoord(1)+eps;-eps,eps;-eps,params.defect.B.height+eps],'boundary');
sym1.selection.set(symmetryface);


bnd1box = [leftEndCoord(1)-eps, leftEndCoord(1)+eps;...
    -params.defect.B.width*5, params.defect.B.width*5;...
    -eps, params.defect.B.height*5];
bnd2box = [rightEndCoord(1)-eps, rightEndCoord(1)+eps;...
    -params.defect.B.width*5, params.defect.B.width*5;...
    -eps, params.defect.B.height*5];
ftribox = [leftEndCoord(1)-eps, rightEndCoord(1)+eps;...
    -params.defect.B.width*5, params.defect.B.width*5;...
    params.defect.B.height-eps, params.defect.B.height+eps];
sweldestibox = [leftEndCoord(1)-eps, rightEndCoord(1)+eps;...
    -params.defect.B.width*5, params.defect.B.width*5;...
    -eps, eps];
idx_bnd1 = mphselectbox(links.model,'geom1', bnd1box, 'boundary');
idx_bnd2 = mphselectbox(links.model,'geom1', bnd2box, 'boundary');
idx_ftri = mphselectbox(links.model,'geom1', ftribox, 'boundary');
idx_sweldestiface = mphselectbox(model,'geom1', sweldestibox, 'boundary');
links.fix1.selection.set([idx_bnd1 idx_bnd2]);
links.Msize.set('hmax', 'MS');
links.Msize.set('hmin', 'MS/4');
links.Msize.set('hcurve', '0.2');
links.ftri.selection.set(idx_ftri);

links.ref{1}.set('rmethod', 'regular');
links.ref{1}.set('numrefine', 3);
links.ref{1}.set('boxcoord', true);
links.ref{1}.set('xmax', bnd1box(1,1)+params.MS);
links.ref{1}.set('xmin', bnd1box(1,1));
links.ref{1}.set('ymax', bnd1box(2,2));
links.ref{1}.set('ymin', bnd1box(2,1));
links.ref{1}.set('zmax', bnd1box(3,2));
links.ref{1}.set('zmin', bnd1box(3,1));
links.ref{1}.selection.geom('geom1', 2);
links.ref{1}.selection.set(idx_ftri);

links.ref{2}.set('rmethod', 'regular');
links.ref{2}.set('numrefine', 1);
links.ref{2}.set('boxcoord', true);
links.ref{2}.set('xmax', bnd1box(1,1)+params.MS/3);
links.ref{2}.set('xmin', bnd1box(1,1));
links.ref{2}.set('ymax', bnd1box(2,2));
links.ref{2}.set('ymin', bnd1box(2,1));
links.ref{2}.set('zmax', bnd1box(3,2));
links.ref{2}.set('zmin', bnd1box(3,1));
links.ref{2}.selection.geom('geom1', 2);
links.ref{2}.selection.set(idx_ftri);

links.ref{3}.set('rmethod', 'regular');
links.ref{3}.set('numrefine', 3);
links.ref{3}.set('boxcoord', true);
links.ref{3}.set('xmax', bnd2box(1,2));
links.ref{3}.set('xmin', bnd2box(1,2)-params.MS);
links.ref{3}.set('ymax', bnd2box(2,2));
links.ref{3}.set('ymin', bnd2box(2,1));
links.ref{3}.set('zmax', bnd2box(3,2));
links.ref{3}.set('zmin', bnd2box(3,1));
links.ref{3}.selection.geom('geom1', 2);
links.ref{3}.selection.set(idx_ftri);

links.ref{4}.set('rmethod', 'regular');
links.ref{4}.set('numrefine', 1);
links.ref{4}.set('boxcoord', true);
links.ref{4}.set('xmax', bnd2box(1,2));
links.ref{4}.set('xmin', bnd2box(1,2)-params.MS/3);
links.ref{4}.set('ymax', bnd2box(2,2));
links.ref{4}.set('ymin', bnd2box(2,1));
links.ref{4}.set('zmax', bnd2box(3,2));
links.ref{4}.set('zmin', bnd2box(3,1));
links.ref{4}.selection.geom('geom1', 2);
links.ref{4}.selection.set(idx_ftri);

links.swel.selection('sourceface').set(idx_ftri);
links.swel.selection('targetface').set(idx_sweldestiface);
links.swel.create('dis1', 'Distribution');
links.swel.feature('dis1').set('numelem', 4);
links.mesh.run;
links.std.run;
[localmodefreq, localmodeEffMass] = Localmode_center_tilt(links,leftEndCoord,rightEndCoord,params);
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
Eigenfreq = mphglobal(links.model,'solid.freq');
SingleRunResult = evaluategeom(links.links,params,localmodefreq,localmodeEffMass,leftEndCoord, rightEndCoord);
SingleRunResult.EffMass = localmodeEffMass;
SingleRunResult.Eigenfreq = Eigenfreq;
links.geom1.feature.remove('difblock');
links.geom1.feature.remove('dif1');
links.solid.feature.remove('sym1');
links.swel.feature.remove('dis1');
end