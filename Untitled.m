TMP = SearchResult.p;
params = TMPtoComsolP(TMP);
simuResult = reconstruct(params,links);
stress = [];
for  i = 1:params.NumofUC
    x = params.UCs(2*i-1).A.x;
    y = params.UCs(2*i-1).A.y;
    z = params.UCs(2*i-1).A.z;
    data = mphinterp(links.model,'solid.sp1','coord',[x;y;z],'dataset','dset2');
    stress = [stress, data(1,1)];
    x = params.UCs(2*i-1).B.x;
    y = params.UCs(2*i-1).B.y;
    z = params.UCs(2*i-1).B.z;
    data = mphinterp(links.model,'solid.sp1','coord',[x;y;z],'dataset','dset2');
    stress = [stress, data(1,1)];
end
x = params.UCs(2*params.NumofUC-1).C.x;
y = params.UCs(2*params.NumofUC-1).C.y;
z = params.UCs(2*params.NumofUC-1).C.z;
data = mphinterp(links.model,'solid.sp1','coord',[x;y;z],'dataset','dset2');
stress = [stress, data(1,1)];



lengthscale = 80e-6;
widthscale = 10e-6;
height = 118e-9;
TMP(1,:) = TMP(1,:)*widthscale;
TMP(2,:) = TMP(2,:)*lengthscale;
NumofUC = 0;
MS = 3e-6;
UCs = [];
simuSx = [];

for i = 1 : size(TMP,2)
    baseRec = PhC_Rec(TMP(2,i), TMP(1,i), height,'Defect');
    A = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'A');
    B = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'B');
    C = PhC_Rec(baseRec.length/3, baseRec.width, baseRec.height,'C');
    A.x = -(A.length + B.length)/2;
    C.x = (C.length + B.length)/2;
    defect = UnitCell(A,B,C);
    defect.rename('defect');
    defect.width = B.width;

    ComsolP = Params(defect, UCs, NumofUC, MS);
    ComsolP.stressTensor = (stress(i)/0.78)*[1,0,0;0,1,0;0,0,0];
    simuResult = reconstruct(ComsolP, links);
    fit = polyfit(simuResult.modes.OutOfPlane.k(1:5), 2*pi*simuResult.modes.OutOfPlane.freq(1:5),1);
    c(i)=fit(1);
    simuSx(i) = mphinterp(links.model,'solid.sp1','coord',[0;0;0],'dataset','dset2');
end
plot([1:11], TMP(1,:)/TMP(1,1), [1:11], simuSx(1)./simuSx, '*');