%MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Fri Jul 12 11:18:07 2019                                           IM
%Main program to call to control all the work

%call creatreModel.m with a sucess as return signal
%modify parameters and reconstruct, fetch result and give Search an
%parameter space and search target (a general search problem), with
%result returned

[Params, Links] = init_shan();
Params{1}{end}.value = 8;
ParamstoSweep = {[1,1]};
SweepRanges{1}.min = 50e-6;
SweepRanges{1}.max = 50e-5;
Stepsize = 5e-6;
result = SweepParams(ParamstoSweep,SweepRanges,Stepsize,Params, Links);

plotgraph = figure;
plot(result.point,result.Allfreq);
c=clock;
saveas(plotgraph,['snapshot\test', num2str(c(4)), num2str(c(5)), num2str(round(c(6))), '.png']);
close(plotgraph);
save('snapshot\data.mat','result');