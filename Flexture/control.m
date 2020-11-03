addpath('..\')
%----params defined section-----
baseRec = PhC_Rec(140e-6, 10e-6,118e-9,'Defect');
A = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'A');
B = PhC_Rec(baseRec.length/3, baseRec.width*1.5, baseRec.height,'B');
C = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'C');
A.x = -(A.length + B.length)/2;
C.x = (C.length + B.length)/2;
A.chamfer = abs(B.width - A.width)/2;
A.fillet = A.chamfer/(sqrt(2)*tan(pi/8));
C.chamfer = abs(B.width - C.width)/2;
C.fillet = C.chamfer/(sqrt(2)*tan(pi/8));
defect = UnitCell(A,B,C);
defect.width = max([defect.A.width, defect.B.width, defect.C.width]);
defect.rename('defect');

MS = 3e-6;
UCs = [];
NumofUC = 0;
params = Params(defect, UCs, NumofUC, MS);

simuR = Flexture(params, links)
figure(1)
hold on;
for i = 1:size(simuR.floSol,2)
    plot(simuR.floSol(i).OutOfPlane.k, abs(simuR.floSol(i).OutOfPlane.freq), '*r');
    plot(simuR.floSol(i).InPlane_x.k, abs(simuR.floSol(i).InPlane_x.freq), '*g');
    plot(simuR.floSol(i).InPlane_y.k, abs(simuR.floSol(i).InPlane_y.freq), '*b');
    plot(simuR.floSol(i).tilt.k, abs(simuR.floSol(i).tilt.freq), '*k');
end
legend('OutOfPlane','InPlane-y','tilt')