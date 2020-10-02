function SingleResult = evaluategeom(links, params, localmodefreq, localmodeEffMass, leftEndCoord, rightEndCoord)
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
allfreq = mphglobal(links.model,'solid.freq');
[temp, localmodeindex] = min(abs(allfreq - localmodefreq));
SingleResult.localmodefreq = allfreq(localmodeindex);
SingleResult.QualityFactor = CalculateQ(links, params,localmodeindex, leftEndCoord, rightEndCoord);
SingleResult.cooperation = 1*SingleResult.QualityFactor/(localmodeEffMass*localmodefreq);
SingleResult.meritfunction = -localmodeEffMass;
if localmodeindex == 1 || localmodeindex == size(allfreq,1)
    SingleResult.gapsize = 0;
else
    SingleResult.gapsize = allfreq(localmodeindex+1) - allfreq(localmodeindex-1);
end
end

function Q = CalculateQ(links, params, localmodeindex, leftEndCoord, rightEndCoord)
h =params{1}{3}.value;
Q0=6900*(h/1e-7);
E =250e9;
centerline = mphselectbox(links.model,'geom1', [leftEndCoord(1)-eps,rightEndCoord(1)+eps;-eps,eps;-eps,eps;], 'edge');
expr = {'wXX','wX'};
centerlinedata = mpheval(model,expr,'edim',1,'selection',centerline,'dataset','dset1','solnum',localmodeindex);
centerlinedata_sigma = mpheval(model,'solid.sx','edim',1,'selection',centerline,'dataset','dset2');
nodes_x1 = centerlinedata.p(1,:);
nodes_x2 = centerlinedata_sigma.p(1,:);

index_x1 = [];
index_x2 = [];
for i = [1:size(nodes_x1,2)]
    temp = find(nodes_x2 == nodes_x1(i));
    if(not(isempty(temp)) && isempty(find(nodes_x1(index_x1) == nodes_x1(i))))
        index_x1 = [index_x1, i];
        index_x2 = [index_x2, temp(1)];
    end
end

if isequal(nodes_x1(index_x1),nodes_x2(index_x2))
    wXX = centerlinedata.d1(:,index_x1);
    wX = centerlinedata.d2(:,index_x1);
    sigma = centerlinedata_sigma.d1(index_x2);
    nodes_x = nodes_x1(index_x1);
end

[nodes_x,order] = sort(nodes_x,'ascend');
sigma = sigma(:,order);
wX = wX(:,order);
wXX = wXX(:,order);

for i = 1:size(wXX,1)
    Q(i) = Q0*(12/(E*h*h))*trapz(nodes_x,wX(i,:).*wX(i,:))/trapz(nodes_x,wXX(i,:).*wXX(i,:)./sigma);
end

%not sure how to calculate Q with varying h, here just try a trial
h = arrayfun(@getSize, nodes_x);
for i = 1:size(wXX,1)
    Q(i) = 6900/1e-7*12/E*trapz(nodes_x,wX(i,:).*wX(i,:)./h)/trapz(nodes_x,wXX(i,:).*wXX(i,:)./sigma);
end
end

function Q = CalculateQ_whole(Links, Params, localmodeindex)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref] = Links{1:end};
h =Params{1}{3}.value;
Q0=6900*(h/1e-7);
E =250e9;
int2expr = {'wX*wX','wXX*wXX/solid.sx'};
numerator = mphint2(model,int2expr{1},'volume','solnum',localmodeindex);
denominator = mphint2(model,int2expr{2},'volume','solnum',localmodeindex);
Q = Q0*(12/(E*h*h))*numerator./denominator;
end

function thickness = getSize(x, params)
    if inCell(x, params.defect)
        if inRec(x, params.defect.A)
            thickness = params.defect.A.height;
        elseif inRec(x, params.defect.B)
            thickness = params.defect.B.height;
        else
            thickness = params.defect.C.height;
        end
    else
        for i = 1:params.NumofUC*2
            if inCell(x, params.defect(i))
                if inRec(x, params.defect.A)
                    thickness = params.defect.A.height;
                elseif inRec(x, params.defect.B)
                    thickness = params.defect.B.height;
                else
                    thickness = params.defect.C.height;
                end
            end
        end
    end
end

function re = inCell(x, unitcell)
    if x <= unitcell.x + unitcell.length/2 && x >= unitcell.x - unitcell.length/2
        re = true;
    else
        re = false;
    end
end

function re = inRec(x, rectangle)
    if x <= rectangle.x + rectangle.length/2 && x >= rectangle.x - rectangle.length/2
        re = true;
    else
        re = false;
    end 
end