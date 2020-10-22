function ComsolP = TMPtoComsolP_heightTest(TMP)
    NumofUC = (size(TMP,2)-1)/2;
    MS = 3e-6;
    lengthscale = 80e-6;
    width = 10e-6;
    heightscale = 118e-6;
    TMP(1,:) = zeros(size(TMP(1,:)))+1;
    TMP(1,[1:2:size(TMP(1,:),2)]) = 2;
    TMP(1,:) = TMP(1,:)*heightscale;
    TMP(2,:) = TMP(2,:)*lengthscale;
    defectL = TMP(2,1);
    %TMP(1,:) = zeros(size(TMP(1,:)))+TMP(1,1);%for test
    UCs = [];
    occuppied = TMP(2,1)/2;
    
    baseRec = PhC_Rec(defectL, width, TMP(1,1),'Defect');
    A = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'A');
    B = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'B');
    C = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'C');
    A.x = -(A.length + B.length)/2;
    C.x = (C.length + B.length)/2;
    defect = UnitCell(A,B,C);
    defect.rename('defect');
    defect.width = B.width;
    defect.formUni = false;
    
    for i = 1 : NumofUC
        B = PhC_Rec(TMP(2,2*i), width, TMP(1,2*i), 'B');
        
        A = PhC_Rec(TMP(2,2*i-1)-occuppied, width, TMP(1,2*i-1), 'A');
        A.chamfer = abs(B.width - A.width)/2;
        A.fillet = A.chamfer/(sqrt(2)*tan(pi/8));
        
        C = PhC_Rec(TMP(2,2*i+1)/2, width, TMP(1,2*i+1), 'C');
        C.chamfer = abs(B.width - C.width)/2;
        C.fillet = C.chamfer/(sqrt(2)*tan(pi/8));
        
        occuppied = C.length;
        
        A.x = -(A.length + B.length)/2;
        C.x = (C.length + B.length)/2;
        
        copyA = PhC_Rec(1, 1, 1, 'A');
        copyB = PhC_Rec(1, 1, 1, 'B');
        copyC = PhC_Rec(1, 1, 1, 'C');
        copyA.copyfrom(C);
        copyB.copyfrom(B);
        copyC.copyfrom(A);
        copyA.x = -(copyA.length + copyB.length)/2;
        copyC.x = (copyC.length + copyB.length)/2;

        UCs = [UCs,UnitCell(A,B,C),UnitCell(copyA,copyB,copyC)];
        if size(UCs,2) == 2
            UCs(end).moveTo(-(defect.length+UCs(end).length)/2+defect.x, 0, 0);
            UCs(end-1).moveTo((defect.length+UCs(end-1).length)/2+defect.x, 0, 0);
            UCs(end-1).rename(['R',num2str(i)]);
            UCs(end).rename(['L',num2str(i)]);
        else
            UCs(end).moveTo(-(UCs(end-2).length+UCs(end).length)/2+UCs(end-2).x, 0, 0);
            UCs(end-1).moveTo((UCs(end-3).length+UCs(end-1).length)/2+UCs(end-3).x, 0, 0);
            UCs(end-1).rename(['R',num2str(i)]);
            UCs(end).rename(['L',num2str(i)]);
        end
        UCs(end-1).width = UCs(end-1).B.width;
        UCs(end).width = UCs(end).B.width;
        UCs(end-1).formUni = false;
        UCs(end).formUni = false;
    end
    
    ComsolP = Params(defect, UCs, NumofUC, MS);
end