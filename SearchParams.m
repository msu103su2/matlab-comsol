%MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Fri Jul 12 11:16:55 2019                                                 IM
%reserved for searching algorithms
function SearchResult = SearchParams(Params, Links)
import com.comsol.model.*
import com.comsol.model.util.*
model = Links{1};
oldParams = Params;
%try simulated anneling
Ti = 10;
Tf = 1e-2;
r = 0.97;
T = Ti;
Alldata.SingleResults = [reconstruct(oldParams, Links)];
Alldata.params = [oldParams];
Alldata.Allfreq = [mphglobal(model,'solid.freq')];
counter = 2;
flag = 1;
tic;
totaliterations = round(log(Ti/Tf)/log(1/r))+2;
max = Alldata.SingleResults(1).cooperation;
while T > Tf
   newParams = GenerateNewParams2(oldParams, T, Tf);
   Alldata.params = [Alldata.params; newParams];
   Alldata.SingleResults = [Alldata.SingleResults,reconstruct(newParams, Links)];
   Alldata.Allfreq = [Alldata.Allfreq,mphglobal(model,'solid.freq')];
   new = Alldata.SingleResults(counter).cooperation;
   delta = (abs(real(new)) - abs(real(max)))/1e12;
   x = sprintf('Pregress : %.2f/%% (%i/%i), max cooperation = %e, new cooperation = %e' ,counter/totaliterations*100,counter,totaliterations, max, new);
   disp(x);
   toc;
          exp(delta/T)
   if delta > 0 || exp(delta/T) > rand
        flag = counter;
        max = new;
        oldParams = newParams;
   end
   T = r*T;
   counter = counter+1;
end
Alldata.searchresult = flag;
SearchResult = Alldata;
end

function newParams = GenerateNewParams(oldParams)
DefectParamsIndicies = [1,9];
UCParamsIndicies = [7,8];
totaldimension = size(DefectParamsIndicies,2) + size(UCParamsIndicies,2);
seed = randi([1, totaldimension]);
%DefectParams = {DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC};
DefectParams = oldParams{1};
%UCParams = {UL UW UH Ux Uy Uz UrecL UrecW ChamferR FilletR};
UCParams = oldParams{2};
newParams = oldParams;
SearchRange = {[0.2*DefectParams{1}.value,2*DefectParams{1}.value],...
    [8,14],[0.1*UCParams{7}.value, UCParams{1}.value],[UCParams{2}.value, UCParams{8}.value]};
if seed > size(DefectParamsIndicies,2)
    smallseed = seed - size(DefectParamsIndicies,2);
    newParams{2}{UCParamsIndicies(smallseed)}.value = ...
        rand*(SearchRange{seed}(2) - SearchRange{seed}(1))+SearchRange{seed}(1);
else
    smallseed = seed;
    newParams{1}{DefectParamsIndicies(smallseed)}.value = ...
        rand*(SearchRange{seed}(2) - SearchRange{seed}(1))+SearchRange{seed}(1);
end
newParams{1}{9}.value = round(newParams{1}{9}.value);
end

function newParams = GenerateNewParams2(oldParams, T, Tf)
newParams = oldParams;
global totallength;
rangefactor = (1+log(T/Tf)*7);

outofrange = 1;

while outofrange == 1
DLMin = 50e-6;
DLMax = 200e-6;
DLrange = rangefactor*(DLMax-DLMin)/5;
%newParams{1}{1}.value = rand*DLrange+oldParams{1}{1}.value;
newParams{1}{1}.value = normrnd(oldParams{1}{1}.value, DLrange/2);
if newParams{1}{1}.value>=DLMin && newParams{1}{1}.value<=DLMax
    outofrange = 0;
end
end

outofrange = 1;
while outofrange == 1
ULMin = oldParams{1}{1}.value*0.5;
ULMax = oldParams{1}{1}.value*2;
ULrange = rangefactor*(ULMax-ULMin)/5;
%newParams{2}{1}.value = rand*ULrange+oldParams{2}{1}.value;
newParams{2}{1}.value = normrnd(oldParams{2}{1}.value, ULrange/2);
if newParams{2}{1}.value>=ULMin && newParams{2}{1}.value<=ULMax
    outofrange = 0;
end
end
newParams{1}{end}.value = floor((totallength-newParams{1}{1}.value)/(2*newParams{2}{1}.value));

outofrange = 1;
while outofrange == 1
UrecWMin = 1.01*newParams{2}{2}.value;
UrecWMax = 2*newParams{2}{2}.value;
UrecWrange = rangefactor*(UrecWMax - UrecWMin)/5;
%newParams{2}{8}.value = rand*UrecWrange+oldParams{2}{8}.value;
newParams{2}{8}.value = normrnd(oldParams{2}{8}.value, UrecWrange/2);
if newParams{2}{8}.value>=UrecWMin && newParams{2}{8}.value<=UrecWMax
    outofrange = 0;
end
end
newParams{2}{9}.value = (newParams{2}{8}.value-newParams{2}{2}.value)/2;
newParams{2}{10}.value = newParams{2}{9}.value*cos(pi/4)/tan(22.5*pi/180);

outofrange = 1;
while outofrange == 1
UrecLMin = 2*(newParams{2}{8}.value-newParams{2}{2}.value+newParams{2}{10}.value*tan(22.5*pi/180));
UrecLMax = newParams{2}{1}.value-2*newParams{2}{10}.value*tan(22.5*pi/180)-2*newParams{1}{8}.value;
UrecLrange = rangefactor*(UrecLMax - UrecLMin)/5;
%newParams{2}{7}.value = rand*UrecLrange+oldParams{2}{7}.value;
newParams{2}{7}.value = normrnd(oldParams{2}{7}.value, UrecLrange/2);
if newParams{2}{7}.value>=UrecLMin && newParams{2}{7}.value<=UrecLMax
    outofrange = 0;
end
end

end