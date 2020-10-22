function params = test(DeviceNumber)
sql = SQL;
oldparams = sql.SelectDevice('000',21,DeviceNumber);
MS = oldparams{1}{8}.value;
NumofUC = oldparams{1}{9}.value;

baseRec = PhC_Rec(oldparams{1}{1}.value, oldparams{1}{2}.value,...
    oldparams{1}{3}.value,'Defect');
A = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'A');
B = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'B');
C = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'C');
A.x = -(A.length + B.length)/2;
C.x = (C.length + B.length)/2;
defect = UnitCell(A,B,C);
defect.width = defect.B.width;

UCs = []; %increase size in a loop, to be optimize if necessary
baseRec = PhC_Rec(oldparams{2}{1}.value-oldparams{2}{7}.value, ...
    oldparams{2}{2}.value,oldparams{2}{3}.value,'Defect');
for i = 1 : 2*NumofUC
    comsol_index = ceil(i/2); 
    
    A = PhC_Rec(baseRec.length/2, baseRec.width, baseRec.height,'A');
    B = PhC_Rec(oldparams{2}{7}.value, oldparams{2}{8}.value, baseRec.height,'B');
    C = PhC_Rec(baseRec.length/2, baseRec.width, baseRec.height,'C');
    A.x = -(A.length + B.length)/2;
    C.x = (C.length + B.length)/2;
    A.fillet = oldparams{2}{10}.value;
    A.chamfer = oldparams{2}{9}.value;
    C.fillet = oldparams{2}{10}.value;
    C.chamfer = oldparams{2}{9}.value;
    UC = UnitCell(A,B,C);

    UCs = [UCs, UC];
    if rem(i, 2) == 0
        UCs(i).moveTo(defect.x - defect.length/2 - UCs(i).length * (comsol_index-0.5), 0, 0);
        UCs(i).rename(['L',num2str(comsol_index)]);
    else
        UCs(i).moveTo(defect.x + defect.length/2 + UCs(i).length * (comsol_index-0.5), 0, 0);
        UCs(i).rename(['R',num2str(comsol_index)]);
    end
end

params = Params(defect, UCs, NumofUC, MS);
end