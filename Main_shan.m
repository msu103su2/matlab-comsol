%MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Fri Jul 12 11:18:07 2019                                           IM
%Main program to call to control all the work

%call creatreModel.m with a sucess as return signal
%modify parameters and reconstruct, fetch result and give Search an
%parameter space and search target (a general search problem), with
%result returned

[Params, Links] = init_shan();
Params{1}{end}.value = 8;
result = SearchParams(Params, Links);

SingleRunResult = reconstruct(result, Links);
result = {result{1}{1:end}, result{2}{1:end}};
for i = 1:size(result,2)
    disp([result{i}.name,' : ', num2str(result{i}.value)]);
end
