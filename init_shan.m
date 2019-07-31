function [Params, Links] = init_shan()
%import necessary libarary and test git
import com.comsol.model.*
import com.comsol.model.util.*

%----params defined section-----
% paramname = {value, 'unit', 'comments'}
f1 = 'name';   f2 = 'value';    f3 = 'unit';    f4 = 'comment';
DL = struct(f1, 'DL', f2, 200e-6, f3, '[m]', f4, 'Defect length');
DW = struct(f1, 'DW', f2, 10e-6, f3, '[m]', f4, 'Defect width');
DH = struct(f1, 'DH', f2, 20e-9, f3, '[m]', f4, 'Defect height');
Dx = struct(f1, 'Dx', f2, 0, f3, '[m]', f4, 'Defect x position');
Dy = struct(f1, 'Dy', f2, 0, f3, '[m]', f4, 'Defect y position');
Dz = struct(f1, 'Dz', f2, 0, f3, '[m]', f4, 'Defect z position');
kx = struct(f1, 'kx', f2, 2*pi/DL.value, f3, '[1/m]', f4, 'Defect length');
MS = struct(f1, 'MS', f2, DL.value/20, f3, '[m]', f4, 'Mesh typical size');
NumofUC = struct(f1, 'NumofUC', f2, 5, f3, '[1]', f4, 'Unitcell number on one side');
Params = {DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC};

%----Model node creation and modification
model = ModelUtil.create('Model');
model.hist.disable;
%----Model params defination
for i = 1 : size(Params,2)
    model.param.set(Params{i}.name,[num2str(Params{i}.value) Params{i}.unit], ...
        Params{i}.comment);
end

%----Geom creation----
geom1 = model.geom.create('geom1', 3);

%----geom.wp1---------
wp1 = geom1.feature.create('wp1', 'WorkPlane');

%Just reserve space for Params
[BaseParams, Basenames] = unitcellgeom(wp1);

ext1 = geom1.feature.create('ext1','Extrude');
ext1.selection('input').set('wp1');

Si3N4 = model.material.create('Si3N4');
Si3N4.selection.all;
Si3N4.label('Si3N4');
Si3N4.materialModel('def').set('electricconductivity', {'0[S/m]' '0' '0' '0' '0[S/m]' '0' '0' '0' '0[S/m]'});
Si3N4.materialModel('def').set('thermalexpansioncoefficient', {'2.3e-6[1/K]' '0' '0' '0' '2.3e-6[1/K]' '0' '0' '0' '2.3e-6[1/K]'});
Si3N4.materialModel('def').set('heatcapacity', '700[J/(kg*K)]');
Si3N4.materialModel('def').set('relpermittivity', {'9.7' '0' '0' '0' '9.7' '0' '0' '0' '9.7'});
Si3N4.materialModel('def').set('density', '3100[kg/m^3]');
Si3N4.materialModel('def').set('thermalconductivity', {'20[W/(m*K)]' '0' '0' '0' '20[W/(m*K)]' '0' '0' '0' '20[W/(m*K)]'});
Si3N4.materialModel('def').set('youngsmodulus', '250e9[Pa]');
Si3N4.materialModel('def').set('poissonsratio', '0.23');

mesh = model.mesh.create('mesh', 'geom1');
Msize = mesh.feature('size');
ftri = mesh.feature.create('ftri', 'FreeTri');
swel = mesh.create('swel', 'Sweep');

solid = model.physics.create('solid', 'SolidMechanics', 'geom1');
fix1 = solid.create('fix1', 'Fixed', 2);
iss1 = solid.feature('lemm1').create('iss1', 'InitialStressandStrain', 3);

std = model.study.create('std');
stat = std.feature.create('stat', 'Stationary');
stat.set('geometricNonlinearity', true);
ModelUtil.showProgress(true);
eig = std.feature.create('eig', 'Eigenfrequency');
eig.set('neigsactive', true);
eig.set('geometricNonlinearity', true);
eig.set('useadvanceddisable', true);

Links = {model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, ...
    fix1, std, eig};
Params = {Params, BaseParams};
end