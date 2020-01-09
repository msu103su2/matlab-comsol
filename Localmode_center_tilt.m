function [localmodefreq, localmodeEffMass]= Localmode_center_tilt(Links,coords)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref] = Links{1:end};
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
centerline = mphselectbox(model,'geom1', [coords{5}(1),coords{6}(1);coords{5}(2),coords{6}(2);-eps,eps;], 'edge');
centerlinedata_disp = mpheval(model,'u*u+v*v+w*w','edim',0,'selection',centerline);
maxpointdata_disp = max(centerlinedata_disp.d1);
temp = mphint2(model,'solid.rho*(u*u+v*v+w*w)',3);
effectivemass = temp./(maxpointdata_disp.d1)';
[localmodeEffMass, index] = min(effectivemass);
allfreq = mphglobal(model, 'solid.freq');
localmodefreq = allfreq(index);
end