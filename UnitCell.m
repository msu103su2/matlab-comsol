classdef UnitCell < handle
    properties
        A;
        B;
        C;
        x;
        y;
        z;
        length;
        width
        NamePrefix;
        constructedNameList;
        formUni;
    end
    methods
        function obj = UnitCell(partA, partB, partC)
            obj.A = partA;
            obj.B = partB;
            obj.C = partC;
            obj.length = partA.length + partB.length + partC.length;
            obj.x = ((partA.x-partA.length/2)+(partC.x+partC.length/2))/2;
            obj.y = partB.y;
            obj.z = partB.z;
            obj.NamePrefix = '';
            obj.formUni = true;%if not form union, charmfer and fillet will not be constructed due to complicated indexs
        end
        
        function moveBy(obj, delta_x, delta_y, delta_z)
            obj.x = obj.x + delta_x;
            obj.y = obj.y + delta_y;
            obj.z = obj.z + delta_z;
            obj.A.x = obj.A.x + delta_x;
            obj.A.y = obj.A.y + delta_y;
            obj.A.z = obj.A.z + delta_z;
            obj.B.x = obj.B.x + delta_x;
            obj.B.y = obj.B.y + delta_y;
            obj.B.z = obj.B.z + delta_z;
            obj.C.x = obj.C.x + delta_x;
            obj.C.y = obj.C.y + delta_y;
            obj.C.z = obj.C.z + delta_z;
        end
        
        function moveTo(obj, x, y, z)
            
            
            dx = obj.A.x - obj.x;
            dy = obj.A.y - obj.y;
            dz = obj.A.z - obj.z;
            obj.A.x = dx + x;
            obj.A.y = dy + y;
            obj.A.z = dz + z;
            
            dx = obj.C.x - obj.x;
            dy = obj.C.y - obj.y;
            dz = obj.C.z - obj.z;
            obj.C.x = dx + x;
            obj.C.y = dy + y;
            obj.C.z = dz + z;
            
            dx = obj.B.x - obj.x;
            dy = obj.B.y - obj.y;
            dz = obj.B.z - obj.z;
            obj.B.x = dx + x;
            obj.B.y = dy + y;
            obj.B.z = dz + z;
            
            obj.x = x;
            obj.y = y;
            obj.z = z;
        end
        
        function rename(obj, NamePrefix)
            obj.NamePrefix = NamePrefix;
            obj.A.changeNamePrefix(obj.NamePrefix);
            obj.B.changeNamePrefix(obj.NamePrefix);
            obj.C.changeNamePrefix(obj.NamePrefix);
        end
        
    end
end