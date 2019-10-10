function SingleResult = evaluategeom(Links, Params, localmodefreq, localmodeEffMass)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref] = Links{1:end};
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
allfreq = mphglobal(model,'solid.freq');
[temp, localmodeindex] = min(abs(allfreq - localmodefreq));
SingleResult.localmodefreq = allfreq(localmodeindex);
SingleResult.QualityFactor = CalculateQ(Links, Params,localmodeindex);
SingleResult.cooperation = 1*SingleResult.QualityFactor/(localmodeEffMass*localmodefreq);
if localmodeindex == 1 || localmodeindex == size(allfreq,1)
    SingleResult.gapsize = 0;
else
    SingleResult.gapsize = allfreq(localmodeindex+1) - allfreq(localmodeindex-1);
end
end

function Q = CalculateQ(Links, Params, localmodeindex)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref] = Links{1:end};
h =Params{1}{3}.value;
Q0=6900*(h/1e-7);
E =250e9;
L = 2*Params{2}{1}.value*Params{1}{9}.value+Params{1}{1}.value;
centerline = mphselectbox(model,'geom1', [-L/2-eps,L/2+eps;-eps,eps;-eps,eps;], 'edge');
expr = {'wXX','wX'};
centerlinedata = mpheval(model,expr,'edim',1,'selection',centerline,'dataset','dset1','solnum',localmodeindex);
centerlinedata_sigma = mpheval(model,'solid.sx','edim',1,'selection',centerline,'dataset','dset2');
nodes_x1 = centerlinedata.p(1,:);
nodes_x2 = centerlinedata_sigma.p(1,:);

if (size(nodes_x1,2)<size(nodes_x2,2))
    nodes_x = nodes_x1;
    nodes_lo = nodes_x2;
else
    nodes_x = nodes_x2;
    nodes_lo = nodes_x1;
end

[nodes_x,order] = sort(nodes_x);
if isequal(nodes_x,nodes_lo(order))
    wXX = centerlinedata.d1(:,order);
    wX = centerlinedata.d2(:,order);
    sigma = centerlinedata_sigma.d1(order);
end

for i = 1:size(wXX,1)
    Q(i) = Q0*(12/(E*h*h))*trapz(nodes_x,wX(i,:).*wX(i,:))/trapz(nodes_x,wXX(i,:).*wXX(i,:)./sigma);
end
end