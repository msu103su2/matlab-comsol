classdef Params < handle
    properties
        defect;
        UCs;
        NumofUC;
        MS;
    end
    methods
        function obj = Params(defect, UCs, NumofUC, MS)
            obj.defect = defect;
            obj.UCs = UCs;
            obj.NumofUC = NumofUC;
            obj.MS = MS;
        end
    end
end