function Alldata = SweepParams(ParamstoSweep, SweepRanges, stepsizes, Params, Links)
import com.comsol.model.*
import com.comsol.model.util.*
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref1] = Links{1:end};
for i = 1:size(ParamstoSweep,1)
    dim{i} = SweepRanges{i}.min : stepsizes(i) : SweepRanges{i}.max;
end

for i = 1:size(ParamstoSweep,1)
    Lengthofdim(i) = int64(size(dim{i},2));
end

for i = 1:size(ParamstoSweep,1)
    division(i) = int64(prod(Lengthofdim(1:i)));
    Alldata.pointname{i} = Params{ParamstoSweep{i}(1)}{ParamstoSweep{i}(2)}.name;
end



counter = int64(0);
while counter < division(end)
    temp = counter;
    for i = 2:size(ParamstoSweep,1)
        [flags(end+1-i),temp] = quorem(temp, division(end-i));
        flags(end+1-i) = flags(end+1-i)+1;
    end
    flags(1) = temp+1;
    counter = counter+1;
    for i = 1:size(ParamstoSweep,1)
        Params{ParamstoSweep{i}(1)}{ParamstoSweep{i}(2)}.value = dim{i}(flags(i));
        Alldata.point(counter) = dim{i}(flags(i));
    end
    Alldata.cooperation(counter) = reconstruct(Params, Links);
    if counter == 1
        a = mphglobal(model,'solid.freq');
    else
        a = [a, mphglobal(model,'solid.freq')];
    end
end
Alldata.Allfreq = a;
end