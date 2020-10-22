classdef Params < handle
    properties
        defect;
        UCs;
        NumofUC;
        MS;
        minW;
        totalLength;
        stressTensor;
    end
    methods
        function obj = Params(defect, UCs, NumofUC, MS)
            obj.defect = defect;
            obj.UCs = UCs;
            obj.NumofUC = NumofUC;
            obj.MS = MS;
            obj.stressTensor = [1e9,0,0;0,1e9,0;0,0,0];
        end
        
        function r = getMinWidth(obj)
            r = min([obj.defect.A.width, obj.defect.B.width, obj.defect.C.width]);
            for i = 1:2*obj.NumofUC
                r = min([r, obj.UCs(i).A.width, obj.UCs(i).B.width, obj.UCs(i).C.width]);
            end
            obj.minW = r;
        end
        
        function r = getLength(obj)
            if obj.NumofUC == 0
                r = obj.defect.length;
                obj.totalLength = r;
            else
                r = obj.UCs(obj.NumofUC*2-1).C.x + obj.UCs(obj.NumofUC*2-1).C.length/2 - ...
                    obj.UCs(obj.NumofUC*2).A.x + obj.UCs(obj.NumofUC*2).A.length/2;
                obj.totalLength = r;
            end
        end
    end
end