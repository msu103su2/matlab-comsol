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
        constrctedNameList;
    end
    methods
        function obj = UnitCell(partA, partB, partC)
            obj.A = partA;
            obj.B = partB;
            obj.C = partC;
            obj.length = partA.length + partB.length + partC.length;
            obj.x = partB.x;
            obj.y = partB.y;
            obj.z = partB.z;
            obj.NamePrefix = '';
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
            obj.x = x;
            obj.y = y;
            obj.z = z;
            
            dx = obj.A.x - obj.B.x;
            dy = obj.A.y - obj.B.y;
            dz = obj.A.z - obj.B.z;
            obj.A.x = dx + x;
            obj.A.y = dy + y;
            obj.A.z = dz + z;
            
            dx = obj.C.x - obj.B.x;
            dy = obj.C.y - obj.B.y;
            dz = obj.C.z - obj.B.z;
            obj.C.x = dx + x;
            obj.C.y = dy + y;
            obj.C.z = dz + z;
            
            obj.B.x = x;
            obj.B.y = y;
            obj.B.z = z;
        end
        
        function rename(obj, NamePrefix)
            obj.NamePrefix = NamePrefix;
            obj.A.changeNamePrefix(obj.NamePrefix);
            obj.B.changeNamePrefix(obj.NamePrefix);
            obj.C.changeNamePrefix(obj.NamePrefix);
        end
        
    end
end