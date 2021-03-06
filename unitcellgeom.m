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
    ChamferR = struct(f1, 'ChamferR', f2, 2.5e-6, f3, '[m]', f4, 'Chamfer radius');
    FilletR = struct(f1, 'FilletR', f2, 4.26776e-6, f3, '[m]', f4, 'fillet radius');
    names = {'UCR1' 'UCR2' 'UCUnion1' 'UCCharm1' 'UCFillet1'};
elseif nargin < 4
    [UL, UW, UH, Ux, Uy, Uz, UrecL, UrecW, ChamferR, FilletR] = UCParams{1:end};
    names = {'UCR1' 'UCR2' 'UCUnion1' 'UCCharm1' 'UCFillet1'};
    UH.value = DefectParams{3}.value;
else
    [UL, UW, UH, Ux, Uy, Uz, UrecL, UrecW, ChamferR, FilletR] = UCParams{1:end};
    UH.value = DefectParams{3}.value;
end



BaseRec = workplane.geom.feature.create(names{1}, 'Rectangle');
ComplRec = workplane.geom.feature.create(names{2}, 'Rectangle');

BaseRec.set('base', 'center');
ComplRec.set('base', 'center');
BaseRec.set('pos', [Ux.value Uy.value]);
ComplRec.set('pos', [Ux.value Uy.value]);

BaseRec.set('size', [UL.value UW.value]);
ComplRec.set('size', [UrecL.value UrecW.value]);

UCUnion = workplane.geom.feature.create(names{3}, 'Union');
UCUnion.selection('input').set(names(1:2));
UCUnion.set('intbnd', false);

UCcha = workplane.geom.feature.create(names{4}, 'Chamfer');
UCcha.selection('point').set(names{3}, [3 6 7 10]);
UCcha.set('dist', ChamferR.value);

UCfil = workplane.geom.feature.create(names{5}, 'Fillet');
UCfil.selection('point').set(names{4}, [3 4 5 6 7 8 9 10]);
UCfil.set('radius', FilletR.value);

rUCParams = {UL UW UH Ux Uy Uz UrecL UrecW ChamferR FilletR};
rnames = names;
end