load('Z:\data\optical lever project\test\SearchResult');
params = TMPtoComsolP(SearchResult.p);
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
stressNormalized = pi*0.5*sqrt(stress(1))./sqrt(stress);
plot([1:11],stressNormalized, '*', [1:11], SearchResult.p(1,:));