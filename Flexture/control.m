addpath('..\')
sql = SQL;

%----params defined section-----
Thickness = 118e-9;
L = 70e-6;
W = 5e-6;
widerL = 35e-6;
widerW = 7.5e-6;
higherL = 40e-6;
higherH = Thickness*2;

baseRec = PhC_Rec(L, W, Thickness,'Defect');
A = PhC_Rec((L-widerL)/2, baseRec.width, baseRec.height,'A');
B = PhC_Rec(widerL, widerW, baseRec.height,'B');
C = PhC_Rec((L-widerL)/2, baseRec.width, baseRec.height,'C');
A.x = -(A.length + B.length)/2;
C.x = (C.length + B.length)/2;
A.chamfer = abs(B.width - A.width)/2;
A.fillet = A.chamfer/(sqrt(2)*tan(pi/8));
C.chamfer = abs(B.width - C.width)/2;
C.fillet = C.chamfer/(sqrt(2)*tan(pi/8));
defect = UnitCell(A,B,C);
defect.width = max([defect.A.width, defect.B.width, defect.C.width]);
defect.rename('defect');
defect.formUni = true;

MS = 3e-6;
UCs = [];
NumofUC = 0;
params = Params(defect, UCs, NumofUC, MS);
params.extra.higherL = higherL;
params.extra.higherH = higherH;

simuR = Flexture(params, links);

OOP.k = [];
OOP.f = [];
IPX.k = [];
IPX.f = [];
IPY.k = [];
IPY.f = [];
Tilt.k = [];
Tilt.f = [];
Trash.k = [];
Trash.f = [];
for i = 1:size(simuR.floSol,2)
    OOP.k = [OOP.k,simuR.floSol(i).OutOfPlane.k];
    OOP.f = [OOP.f,abs(simuR.floSol(i).OutOfPlane.freq)];
    IPX.k = [IPX.k,simuR.floSol(i).InPlane_x.k];
    IPX.f = [IPX.f,abs(simuR.floSol(i).InPlane_x.freq)];
    IPY.k = [IPY.k,simuR.floSol(i).InPlane_y.k];
    IPY.f = [IPY.f,abs(simuR.floSol(i).InPlane_y.freq)];
    Tilt.k = [Tilt.k,simuR.floSol(i).tilt.k];
    Tilt.f = [Tilt.f,abs(simuR.floSol(i).tilt.freq)];
    Trash.k = [Trash.k,simuR.floSol(i).trash.k];
    Trash.f = [Trash.f,abs(simuR.floSol(i).trash.freq)];
end


figure(1)
hold on;
MaxKf = max([OOP.k,IPX.k,IPY.k,Tilt.k,Trash.k]);
flapLow = min(Trash.f);
AllFreq = sort([OOP.f,IPX.f,IPY.f,Tilt.f,Trash.f]);
[GapSize, idx] = max(AllFreq(2:end)-AllFreq(1:end-1));
GapLow = AllFreq(idx); GapHi = AllFreq(idx+1);

plot(OOP.k,OOP.f,'*r','DisplayName','OutOfPlane')
plot(IPX.k,IPX.f,'o','DisplayName','InPlaneX','MarkerEdgeColor','k',...
    'MarkerFaceColor',[.49 1 .63])
plot(IPY.k,IPY.f,'*b','DisplayName','InPlaneY')
plot(Tilt.k,Tilt.f,'sk','DisplayName','Tilt')
plot(Trash.k,Trash.f,'o','DisplayName','Falpping', 'MarkerEdgeColor','k','MarkerFaceColor','m')
h = fill([0,MaxKf, MaxKf, 0],[GapLow, GapLow, GapHi, GapHi],[17 17 17]/255,'DisplayName','Gap');
set(h,'facealpha',.5);
axis([0 MaxKf 0 max(AllFreq)])
legend