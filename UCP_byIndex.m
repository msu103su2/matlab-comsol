function UnitCellParam = UCP_byIndex(i, AllElementParams, direction)
%assumed BaseParam: ucindex, Length, width, height, x, y, z
BaseParam = AllElementParams(1,:);
LastUC = AllElementParams(i-1,:);
UnitCellParam = BaseParam;
UnitCellParam(1).value = i;
UnitCellParam(3).value = LastUC(3).value*1.1;
UnitCellParam(2).value = LastUC(2).value*1.1;
if direction == 1
    UnitCellParam(5).value = LastUC(5).value + ...
    (UnitCellParam(2).value + LastUC(2).value)/2;
else
    UnitCellParam(5).value = LastUC(5).value - ...
    (UnitCellParam(2).value + LastUC(2).value)/2;
end
end