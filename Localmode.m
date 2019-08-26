function [localmodefreq, localmodeEffMass]= Localmode(Links,coords)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref] = Links{1:end};
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
centerpoint = mphselectbox(model,'geom1', [-eps,eps;-eps,eps;-eps,eps;], 'point');
centerpointdata_disp = mpheval(model,'u*u+v*v+w*w','edim',0,'selection',centerpoint);
temp = mphint2(model,'solid.rho*(u*u+v*v+w*w)',3);
effectivemass = temp./(centerpointdata_disp.d1)';
[localmodeEffMass, index] = min(effectivemass);
allfreq = mphglobal(model, 'solid.freq');
localmodefreq = allfreq(index);
end