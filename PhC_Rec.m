classdef PhC_Rec < handle
    properties
        length;
        width;
        height;
        fillet;
        chamfer;
        x;
        y;
        z;
        comsol_Rec_name;
        comsol_fillet_name;
        comsol_chamfer_name;
        
        comsol_Rec_barename;
        comsol_fillet_barename;
        comsol_chamfer_barename;
    end
    
    methods
        function obj = PhC_Rec(length, width, height, seedName)
            obj.length = length;
            obj.width = width;
            obj.height = height;
            obj.fillet = 0;
            obj.chamfer = 0;
            obj.x = 0;
            obj.y = 0;
            obj.z = 0;
            obj.comsol_Rec_name = ['rec' seedName];
            obj.comsol_chamfer_name = ['charm' seedName];
            obj.comsol_fillet_name = ['fil' seedName];
            obj.comsol_Rec_barename = obj.comsol_Rec_name;
            obj.comsol_chamfer_barename = obj.comsol_chamfer_name;
            obj.comsol_fillet_barename = obj.comsol_fillet_name;
        end
        
        function changeNamePrefix(obj, NamePrefix)
            obj.comsol_Rec_name = [NamePrefix obj.comsol_Rec_barename];
            obj.comsol_chamfer_name = [NamePrefix obj.comsol_chamfer_barename];
            obj.comsol_fillet_name = [NamePrefix obj.comsol_fillet_barename];
        end
        
        function copyfrom(obj, other)
            obj.length = other.length;
            obj.width = other.width;
            obj.height = other.height;
            obj.fillet = other.fillet;
            obj.chamfer = other.chamfer;
            obj.x = other.x;
            obj.y = other.y;
            obj.z = other.z;
        end
    end
end