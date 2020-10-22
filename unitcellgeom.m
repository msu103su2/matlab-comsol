function rUC = unitcellgeom(workplane, UC)
%construct the unit cell geom
import com.comsol.model.*
import com.comsol.model.util.*

%----check geom parameter compatibility----
compatible = CheckChamferFillet(UC.A.length, UC.A.width, UC.B.length, UC.B.width, UC.A.chamfer, UC.A.fillet);
compatible = compatible && CheckChamferFillet(UC.B.length, UC.B.width, UC.C.length, UC.C.width, UC.C.chamfer, UC.C.fillet);
if (UC.A.width < UC.B.width && UC.B.width > UC.C.width)
    compatible = compatible && (UC.B.length > (UC.A.fillet+UC.C.fillet)*tan(pi/8)+(UC.A.chamfer+UC.C.chamfer));
end
if (UC.A.width > UC.B.width && UC.B.width < UC.C.width)
    compatible = compatible && (UC.B.length > (UC.A.fillet+UC.C.fillet)*tan(pi/8));
end
if (UC.A.width < UC.B.width && UC.B.width < UC.C.width)
    compatible = compatible && (UC.B.length > (UC.A.fillet+UC.C.fillet)*tan(pi/8)+UC.A.chamfer);
end
if (UC.A.width > UC.B.width && UC.B.width > UC.C.width)
    compatible = compatible && (UC.B.length > (UC.A.fillet+UC.C.fillet)*tan(pi/8)+UC.C.chamfer);
end
assert(compatible,'double check codes. Incompatible geom parameter sets detected');

%---create geometry and set up chamfer and fillet on correct rectangle
%based on relative widths of rectangle ABC---
RecA = workplane.geom.feature.create(UC.A.comsol_Rec_name, 'Rectangle');
RecB = workplane.geom.feature.create(UC.B.comsol_Rec_name, 'Rectangle');
RecC = workplane.geom.feature.create(UC.C.comsol_Rec_name, 'Rectangle');
RecA.set('base', 'center');
RecB.set('base', 'center');
RecC.set('base', 'center');
UC.constructedNameList = {UC.A.comsol_Rec_name, ...
    UC.B.comsol_Rec_name,UC.C.comsol_Rec_name};

RecA.set('size', [UC.A.length UC.A.width]);
RecB.set('size', [UC.B.length UC.B.width]);
RecC.set('size', [UC.C.length UC.C.width]);

RecA.set('pos', [UC.A.x UC.A.y]);
RecB.set('pos', [UC.B.x UC.B.y]);
RecC.set('pos', [UC.C.x UC.C.y]);

if UC.formUni
    UCUnion = workplane.geom.feature.create([UC.NamePrefix,'Uni'], 'Union');
    UCUnion.set('intbnd', false);
    UCUnion.selection('input').set(UC.constructedNameList);

    indiceComp = 4;

    if not(UC.A.chamfer == 0)
        UCchaA = workplane.geom.feature.create(UC.A.comsol_chamfer_name, 'Chamfer');
        UCchaA.selection('point').set([UC.NamePrefix,'Uni'], [3 6]);
        UCchaA.set('dist', UC.A.chamfer);

        UCfilA = workplane.geom.feature.create(UC.A.comsol_fillet_name, 'Fillet');
        UCfilA.selection('point').set(UC.A.comsol_chamfer_name, [3 4 5 6]);
        UCfilA.set('radius', UC.A.fillet);

        UC.constructedNameList = [UC.constructedNameList, ...
            UC.A.comsol_chamfer_name, UC.A.comsol_fillet_name];

        indiceComp = 0;
    end
    if not(UC.C.chamfer == 0)
        UCchaC = workplane.geom.feature.create(UC.C.comsol_chamfer_name, 'Chamfer');
        if (indiceComp == 0)
            UCchaC.selection('point').set(UC.A.comsol_fillet_name, [9 12]-indiceComp);
        else
            UCchaC.selection('point').set([UC.NamePrefix,'Uni'], [9 12]-indiceComp);
        end
        UCchaC.set('dist', UC.C.chamfer);

        UCfilC = workplane.geom.feature.create(UC.C.comsol_fillet_name, 'Fillet');
        UCfilC.selection('point').set(UC.C.comsol_chamfer_name, [9 10 11 12]-indiceComp);
        UCfilC.set('radius', UC.C.fillet);

        UC.constructedNameList = [UC.constructedNameList, ...
            UC.C.comsol_chamfer_name, UC.C.comsol_fillet_name];
    end
end

%---return Params and object names in comsol. The names might not be used in
%comsol as the associsated params will be 0.---
rUC = UC;
end