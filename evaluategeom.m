function result = evaluategeom(Links,localmodefreq)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid] = Links{1:end};
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
allfreq = mphglobal(model,'solid.freq');
[temp, localmodeindex] = min(abs(allfreq - localmodefreq));
result = 1/(allfreq(localmodeindex+1)-allfreq(localmodeindex-1));
end