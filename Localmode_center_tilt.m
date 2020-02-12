function [localmodefreq, localmodeEffMass]= Localmode_center_tilt(Links,coords)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref] = Links{1:end};
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
centerline = mphselectbox(model,'geom1', [coords{5}(1)-eps,coords{6}(1)+eps;-eps,eps;-eps,eps;], 'edge');

lowlinedata_disp = mpheval(model,'w','edim',1,'selection',centerline(1));
coords = lowlinedata_disp.p;
low_dp = lowlinedata_disp.d1;

highlinedata_disp = mphinterp(model,'w','coord',-coords);
high_dp = highlinedata_disp;

absdiff = abs(low_dp+high_dp);
judge = zeros(size(low_dp,1),1);
for rowi = 1:size(low_dp,1)
    
    level = mean(abs(low_dp(rowi,:)))+ mean(abs(high_dp(rowi,:)));
    level = level/200;
    
    temp1 = absdiff(rowi,:);
    temp2 = temp1>level;
    temp1 = temp1(temp2);
    if size(temp1,2)>0
    else
        judge(rowi) = 1;
    end
end

centerlinedata_disp = mpheval(model,'u*u+v*v+w*w','edim',1,'selection',centerline);
centerlinedata_disp.d1 = centerlinedata_disp.d1(find(judge),:);

if isequal(size(centerlinedata_disp.d1,1),0)
    fprintf('No mode identified');
    allfreq = mphglobal(model, 'solid.freq');
    localmodefreq = allfreq(1);
    localmodeEffMass = 1e-6;
else
    maxpointdata_disp = zeros(size(centerlinedata_disp.d1,1),1);
    for i=1:size(centerlinedata_disp.d1,1)
        maxpointdata_disp(i) = max(centerlinedata_disp.d1(i,:));
    end
    temp = mphint2(model,'solid.rho*(u*u+v*v+w*w)',3);
    temp = temp(find(judge));
    effectivemass = temp./(maxpointdata_disp)';
    [localmodeEffMass, index] = min(effectivemass);
    allfreq = mphglobal(model, 'solid.freq');
    allfreq = allfreq(find(judge));
    localmodefreq = allfreq(index);
end
end