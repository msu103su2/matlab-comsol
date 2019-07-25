function [Params, Links] = init_shan()
%import necessary libarary
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

ucindex = struct(f1, 'ucindex', f2, 1, f3, '[1]', f4, ['assume the defect'...
    'as 0, positive integer as X+ geomtries and negative X-']);
UL = struct(f1, 'UL', f2, 200e-6, f3, '[m]', f4, 'Unitcell length');
UW = struct(f1, 'UW', f2, 10e-6, f3, '[m]', f4, 'Unitcell width');
UH = struct(f1, 'UH', f2, 20e-9, f3, '[m]', f4, 'Unitcell height');
Ux = struct(f1, 'Ux', f2, (UL.value+DL.value)/2, f3, '[m]', f4, 'Unitcell x position');
Uy = struct(f1, 'Uy', f2, Dy.value, f3, '[m]', f4, 'Unitcell y position');
Uz = struct(f1, 'Uz', f2, Dz.value, f3, '[m]', f4, 'Unitcell z position');

kx = struct(f1, 'kx', f2, 2*pi/DL.value, f3, '[1/m]', f4, 'Defect length');
MS = struct(f1, 'MS', f2, DL.value/20, f3, '[m]', f4, 'Mesh typical size');
NumofUC = struct(f1, 'NumofUC', f2, 5, f3, '[1]', f4, 'Unitcell number on one side');

Params = [DL, DW, DH, Dx, Dy, Dz, UL, UW, UH, Ux, Uy, Uz, kx, MS, NumofUC, ucindex];
BaseParams = [ucindex, UL, UW, UH, Ux, Uy, Uz];
RightArrayParams = repmat(BaseParams, NumofUC.value, 1);
LeftArrayParams = repmat(BaseParams, NumofUC.value, 1);

%----Model node creation and modification
model = ModelUtil.create('Model');

%----Model params defination
for i = 1 : size(Params,2)
    model.param.set(Params(i).name,[num2str(Params(i).value) Params(i).unit], ...
        Params(i).comment);
end

%----Geom creation----
geom1 = model.geom.create('geom1', 3);

%----geom.wp1---------
wp1 = geom1.feature.create('wp1', 'WorkPlane');
wp1.set('quickplane', 'xy');
defect = wp1.geom.feature.create('defect', 'Rectangle');
defect.set('size', [DL.value DW.value]);
defect.set('base', 'center');
defect.set('pos', [Dx.value Dy.value]);

%deal with the geomtry array
LeftArrayParams(1,5).value = -LeftArrayParams(1,5).value;
for i = 1 : NumofUC.value
    RightUCs(i) =  wp1.geom.feature.create(['RightUC_' num2str(i)], 'Rectangle');
    LeftUCs(i) =  wp1.geom.feature.create(['LeftUC_' num2str(i)], 'Rectangle');
    if i>1
    RightArrayParams(i,:) = UCP_byIndex(i, RightArrayParams, 1);
    LeftArrayParams(i,:) = UCP_byIndex(i, LeftArrayParams, -1);
    end
end
for i = 1 : NumofUC.value
    SetElement(i, RightArrayParams, RightUCs);
    SetElement(i, LeftArrayParams, LeftUCs);
end

Uni = wp1.geom.feature.create('Uni', 'Union');
Uni.selection('input').set('defect');
ext1 = geom1.feature.create('ext1','Extrude');
ext1.selection('input').set({'wp1.Uni'});

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

Links = {model, geom1, wp1, Uni, ext1, mesh, Msize, ftri, swel, iss1, ...
    fix1, std, eig, defect, LeftUCs, RightUCs};
Params = {DL, DW, DH, Dx, Dy, Dz, UL, UW, UH, Ux, Uy, Uz, kx, MS, NumofUC, ucindex};
end