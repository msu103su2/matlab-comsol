%MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Fri Jul 12 11:18:07 2019                                           IM
%Main program to call to control all the work

%call creatreModel.m with a sucess as return signal
%modify parameters and reconstruct, fetch result and give Search an
%parameter space and search target (a general search problem), with
%result returned

[Params, Links] = init_shan();
Params{1}{end}.value = 2;
result = SearchParams(Params, Links);