function [localmodefreq, localmodeEffMass]= Localmode_center_tilt(Links,coords)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref] = Links{1:end};
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
centerline = mphselectbox(model,'geom1', [coords{5}(1)-eps,coords{6}(1)+eps;-eps,eps;-eps,eps;], 'edge');
centerlinedata_disp = mpheval(model,'u*u+v*v+w*w','edim',1,'selection',centerline);

maxpointdata_disp = zeros(size(centerlinedata_disp.d1,1),1);
for i=1:size(centerlinedata_disp.d1,1)
    maxpointdata_disp(i) = max(centerlinedata_disp.d1(i,:));
end
temp = mphint2(model,'solid.rho*(u*u+v*v+w*w)',3);
effectivemass = temp./(maxpointdata_disp)';
[localmodeEffMass, index] = min(effectivemass);
allfreq = mphglobal(model, 'solid.freq');
localmodefreq = allfreq(index);
end