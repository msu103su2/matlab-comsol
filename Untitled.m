function out = model
%
% Untitled.m
%
% Model exported on Jul 26 2019, 18:02 by COMSOL 5.4.0.346.

import com.comsol.model.*
import com.comsol.model.util.*

model = ModelUtil.create('Model');

model.modelPath('C:\Users\purdylab\Documents\Git_server');

model.param.set('DL', '0.0002[m]', 'Defect length');
model.param.set('DW', '1e-05[m]', 'Defect width');
model.param.set('DH', '2e-08[m]', 'Defect height');
model.param.set('Dx', '0[m]', 'Defect x position');
model.param.set('Dy', '0[m]', 'Defect y position');
model.param.set('Dz', '0[m]', 'Defect z position');
model.param.set('kx', '31415.9265[1/m]', 'Defect length');
model.param.set('MS', '1e-05[m]', 'Mesh typical size');
model.param.set('NumofUC', '5[1]', 'Unitcell number on one side');

model.geom.create('geom1', 3);
model.component('mod1').geom('geom1').feature.create('wp1', 'WorkPlane');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1').set('pos', [0 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2').set('pos', [0 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1').selection('input').set({'UCR1' 'UCR2'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1').selection('point').set('UCUnion1', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1').selection('point').set('UCCharm1', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature.create('ext1', 'Extrude');
model.component('mod1').geom('geom1').feature('ext1').selection('input').set({'wp1'});

model.component('mod1').material.create('Si3N4');
model.component('mod1').material('Si3N4').selection.all;
model.component('mod1').material('Si3N4').label('Si3N4');
model.component('mod1').material('Si3N4').propertyGroup('def').set('electricconductivity', {'0[S/m]' '0' '0' '0' '0[S/m]' '0' '0' '0' '0[S/m]'});
model.component('mod1').material('Si3N4').propertyGroup('def').set('thermalexpansioncoefficient', {'2.3e-6[1/K]' '0' '0' '0' '2.3e-6[1/K]' '0' '0' '0' '2.3e-6[1/K]'});
model.component('mod1').material('Si3N4').propertyGroup('def').set('heatcapacity', '700[J/(kg*K)]');
model.component('mod1').material('Si3N4').propertyGroup('def').set('relpermittivity', {'9.7' '0' '0' '0' '9.7' '0' '0' '0' '9.7'});
model.component('mod1').material('Si3N4').propertyGroup('def').set('density', '3100[kg/m^3]');
model.component('mod1').material('Si3N4').propertyGroup('def').set('thermalconductivity', {'20[W/(m*K)]' '0' '0' '0' '20[W/(m*K)]' '0' '0' '0' '20[W/(m*K)]'});
model.component('mod1').material('Si3N4').propertyGroup('def').set('youngsmodulus', '250e9[Pa]');
model.component('mod1').material('Si3N4').propertyGroup('def').set('poissonsratio', '0.23');

model.component('mod1').mesh.create('mesh');
model.component('mod1').mesh('mesh').feature.create('ftri', 'FreeTri');
model.component('mod1').mesh('mesh').create('swel', 'Sweep');

model.component('mod1').physics.create('solid', 'SolidMechanics', 'geom1');
model.component('mod1').physics('solid').create('fix1', 'Fixed', 2);
model.component('mod1').physics('solid').feature('lemm1').create('iss1', 'InitialStressandStrain', 3);

model.study.create('std');
model.study('std').feature.create('stat', 'Stationary');
model.study('std').feature('stat').set('geometricNonlinearity', true);
model.study('std').feature.create('eig', 'Eigenfrequency');
model.study('std').feature('eig').set('neigsactive', true);
model.study('std').feature('eig').set('geometricNonlinearity', true);
model.study('std').feature('eig').set('useadvanceddisable', true);

model.param.set('DL', '0.0002[m]', 'Defect length');
model.param.set('DW', '1e-05[m]', 'Defect width');
model.param.set('DH', '2e-08[m]', 'Defect height');
model.param.set('Dx', '0[m]', 'Defect x position');
model.param.set('Dy', '0[m]', 'Defect y position');
model.param.set('Dz', '0[m]', 'Defect z position');
model.param.set('kx', '31415.9265[1/m]', 'Defect length');
model.param.set('MS', '1e-05[m]', 'Mesh typical size');
model.param.set('NumofUC', '2[1]', 'Unitcell number on one side');

model.component('mod1').geom('geom1').feature.remove('wp1');
model.component('mod1').geom('geom1').feature.create('wp1', 'WorkPlane');
model.component('mod1').geom('geom1').feature.move('wp1', 0);
model.component('mod1').geom('geom1').feature('wp1').set('quickplane', 'xy');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('defect', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('defect').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('defect').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('defect').set('pos', [0 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1').set('pos', [0 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2').set('pos', [0 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1').selection('input').set({'UCR1' 'UCR2'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1').selection('point').set('UCUnion1', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1').selection('point').set('UCCharm1', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_1', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_1', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_1').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_1').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_1').set('pos', [-4.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_1').set('pos', [-4.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_1').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_1').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_1', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_1').selection('input').set({'UCR1_1' 'UCR2_1'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_1').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_1', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_1').selection('point').set('UCUnion1_1', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_1').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_1', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_1').selection('point').set('UCCharm1_1', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_1').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_2', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_2', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_2').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_2').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_2').set('pos', [-2.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_2').set('pos', [-2.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_2').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_2').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_2', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_2').selection('input').set({'UCR1_2' 'UCR2_2'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_2').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_2', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_2').selection('point').set('UCUnion1_2', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_2').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_2', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_2').selection('point').set('UCCharm1_2', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_2').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_3', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_3', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_3').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_3').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_3').set('pos', [2.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_3').set('pos', [2.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_3').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_3').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_3', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_3').selection('input').set({'UCR1_3' 'UCR2_3'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_3').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_3', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_3').selection('point').set('UCUnion1_3', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_3').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_3', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_3').selection('point').set('UCCharm1_3', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_3').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_4', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_4', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_4').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_4').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_4').set('pos', [4.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_4').set('pos', [4.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_4').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_4').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_4', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_4').selection('input').set({'UCR1_4' 'UCR2_4'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_4').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_4', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_4').selection('point').set('UCUnion1_4', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_4').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_4', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_4').selection('point').set('UCCharm1_4', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_4').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('Uni', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('Uni').selection('input').set({'UCFillet1_1' 'UCFillet1_2' 'UCFillet1_3' 'UCFillet1_4' 'defect'});
model.component('mod1').geom('geom1').feature('ext1').set('workplane', 'wp1');
model.component('mod1').geom('geom1').feature('ext1').selection('input').set({'wp1.Uni'});
model.component('mod1').geom('geom1').feature('ext1').set('distance', 'DH');
model.component('mod1').geom('geom1').run;
model.component('mod1').geom('geom1').run;
model.component('mod1').geom('geom1').run;
model.component('mod1').geom('geom1').run;
model.component('mod1').geom('geom1').run;

model.component('mod1').physics('solid').feature('fix1').selection.set([1 90]);

model.component('mod1').mesh('mesh').feature('size').set('hmax', 'MS');
model.component('mod1').mesh('mesh').feature('size').set('hmin', 'MS/4');
model.component('mod1').mesh('mesh').feature('size').set('hcurve', '0.2');
model.component('mod1').mesh('mesh').feature('ftri').selection.set([4 25 46 51 72]);
model.component('mod1').mesh('mesh').feature('swel').selection('sourceface').set([4 25 46 51 72]);
model.component('mod1').mesh('mesh').feature('swel').selection('targetface').set([4 25 46 51 72]);
model.component('mod1').mesh('mesh').run;

model.component('mod1').physics('solid').feature('lemm1').feature('iss1').set('Sil', {'1e9' '0' '0' '0' '1e9' '0' '0' '0' '0'});

model.study('std').feature('eig').set('neigs', 50);

model.component('mod1').mesh('mesh').run;

model.component('mod1').geom('geom1').feature('wp1').geom.feature('Uni').set('intbnd', false);
model.component('mod1').geom('geom1').run('fin');

model.component('mod1').mesh('mesh').run;

out = model;
