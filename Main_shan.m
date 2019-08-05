%MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Fri Jul 12 11:18:07 2019                                           IM
%Main program to call to control all the work

%call creatreModel.m with a sucess as return signal
%modify parameters and reconstruct, fetch result and give Search an
%parameter space and search target (a general search problem), with
%result returned

[Params, Links] = init_shan();
Params{1}{end}.value = 8;
ParamstoSweep = [{[2,1]};{[2,8]}];
SweepRanges{1}.min = 150e-6;
SweepRanges{1}.max = 300e-6;
SweepRanges{2}.min = 11e-6;
SweepRanges{2}.max = 21e-6;
Stepsize = [5e-6,1e-6];
result = SweepParams(ParamstoSweep,SweepRanges,Stepsize,Params, Links);

plotgraph = figure;
plot(result.point,result.Allfreq);
c=clock;
saveas(plotgraph,['snapshot4\test', num2str(c(4)), num2str(c(5)), num2str(round(c(6))), '.png']);
close(plotgraph);
save('snapshot4\data.mat','result');