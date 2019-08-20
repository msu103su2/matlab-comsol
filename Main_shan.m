%MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Fri Jul 12 11:18:07 2019                                           IM
%Main program to call to control all the work

[Params, Links] = init_shan();
Params{1}{end}.value = 8;%num of UC
totallength = 2e-3;
RelativeVarianceInL = 0.05;
min = 100e-6;
max = 200e-6;
step = 50e-6;
flag=0;

for DLIte = min : step : max
    Params{1}{1}.vlaue = DLIte;
    ULMin = (totallength*(1-RelativeVarianceInL)-Params{1}{1}.vlaue)/Params{1}{end}.value;
    ULMax = (totallength*(1+RelativeVarianceInL)-Params{1}{1}.vlaue)/Params{1}{end}.value;
    ULNumofSteps = 2;
    ULStepsize = (ULMax - ULMin)/ULNumofSteps;
    for ULIte= ULMin : ULStepsize : ULMax
        Params{2}{1}.value = ULIte;
        for UrecWIte= 1.01*Params{2}{2}.value : 0.5*Params{2}{2}.value : 2*Params{2}{2}.value
            Params{2}{8}.value = UrecWIte;
            Params{2}{9}.value = Params{2}{8}.value-Params{2}{2}.value;
            Params{2}{10}.value = Params{2}{9}.value*cos(pi/4)/tan(22.5*pi/180);
            ParamstoSweep = [{[2,7]}];%UrecL
            SweepRanges{1}.min =2*(Params{2}{8}.value-Params{2}{2}.value+Params{2}{10}.value*tan(22.5*pi/180));
            SweepRanges{1}.max = Params{2}{1}.value-2*Params{2}{10}.value*tan(22.5*pi/180);
            NumOfSteps(1)=2;
            Stepsize = [(SweepRanges{1}.max-SweepRanges{1}.min)/NumOfSteps(1)];
            result = SweepParams(ParamstoSweep,SweepRanges,Stepsize,Params, Links);
            temp = repmat([Params{1}{1}.value;Params{2}{1}.value;Params{2}{8}.value],1,size(result.point,2));
            result.point = [temp;result.point];
            if flag==0
                Result = result;
            else
                Result.point = [Result.point,result.point];
                Result.SingleResults = [Result.SingleResults,result.SingleResults];
                Result.Allfreq = [Result.Allfreq,result.Allfreq];
            end
            flag = 1;
        end
    end
end

save('snapshot4\data.mat','result');