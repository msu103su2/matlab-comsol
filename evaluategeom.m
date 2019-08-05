function cooperation = evaluategeom(Links,localmodefreq, localmodeEffMass)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref1] = Links{1:end};
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
allfreq = mphglobal(model,'solid.freq');
[temp, localmodeindex] = min(abs(allfreq - localmodefreq));
localmodefreq = allfreq(localmodeindex);
QualityFactor = real(localmodefreq)./imag(localmodefreq);
cooperation = 1*QualityFactor/(localmodeEffMass*localmodefreq);
end