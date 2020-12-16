[~,i] = max([Alldata.SingleResults.QualityFactor]);
params = Alldata.params(i,:);
params{1}{2}.value*1e6
fprintf('%s:%3.2f\n',params{1}{1}.name,params{1}{1}.value*1e6)
fprintf('%s:%3.2f\n',params{2}{1}.name,params{2}{1}.value*1e6)
fprintf('%s:%3.2f\n',params{2}{8}.name,params{2}{8}.value*1e6)
fprintf('%s:%3.2f\n',params{2}{7}.name,params{2}{7}.value*1e6)

