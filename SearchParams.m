%MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Fri Jul 12 11:16:55 2019                                                 IM
%reserved for searching algorithms
function SearchResult = SearchParams(Params, Links)
oldParams = Params;
%try simulated anneling
Ti = 300;
Tf = 2;
r = 0.9;
T = Ti;
oldmin = recondtruct(oldParams, Links);
while T > Tf
   newParams = GenerateNewParams(oldParamsm);
   newmin = recondtruct(newParams, Links);
   delta = newmin - oldmin;
   if delta < 0 || exp(-delta/T) > rand
        oldmin = newmin;
        oldParams = newParams;
   end
   T = r*T;
end
SearchResult = oldParams;
end

function newParams = GenerateNewParams(oldParams)
DefectParamsIndicies = [1,2,9];
UCParamsIndicies = [1,2,7,8];
totaldimension = size(DefectParamsIndicies,2) + size(UCParamsIndicies,2);
seed = randi([1, totaldimension]);
%DefectParams = {DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC};
DefectParams = oldParams{1};
%UCParams = {UL UW UH Ux Uy Uz UrecL UrecW ChamferR FilletR};
UCParams = oldParams{2};
newParams = oldParams;
SearchRange = {[0.1*DefectParams{1}.value, 10*DefectParams{1}.value],...
    [0.2*DefectParams{2}.value, 2*DefectParams{2}.value],...
    [5,20],...
    [0.1*UCParams{1}.value, 10*UCParams{1}.value],...
    [0.2*UCParams{2}.value, 2*UCParams{2}.value],...
    [0.1*UCParams{7}.value, 10*UCParams{7}.value],...
    [0.2*UCParams{8}.value, 2*UCParams{8}.value]};
if seed > size(DefectParamsIndicies,2)
    smallseed = seed - size(DefectParamsIndicies,2);
    newParams{2}{UCParamsIndicies(smallseed)}.value = ...
        rand*(SearchRange{seed}(2) - SearchRange{seed}(1))+SearchRange{seed}(1);
else
    smallseed = seed;
    newParams{1}{DefectParamsIndicies(smallseed)}.value = ...
        rand*(SearchRange{seed}(2) - SearchRange{seed}(1))+SearchRange{seed}(1);
end
newParams{1}(9).value = round(newParams{1}(9).value);
end