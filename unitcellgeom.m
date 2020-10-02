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
UC.constrctedNameList = [UC.A.comsol_Rec_name, ...
    UC.B.comsol_Rec_name,UC.C.comsol_Rec_name];

RecA.set('size', [UC.A.length UC.A.width]);
RecB.set('size', [UC.B.length UC.B.width]);
RecC.set('size', [UC.C.length UC.C.width]);

RecA.set('pos', [UC.A.x UC.A.y]);
RecB.set('pos', [UC.B.x UC.B.y]);
RecC.set('pos', [UC.C.x UC.C.y]);

if UC.A.width < UC.B.width
    UCchaA = workplane.geom.feature.create(UC.A.comsol_chamfer_name, 'Chamfer');
    UCchaA.selection('point').set(UC.B.comsol_Rec_name, [1 4]);
    UCchaA.set('dist', UC.A.chamfer);

    UCfilA = workplane.geom.feature.create(UC.A.comsol_fillet_name, 'Fillet');
    UCfilA.selection('point').set(UC.A.comsol_chamfer_name, [1 2 3 4]);
    UCfilA.set('radius', UC.A.fillet);
    
    UC.constructedNameList = [UC.constructedNameList, ...
        UC.A.comsol_chamfer_name, UC.A.comsol_fillet_name];
elseif UC.A.width > UC.B.width
    UCchaA = workplane.geom.feature.create(UC.A.comsol_chamfer_name, 'Chamfer');
    UCchaA.selection('point').set(UC.A.comsol_Rec_name, [2 3]);
    UCchaA.set('dist', UC.A.chamfer);
    
    UCfilA = workplane.geom.feature.create(UC.A.comsol_fillet_name, 'Fillet');
    UCfilA.selection('point').set(UC.A.comsol_chamfer_name, [1 2 3 4]);
    UCfilA.set('radius', UC.A.fillet);
    
    UC.constructedNameList = [UC.constructedNameList, ...
        UC.A.comsol_chamfer_name, UC.A.comsol_fillet_name];
end

if UC.C.width < UC.B.width
    UCchaC = workplane.geom.feature.create(UC.C.comsol_chamfer_name, 'Chamfer');
    UCchaC.selection('point').set(UC.B.comsol_Rec_name, [2 3]);
    UCchaC.set('dist', UC.C.chamfer);

    UCfilC = workplane.geom.feature.create(UC.C.comsol_fillet_name, 'Fillet');
    UCfilC.selection('point').set(UC.C.comsol_chamfer_name, [1 2 3 4]);
    UCfilC.set('radius', UC.C.fillet);
    
    UC.constructedNameList = [UC.constructedNameList, ...
        UC.C.comsol_chamfer_name, UC.C.comsol_fillet_name];
elseif UC.C.width > UC.B.width
    UCchaC = workplane.geom.feature.create(UC.C.comsol_chamfer_name, 'Chamfer');
    UCchaC.selection('point').set(UC.C.comsol_Rec_name, [1 4]);
    UCchaC.set('dist', UC.C.chamfer);

    UCfilC = workplane.geom.feature.create(UC.C.comsol_fillet_name, 'Fillet');
    UCfilC.selection('point').set(UC.C.comsol_chamfer_name, [1 2 3 4]);
    UCfilC.set('radius', UC.C.fillet);
    
    UC.constructedNameList = [UC.constructedNameList, ...
        UC.C.comsol_chamfer_name, UC.C.comsol_fillet_name];
end

%---return Params and object names in comsol. The names might not be used in
%comsol as the associsated params will be 0.---
rUC = UC;
end