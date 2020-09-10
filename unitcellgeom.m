function [rUCParams, rnames] = unitcellgeom(workplane, DefectParams, UCParams, names)
%construct the unit cell geom
import com.comsol.model.*
import com.comsol.model.util.*

if nargin < 3
    f1 = 'name';   f2 = 'value';    f3 = 'unit';    f4 = 'comment';
    UL = struct(f1, 'UL', f2, 140e-6, f3, '[m]', f4, 'Unitcell length');
    UW = struct(f1, 'UW', f2, 10e-6, f3, '[m]', f4, 'Unitcell width');
    UH = struct(f1, 'UH', f2, DefectParams{3}.value, f3, '[m]', f4, 'Unitcell height');
    Ux = struct(f1, 'Ux', f2, 0, f3, '[m]', f4, 'Unitcell x position');
    Uy = struct(f1, 'Uy', f2, 0, f3, '[m]', f4, 'Unitcell y position');
    Uz = struct(f1, 'Uz', f2, 0, f3, '[m]', f4, 'Unitcell z position');
    UrecL = struct(f1, 'UrecL', f2, 100e-6, f3, '[m]', f4, 'the length of a rectangle unit in Unitcell');
    UrecW = struct(f1, 'UrecW', f2, 15e-6, f3, '[m]', f4, 'the width of a rectangle unit in Unitcell');
    UCCharmA = struct(f1, 'ChamferA', f2, 0, f3, '[m]', f4, 'Chamfer A side radius');
    UCCharmC = struct(f1, 'ChamferC', f2, 0, f3, '[m]', f4, 'Chamfer C side radius');
    UCFilletA = struct(f1, 'FilletA', f2, 0, f3, '[m]', f4, 'fillet A side radius');
    UCFilletC = struct(f1, 'FilletC', f2, 0, f3, '[m]', f4, 'fillet C side radius');
    names = {'UCRA' 'UCRB' 'UCRC' 'UCUnion1' 'UCCharmA' 'UCCharmC' 'UCFilletA' 'UCFilletC'};
    RecParams = [[UL.value/3, UL.value/3, UL.value/3];[UW.value, UW.value, UW.value]];
    RecParams = struct(f1, 'RecParams', f2, RecParams, f3, '[m]', f4, 'Rectangle lengths and widths');
elseif nargin < 4
    [UL, UW, UH, Ux, Uy, Uz, UrecL, UrecW, UCCharmA, UCCharmC, UCFilletA, UCFilletC, RecParams] = UCParams{1:end};
    names = {'UCRA' 'UCRB' 'UCRC' 'UCUnion1' 'UCCharmA' 'UCCharmC' 'UCFilletA' 'UCFilletC'};
    UH.value = DefectParams{3}.value;
else
    [UL, UW, UH, Ux, Uy, Uz, UrecL, UrecW, UCCharmA, UCCharmC, UCFilletA, UCFilletC, RecParams] = UCParams{1:end};
    UH.value = DefectParams{3}.value;
end

RecParams = RecParams.value;
RecA_length = RecParams(1,1);RecB_length = RecParams(1,2);RecC_length = RecParams(1,3);
RecA_width = RecParams(2,1);RecB_width = RecParams(2,2);RecC_width = RecParams(2,3);
RecParams = struct(f1, 'RecParams', f2, RecParams, f3, '[m]', f4, 'Rectangle lengths and widths');

%----check geom parameter compatibility----
compatible = CheckChamferFillet(RecA_length, RecA_width, RecB_length, RecB_width, UCCharmA.value, UCFilletA.value);
compatible = compatible && CheckChamferFillet(RecB_length, RecB_width, RecC_length, RecC_width, UCCharmC.value, UCFilletC.value);
if (RecA_width < RecB_width && RecB_width > RecC_width)
    compatible = compatible && (RecB_length > (UCFilletA.value+UCFillet.value)*tan(pi/8)+(UCCharmA.value+UCCharmC.value));
end
if (RecA_width > RecB_width && RecB_width < RecC_width)
    compatible = compatible && (RecB_length > (UCFilletA.value+UCFillet.value)*tan(pi/8));
end
if (RecA_width < RecB_width && RecB_width < RecC_width)
    compatible = compatible && (RecB_length > (UCFilletA.value+UCFillet.value)*tan(pi/8)+UCCharmA.value);
end
if (RecA_width > RecB_width && RecB_width > RecC_width)
    compatible = compatible && (RecB_length > (UCFilletA.value+UCFillet.value)*tan(pi/8)+UCCharmC.value);
end
assert(compatible,'double check codes. Incompatible geom parameter sets detected');

%---create geometry based on given center location Ux of center block, and
%set up chamfer and fillet on correct rectangle based on relative widths of
%rectangle ABC---
RecA = workplane.geom.feature.create(names{1}, 'Rectangle');
RecB = workplane.geom.feature.create(names{2}, 'Rectangle');
RecC = workplane.geom.feature.create(names{3}, 'Rectangle');

RecA.set('base', 'center');
RecB.set('base', 'center');
RecC.set('base', 'center');

RecA.set('size', [RecA_length RecA_width]);
RecB.set('size', [RecB_length RecB_width]);
RecC.set('size', [RecC_length RecC_width]);

RecA.set('pos', [Ux.value-(RecA_length + RecB_length)/2 Uy.value]);
RecB.set('pos', [Ux.value Uy.value]);
RecC.set('pos', [Ux.value+(RecC_length + RecB_length)/2 Uy.value]);

if RecA_width < RecB_width
    UCchaA = workplane.geom.feature.create(names{5}, 'Chamfer');
    UCchaA.selection('point').set(names{2}, [1 4]);
    UCchaA.set('dist', UCCharmA.value);

    UCfilA = workplane.geom.feature.create(names{7}, 'Fillet');
    UCfilA.selection('point').set(names{5}, [1 2 3 4]);
    UCfilA.set('radius', UCFilletA.value);
elseif RecA_width > RecB_width
    UCchaA = workplane.geom.feature.create(names{5}, 'Chamfer');
    UCchaA.selection('point').set(names{1}, [2 3]);
    UCchaA.set('dist', UCCharmA.value);
    
    UCfilA = workplane.geom.feature.create(names{7}, 'Fillet');
    UCfilA.selection('point').set(names{5}, [1 2 3 4]);
    UCfilA.set('radius', UCFilletA.value);
end

if RecC_width < RecB_width
    UCchaC = workplane.geom.feature.create(names{6}, 'Chamfer');
    UCchaC.selection('point').set(names{2}, [2 3]);
    UCchaC.set('dist', UCCharmC.value);

    UCfilC = workplane.geom.feature.create(names{8}, 'Fillet');
    UCfilC.selection('point').set(names{6}, [1 2 3 4]);
    UCfilC.set('radius', UCFilletC.value);
elseif RecC_width > RecB_width
    UCchaC = workplane.geom.feature.create(names{6}, 'Chamfer');
    UCchaC.selection('point').set(names{3}, [1 4]);
    UCchaC.set('dist', UCCharmC.value);

    UCfilC = workplane.geom.feature.create(names{8}, 'Fillet');
    UCfilC.selection('point').set(names{6}, [1 2 3 4]);
    UCfilC.set('radius', UCFilletC.value);
end

%---return Params and object names in comsol. The names might not be used in
%comsol as the associsated params will be 0.---
rUCParams = {UL UW UH Ux Uy Uz UrecL UrecW UCCharmA UCCharmC UCFilletA UCFilletC RecParams};
rnames = names;
end