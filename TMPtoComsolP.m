function ComsolP = TMPtoComsolP(TMP)
    NumofUC = (size(TMP,2)-1)/2;
    MS = 3e-6;
    lengthscale = 80e-6;
    widthscale = 10e-6;
    height = 118e-9;
    TMP(1,:) = TMP(1,:)*widthscale;
    TMP(2,:) = TMP(2,:)*lengthscale;
    defectL = TMP(2,1);
    
    UCs = [];
    occuppied = TMP(2,1)/2;
    
    baseRec = PhC_Rec(defectL, TMP(1,1), height,'Defect');
    A = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'A');
    B = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'B');
    C = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'C');
    A.x = -(A.length + B.length)/2;
    C.x = (C.length + B.length)/2;
    defect = UnitCell(A,B,C);
    defect.rename('defect');
    defect.width = B.width;
    
    for i = 1 : NumofUC
        B = PhC_Rec(TMP(2,2*i), TMP(1,2*i), height, 'B');
        
        A = PhC_Rec(TMP(2,2*i-1)-occuppied, TMP(1,2*i-1), height, 'A');
        A.chamfer = abs(B.width - A.width)/2;
        A.fillet = A.chamfer/(sqrt(2)*tan(pi/8));
        
        if (i < NumofUC)
            if (TMP(1,2*(i+1)) > TMP(1,2*i+1))
                tobeoccuppied = abs(TMP(1,2*(i+1)) - TMP(1,2*i+1))/(2*sqrt(2));
            else
                tobeoccuppied = (abs(TMP(1,2*(i+1)) - TMP(1,2*i+1))/2)*(1+1/sqrt(2));
            end
        else
            tobeoccuppied = 0;
        end
        
        C = PhC_Rec(TMP(2,2*i+1)-tobeoccuppied, TMP(1,2*i+1), height, 'C');
        C.chamfer = abs(B.width - C.width)/2;
        C.fillet = C.chamfer/(sqrt(2)*tan(pi/8));
        if (B.width > C.width)
            temp = C.chamfer/sqrt(2);
        else
            temp = C.chamfer*(1+1/sqrt(2));
        end
        
        if (i < NumofUC)
            C.length = (temp + C.length)/2;
        end
        
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
    end
    
    ComsolP = Params(defect, UCs, NumofUC, MS);
end