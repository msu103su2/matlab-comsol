function out = model
%
% new.m
%
% Model exported on Aug 2 2019, 13:07 by COMSOL 5.4.0.346.

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
model.param.set('NumofUC', '8[1]', 'Unitcell number on one side');

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
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_1').set('pos', [-0.0016 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_1').set('pos', [-0.0016 0]);
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
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_2').set('pos', [-0.0014000000000000002 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_2').set('pos', [-0.0014000000000000002 0]);
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
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_3').set('pos', [-0.0012000000000000001 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_3').set('pos', [-0.0012000000000000001 0]);
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
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_4').set('pos', [-0.001 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_4').set('pos', [-0.001 0]);
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
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_5', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_5', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_5').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_5').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_5').set('pos', [-8.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_5').set('pos', [-8.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_5').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_5').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_5', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_5').selection('input').set({'UCR1_5' 'UCR2_5'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_5').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_5', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_5').selection('point').set('UCUnion1_5', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_5').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_5', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_5').selection('point').set('UCCharm1_5', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_5').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_6', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_6', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_6').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_6').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_6').set('pos', [-6.000000000000001E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_6').set('pos', [-6.000000000000001E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_6').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_6').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_6', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_6').selection('input').set({'UCR1_6' 'UCR2_6'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_6').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_6', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_6').selection('point').set('UCUnion1_6', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_6').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_6', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_6').selection('point').set('UCCharm1_6', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_6').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_7', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_7', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_7').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_7').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_7').set('pos', [-4.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_7').set('pos', [-4.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_7').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_7').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_7', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_7').selection('input').set({'UCR1_7' 'UCR2_7'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_7').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_7', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_7').selection('point').set('UCUnion1_7', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_7').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_7', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_7').selection('point').set('UCCharm1_7', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_7').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_8', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_8', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_8').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_8').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_8').set('pos', [-2.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_8').set('pos', [-2.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_8').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_8').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_8', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_8').selection('input').set({'UCR1_8' 'UCR2_8'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_8').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_8', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_8').selection('point').set('UCUnion1_8', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_8').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_8', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_8').selection('point').set('UCCharm1_8', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_8').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_9', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_9', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_9').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_9').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_9').set('pos', [2.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_9').set('pos', [2.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_9').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_9').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_9', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_9').selection('input').set({'UCR1_9' 'UCR2_9'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_9').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_9', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_9').selection('point').set('UCUnion1_9', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_9').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_9', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_9').selection('point').set('UCCharm1_9', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_9').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_10', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_10', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_10').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_10').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_10').set('pos', [4.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_10').set('pos', [4.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_10').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_10').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_10', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_10').selection('input').set({'UCR1_10' 'UCR2_10'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_10').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_10', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_10').selection('point').set('UCUnion1_10', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_10').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_10', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_10').selection('point').set('UCCharm1_10', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_10').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_11', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_11', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_11').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_11').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_11').set('pos', [6.000000000000001E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_11').set('pos', [6.000000000000001E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_11').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_11').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_11', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_11').selection('input').set({'UCR1_11' 'UCR2_11'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_11').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_11', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_11').selection('point').set('UCUnion1_11', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_11').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_11', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_11').selection('point').set('UCCharm1_11', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_11').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_12', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_12', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_12').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_12').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_12').set('pos', [8.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_12').set('pos', [8.0E-4 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_12').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_12').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_12', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_12').selection('input').set({'UCR1_12' 'UCR2_12'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_12').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_12', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_12').selection('point').set('UCUnion1_12', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_12').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_12', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_12').selection('point').set('UCCharm1_12', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_12').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_13', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_13', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_13').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_13').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_13').set('pos', [0.001 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_13').set('pos', [0.001 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_13').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_13').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_13', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_13').selection('input').set({'UCR1_13' 'UCR2_13'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_13').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_13', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_13').selection('point').set('UCUnion1_13', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_13').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_13', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_13').selection('point').set('UCCharm1_13', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_13').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_14', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_14', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_14').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_14').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_14').set('pos', [0.0012000000000000001 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_14').set('pos', [0.0012000000000000001 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_14').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_14').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_14', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_14').selection('input').set({'UCR1_14' 'UCR2_14'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_14').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_14', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_14').selection('point').set('UCUnion1_14', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_14').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_14', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_14').selection('point').set('UCCharm1_14', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_14').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_15', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_15', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_15').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_15').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_15').set('pos', [0.0014000000000000002 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_15').set('pos', [0.0014000000000000002 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_15').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_15').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_15', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_15').selection('input').set({'UCR1_15' 'UCR2_15'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_15').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_15', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_15').selection('point').set('UCUnion1_15', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_15').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_15', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_15').selection('point').set('UCCharm1_15', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_15').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR1_16', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCR2_16', 'Rectangle');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_16').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_16').set('base', 'center');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_16').set('pos', [0.0016 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_16').set('pos', [0.0016 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1_16').set('size', [2.0E-4 1.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2_16').set('size', [1.0E-4 2.0E-5]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCUnion1_16', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_16').selection('input').set({'UCR1_16' 'UCR2_16'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1_16').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCCharm1_16', 'Chamfer');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_16').selection('point').set('UCUnion1_16', [3 6 7 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1_16').set('dist', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('UCFillet1_16', 'Fillet');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_16').selection('point').set('UCCharm1_16', [3 4 5 6 7 8 9 10]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1_16').set('radius', 5.0E-6);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR1').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCR2').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCUnion1').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCCharm1').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('UCFillet1').active(false);
model.component('mod1').geom('geom1').feature('wp1').geom.create('ls1', 'LineSegment');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('ls1').set('specify1', 'coord');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('ls1').set('specify2', 'coord');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('ls1').set('coord1', [-0.0017000000000000001 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('ls1').set('coord2', [0 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.create('ls2', 'LineSegment');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('ls2').set('specify1', 'coord');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('ls2').set('specify2', 'coord');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('ls2').set('coord1', [0 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('ls2').set('coord2', [0.0017000000000000001 0]);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('Uni_small', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('Uni_small').selection('input').set({'UCFillet1_1' 'UCFillet1_2' 'UCFillet1_3' 'UCFillet1_4' 'UCFillet1_5' 'UCFillet1_6' 'UCFillet1_7' 'UCFillet1_8' 'UCFillet1_9' 'UCFillet1_10'  ...
'UCFillet1_11' 'UCFillet1_12' 'UCFillet1_13' 'UCFillet1_14' 'UCFillet1_15' 'UCFillet1_16' 'defect'});
model.component('mod1').geom('geom1').feature('wp1').geom.feature('Uni_small').set('intbnd', false);
model.component('mod1').geom('geom1').feature('wp1').geom.feature.create('Uni', 'Union');
model.component('mod1').geom('geom1').feature('wp1').geom.feature('Uni').set('intbnd', true);
model.component('mod1').geom('geom1').feature('wp1').geom.feature('Uni').selection('input').set({'Uni_small' 'ls1' 'ls2'});
model.component('mod1').geom('geom1').feature('ext1').set('workplane', 'wp1');
model.component('mod1').geom('geom1').feature('ext1').selection('input').set({'wp1.Uni'});
model.component('mod1').geom('geom1').feature('ext1').set('distance', 'DH');
model.component('mod1').geom('geom1').run;

model.component('mod1').physics('solid').feature('lemm1').feature('iss1').set('Sil', {'1e9' '0' '0' '0' '1e9' '0' '0' '0' '0'});

model.study('std').feature('eig').set('neigs', 100);

model.component('mod1').geom('geom1').create('difblock', 'Block');
model.component('mod1').geom('geom1').feature('difblock').set('size', [0.0034000000000000002 1.0E-4 2.0E-8]);
model.component('mod1').geom('geom1').feature('difblock').set('pos', [0 5.0E-5 1.0E-8]);
model.component('mod1').geom('geom1').feature('difblock').set('base', 'center');
model.component('mod1').geom('geom1').create('dif1', 'Difference');
model.component('mod1').geom('geom1').feature('dif1').selection('input').set({'ext1'});
model.component('mod1').geom('geom1').feature('dif1').selection('input2').set({'difblock'});
model.component('mod1').geom('geom1').run;

model.component('mod1').physics('solid').create('sym1', 'SymmetrySolid', 2);

model.component('mod1').geom('geom1').run;

model.component('mod1').physics('solid').feature('sym1').selection.set([5 78]);

model.component('mod1').geom('geom1').run;
model.component('mod1').geom('geom1').run;
model.component('mod1').geom('geom1').run;
model.component('mod1').geom('geom1').run;

model.component('mod1').physics('solid').feature('fix1').selection.set([1 151]);

model.component('mod1').mesh('mesh').feature('size').set('hmax', 'MS');
model.component('mod1').mesh('mesh').feature('size').set('hmin', 'MS/4');
model.component('mod1').mesh('mesh').feature('size').set('hcurve', '0.2');
model.component('mod1').mesh('mesh').feature('ftri').selection.set([4]);
model.component('mod1').mesh('mesh').feature('swel').selection('sourceface').set([4]);
model.component('mod1').mesh('mesh').feature('swel').selection('targetface').set([3]);
model.component('mod1').mesh('mesh').run;

model.study('std').run;

model.component('mod1').geom('geom1').run;

model.result.numerical.remove('eval_internal');
model.result.numerical.create('eval_internal', 'Eval');
model.result.numerical('eval_internal').set('expr', 'u*u+v*v+w*w');
model.result.numerical('eval_internal').set('complexfun', 'on');
model.result.numerical('eval_internal').set('matherr', 'off');
model.result.numerical('eval_internal').set('phase', 0);
model.result.numerical('eval_internal').set('recover', 'off');
model.result.numerical('eval_internal').set('refine', 1);
model.result.numerical('eval_internal').set('solnum', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10'  ...
'11' '12' '13' '14' '15' '16' '17' '18' '19' '20'  ...
'21' '22' '23' '24' '25' '26' '27' '28' '29' '30'  ...
'31' '32' '33' '34' '35' '36' '37' '38' '39' '40'  ...
'41' '42' '43' '44' '45' '46' '47' '48' '49' '50'  ...
'51' '52' '53' '54' '55' '56' '57' '58' '59' '60'  ...
'61' '62' '63' '64' '65' '66' '67' '68' '69' '70'  ...
'71' '72' '73' '74' '75' '76' '77' '78' '79' '80'  ...
'81' '82' '83' '84' '85' '86' '87' '88' '89' '90'  ...
'91' '92' '93' '94' '95' '96' '97' '98' '99' '100'});
model.result.numerical('eval_internal').set('smooth', 'internal');
model.result.numerical('eval_internal').set('smoothexpr', []);
model.result.numerical('eval_internal').set('pattern', 'lagrange');
model.result.numerical('eval_internal').selection.geom(0);
model.result.numerical('eval_internal').selection.set([149]);
model.result.numerical('eval_internal').set('outersolnum', 1);
model.result.numerical('eval_internal').set('allowmaterialsmoothing', true);
model.result.numerical('eval_internal').set('expr', {'u*u+v*v+w*w'});
model.result.numerical('eval_internal').set('evalmethodactive', 'on');
model.result.numerical('eval_internal').set('outertype', 'none');
model.result.numerical('eval_internal').set('solvertype', 'solnum');
model.result.numerical('eval_internal').set('outersolnum', '1');
model.result.numerical('eval_internal').set('solnum', '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100');
model.result.numerical('eval_internal').set('timeinterp', 'off');
model.result.numerical('eval_internal').set('outersolnum', 1);
model.result.numerical('eval_internal').set('allowmaterialsmoothing', true);
model.result.numerical('eval_internal').set('expr', {'u*u+v*v+w*w'});
model.result.numerical('eval_internal').set('evalmethodactive', 'on');
model.result.numerical('eval_internal').set('outertype', 'none');
model.result.numerical('eval_internal').set('solvertype', 'solnum');
model.result.numerical('eval_internal').set('outersolnum', '1');
model.result.numerical('eval_internal').set('solnum', '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100');
model.result.numerical('eval_internal').set('timeinterp', 'off');
model.result.numerical('eval_internal').getData(0);
model.result.numerical('eval_internal').getCoordinates;
model.result.numerical('eval_internal').getElements;
model.result.numerical('eval_internal').getVertexElements;
model.result.numerical.remove('eval_internal');
model.result.numerical.create('num1', 'IntVolume');
model.result.numerical('num1').set('intorder', 4);
model.result.numerical('num1').set('method', 'auto');
model.result.numerical('num1').selection.all;

model.sol('sol1').getSizeMulti;
model.sol('sol1').getSize;
model.sol('sol1').getPVals;
model.sol('sol1').getPValsImag;

model.result.numerical('num1').set('expr', 'solid.rho*(u*u+v*v+w*w)');
model.result.numerical('num1').run;
model.result.numerical('num1').set('solnumindices', 1);
model.result.numerical('num1').set('outersolnum', 1);
model.result.numerical('num1').set('dataisaxisym', false);
model.result.numerical('num1').set('expr', {'solid.rho*(u*u+v*v+w*w)'});
model.result.numerical('num1').set('evalmethodactive', 'on');
model.result.numerical('num1').set('hasouter', false);
model.result.numerical('num1').set('outerinput', 'all');
model.result.numerical('num1').set('outersolnum', '1');
model.result.numerical('num1').set('solnum', '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100');
model.result.numerical('num1').set('outersolnumindices', '');
model.result.numerical('num1').set('solnumindices', '1');
model.result.numerical('num1').set('outerinput', 'all');
model.result.numerical('num1').set('innerinput', 'manualindices');
model.result.numerical('num1').set('looplevelinput', {'manualindices'});
model.result.numerical('num1').set('looplevel', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10'  ...
'11' '12' '13' '14' '15' '16' '17' '18' '19' '20'  ...
'21' '22' '23' '24' '25' '26' '27' '28' '29' '30'  ...
'31' '32' '33' '34' '35' '36' '37' '38' '39' '40'  ...
'41' '42' '43' '44' '45' '46' '47' '48' '49' '50'  ...
'51' '52' '53' '54' '55' '56' '57' '58' '59' '60'  ...
'61' '62' '63' '64' '65' '66' '67' '68' '69' '70'  ...
'71' '72' '73' '74' '75' '76' '77' '78' '79' '80'  ...
'81' '82' '83' '84' '85' '86' '87' '88' '89' '90'  ...
'91' '92' '93' '94' '95' '96' '97' '98' '99' '100'});
model.result.numerical('num1').set('looplevelindices', {'1'});
model.result.numerical('num1').set('interp', {''});
model.result.numerical('num1').set('solrepresentation', 'solutioninfo');

model.sol('sol1').getSizeMulti;

model.result.numerical('num1').set('solnumindices', [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100]);
model.result.numerical('num1').set('outersolnum', 1);
model.result.numerical('num1').set('dataisaxisym', false);
model.result.numerical('num1').set('expr', {'solid.rho*(u*u+v*v+w*w)'});
model.result.numerical('num1').set('evalmethodactive', 'on');
model.result.numerical('num1').set('hasouter', false);
model.result.numerical('num1').set('outerinput', 'all');
model.result.numerical('num1').set('outersolnum', '1');
model.result.numerical('num1').set('solnum', '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100');
model.result.numerical('num1').set('outersolnumindices', '');
model.result.numerical('num1').set('solnumindices', '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100');
model.result.numerical('num1').set('outerinput', 'all');
model.result.numerical('num1').set('innerinput', 'manualindices');
model.result.numerical('num1').set('looplevelinput', {'manualindices'});
model.result.numerical('num1').set('looplevel', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10'  ...
'11' '12' '13' '14' '15' '16' '17' '18' '19' '20'  ...
'21' '22' '23' '24' '25' '26' '27' '28' '29' '30'  ...
'31' '32' '33' '34' '35' '36' '37' '38' '39' '40'  ...
'41' '42' '43' '44' '45' '46' '47' '48' '49' '50'  ...
'51' '52' '53' '54' '55' '56' '57' '58' '59' '60'  ...
'61' '62' '63' '64' '65' '66' '67' '68' '69' '70'  ...
'71' '72' '73' '74' '75' '76' '77' '78' '79' '80'  ...
'81' '82' '83' '84' '85' '86' '87' '88' '89' '90'  ...
'91' '92' '93' '94' '95' '96' '97' '98' '99' '100'});
model.result.numerical('num1').set('looplevelindices', {'1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100'});
model.result.numerical('num1').set('interp', {''});
model.result.numerical('num1').set('solrepresentation', 'solutioninfo');
model.result.numerical.remove('num1');
model.result.numerical.remove('global_internal');
model.result.numerical.create('global_internal', 'Global');
model.result.numerical('global_internal').set('expr', 'solid.freq');
model.result.numerical('global_internal').set('matherr', 'off');
model.result.numerical('global_internal').set('phase', 0);
model.result.numerical('global_internal').set('outersolnum', 1);
model.result.numerical('global_internal').set('solnum', {'1' '2' '3' '4' '5' '6' '7' '8' '9' '10'  ...
'11' '12' '13' '14' '15' '16' '17' '18' '19' '20'  ...
'21' '22' '23' '24' '25' '26' '27' '28' '29' '30'  ...
'31' '32' '33' '34' '35' '36' '37' '38' '39' '40'  ...
'41' '42' '43' '44' '45' '46' '47' '48' '49' '50'  ...
'51' '52' '53' '54' '55' '56' '57' '58' '59' '60'  ...
'61' '62' '63' '64' '65' '66' '67' '68' '69' '70'  ...
'71' '72' '73' '74' '75' '76' '77' '78' '79' '80'  ...
'81' '82' '83' '84' '85' '86' '87' '88' '89' '90'  ...
'91' '92' '93' '94' '95' '96' '97' '98' '99' '100'});
model.result.numerical('global_internal').set('outersolnum', 1);
model.result.numerical('global_internal').set('expr', {'solid.freq'});
model.result.numerical('global_internal').set('evalmethodactive', 'on');
model.result.numerical('global_internal').set('outertype', 'none');
model.result.numerical('global_internal').set('solvertype', 'solnum');
model.result.numerical('global_internal').set('outersolnum', '1');
model.result.numerical('global_internal').set('solnum', '1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100');
model.result.numerical('global_internal').set('timeinterp', 'off');
model.result.numerical('global_internal').getData;
model.result.numerical('global_internal').getImagData;
model.result.numerical.remove('global_internal');
model.result.create('pg1', 'PlotGroup3D');
model.result('pg1').run;
model.result('pg1').create('vol1', 'Volume');
model.result('pg1').feature('vol1').create('def1', 'Deform');
model.result('pg1').run;
model.result('pg1').run;
model.result('pg1').run;
model.result('pg1').set('looplevel', [68]);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 69, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 70, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 71, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 72, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 73, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 74, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 75, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 76, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 77, 0);
model.result('pg1').run;
model.result('pg1').run;
model.result('pg1').set('looplevel', [33]);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 34, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 35, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 36, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 37, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 38, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 39, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 40, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 41, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 42, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 43, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 44, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 45, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 46, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 47, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 48, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 49, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 50, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 51, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 52, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 53, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 54, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 55, 0);
model.result('pg1').run;
model.result('pg1').setIndex('looplevel', 56, 0);
model.result('pg1').run;

model.study('std').feature('eig').set('shift', '5[Hz]');

out = model;
