function SingleResult = evaluategeom(Links,localmodefreq, localmodeEffMass)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref1] = Links{1:end};
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
allfreq = mphglobal(model,'solid.freq');
[temp, localmodeindex] = min(abs(allfreq - localmodefreq));
SingleResult.localmodefreq = allfreq(localmodeindex);
SingleResult.QualityFactor = real(localmodefreq)./imag(localmodefreq);
SingleResult.cooperation = 1*SingleResult.QualityFactor/(localmodeEffMass*localmodefreq);
SingleResult.gapsize = allfreq(localmodeindex+1) - allfreq(localmodeindex-1);
end