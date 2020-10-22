function [params, links] = init_shan()
%import necessary libarary
import com.comsol.model.*
import com.comsol.model.util.*

global totallength;

%----params defined section-----
MS = 3e-6;
baseRec = PhC_Rec(140e-6, 10e-6,118e-9,'Defect');
A = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'A');
B = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'B');
C = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'C');
A.x = -(A.length + B.length)/2;
C.x = (C.length + B.length)/2;
defect = UnitCell(A,B,C);
defect.rename('defect');

%----Model node creation and modification
model = ModelUtil.create('Model');
model.hist.disable;

%----Geom creation----
geom1 = model.geom.create('geom1', 3);

%----geom.wp1---------
wp1 = geom1.feature.create('wp1', 'WorkPlane');

%Prepare a straight string as template
unitcellgeom(wp1, defect);
NumofUC = floor((totallength-defect.length)/...
    (2*defect.length));
UCs = []; %increase size in a loop, to be optimize if necessary
for i = 1 : 2*NumofUC
    comsol_index = ceil(i/2); 
    
    A = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'A');
    B = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'B');
    C = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'C');
    A.x = -(A.length + B.length)/2;
    C.x = (C.length + B.length)/2;
    UC = UnitCell(A,B,C);

    UCs = [UCs, UC];
    if rem(i, 2) == 0
        UCs(i).moveTo(defect.x - defect.length/2 - UCs(i).length * (comsol_index-0.5), 0, 0);
        UCs(i).rename(['L',num2str(comsol_index)]);
    else
        UCs(i).moveTo(defect.x + defect.length/2 + UCs(i).length * (comsol_index-0.5), 0, 0);
        UCs(i).rename(['R',num2str(comsol_index)]);
    end
    unitcellgeom(wp1, UCs(i));
end

%construct Params instance
params = Params(defect, UCs, NumofUC, MS);

%----Comsol Model params defination
model.param.set('DL',[num2str(params.defect.length) '[m]']);
model.param.set('DW',[num2str(params.defect.B.width) '[m]']);
model.param.set('DH',[num2str(params.defect.B.height) '[m]']);
model.param.set('Dx',[num2str(params.defect.x) '[m]']);
model.param.set('Dy',[num2str(params.defect.y) '[m]']);
model.param.set('Dz',[num2str(params.defect.z) '[m]']);
model.param.set('MS',[num2str(params.MS) '[m]']);
model.param.set('NumofUC',[num2str(params.NumofUC) '[1]']);

%other initializations
exts(1) = geom1.feature.create('ext1','Extrude');
exts(1).selection('input').set('wp1');

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
ref1 = mesh.create('ref1','Refine');
ref2 = mesh.create('ref2','Refine');
ref3 = mesh.create('ref3','Refine');
ref4 = mesh.create('ref4','Refine');
swel = mesh.create('swel', 'Sweep');
swe2 = mesh.create('swe2', 'Sweep');
ref = {ref1,ref2,ref3,ref4};

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

links = Links(model, geom1, wp1, exts, mesh, Msize, ftri, swel, swe2, iss1, ...
    fix1, std, eig, solid, ref);
end