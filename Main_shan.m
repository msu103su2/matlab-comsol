%MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Fri Jul 12 11:18:07 2019                                           IM
%Main program to call to control all the work

[Params, Links] = init_shan();
Params{1}{end}.value = 8;%num of UC
global totallength;
totallength = 5e-3;
DLMin = 100e-6;
DLMax = 100e-6;
DLStepsize = 10e-6;
flag=0;
tic;

%{
...
for DLIte = DLMin : DLStepsize : DLMax
    
    Params{1}{1}.vlaue = DLIte;
    ULMin = Params{1}{1}.value*0.5;
    ULMax = Params{1}{1}.value*2;
    ULStepsize = (ULMax - ULMin)/10;
    
    for ULIte= ULMin : ULStepsize : ULMax
        
        Params{2}{1}.value = ULIte;
        Params{1}{end}.value = floor((totallength-Params{1}{1}.value)/(2*Params{2}{1}.value));
        UrecWMin = 1.01*Params{2}{2}.value;
        UrecWMax = 2*Params{2}{2}.value;
        UrecWStepsize = (UrecWMax - UrecWMin)/10;
        
        for UrecWIte = UrecWMin : UrecWStepsize : UrecWMax
            
            Params{2}{8}.value = UrecWIte;
            Params{2}{9}.value = (Params{2}{8}.value-Params{2}{2}.value)/2;
            Params{2}{10}.value = Params{2}{9}.value*cos(pi/4)/tan(22*pi/180);
            ParamstoSweep = [{[2,7]}];%UrecL
            SweepRanges{1}.min =2*(Params{2}{8}.value-Params{2}{2}.value+Params{2}{10}.value*tan(22.5*pi/180));
            SweepRanges{1}.max = Params{2}{1}.value-2*Params{2}{10}.value*tan(22.5*pi/180);
            Stepsize = [(SweepRanges{1}.max-SweepRanges{1}.min)/10];
            result = SweepParams(ParamstoSweep,SweepRanges,Stepsize,Params, Links);
            temp = repmat([Params{1}{1}.value;Params{2}{1}.value;Params{2}{8}.value],1,size(result.point,2));
            result.point = [temp;result.point];
            result.params=Params;
            if flag==0
                Result = result;
                mphlaunch('Model');
            else
                Result.point = [Result.point,result.point];
                Result.SingleResults = [Result.SingleResults,result.SingleResults];
                Result.Allfreq = [Result.Allfreq,result.Allfreq];
                Result.params = [Result.params, result.params];
            end
            flag = flag + 1;
            progress = flag/(size(DLMin : DLStepsize : DLMax, 2)*...
                size(ULMin : ULStepsize : ULMax, 2)*...
                size(UrecWMin : UrecWStepsize : UrecWMax, 2));
            x = sprintf('Pregress : %.2f/%%',progress*100);
            disp(x);
            toc;
        end
    end
end
...
...
%}

Params{1}{1}.vlaue = 100e-6;
Result = PSO(Params, Links);
save('PSO\data_5mm.mat','Result');
reconstruct(Result.params(Result.searchresult,1:2),Links);