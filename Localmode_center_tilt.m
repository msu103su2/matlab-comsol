function [localmodefreq, localmodeEffMass]= Localmode_center_tilt(Links,coords, Params)
[model, geom1, wp1, ext1, mesh, Msize, ftri, swel, iss1, fix1, std,...
    eig, solid, ref] = Links{1:end};
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*
centerline = mphselectbox(model,'geom1', [coords{5}(1)-eps,coords{6}(1)+eps;-eps,eps;-eps,eps;], 'edge');

h =Params{1}{3}.value;
L = 2*Params{2}{1}.value*Params{1}{9}.value+Params{1}{1}.value;
W = Params{2}{8}.value;
PhC = mphselectbox(model,'geom1', [-L/2-eps,L/2+eps;-W/2-eps,W/2+eps;-eps,h+eps;], 'domain');
PhCdata = mpheval(model,'w','edim',3,'selection',PhC);

lowlinedata_disp = mpheval(model,'w','edim',1,'selection',centerline(1));
coords = lowlinedata_disp.p;
low_dp = lowlinedata_disp.d1;

highlinedata_disp = mphinterp(model,'w','coord',-coords);
high_dp = highlinedata_disp;

judge = zeros(size(low_dp,1),1);
for rowi = 1:size(low_dp,1)
    %{
    level = mean(abs(low_dp(rowi,:)))+ mean(abs(high_dp(rowi,:)));
    level = level/200;
    
    temp1 = absdiff(rowi,:);
    temp2 = temp1>level;
    temp1 = temp1(temp2);
    if size(temp1,2)>0
    else
        judge(rowi) = 1;
    end
    %}
    coef = corrcoef(high_dp(rowi,:),low_dp(rowi,:));
    if coef(1,2)<-0.98
        flapFlag = 1;
        data = [abs(low_dp(rowi,:));-coords(1,:)];
        data = sortrows(transpose(data),2);
        [pks, locs] = findpeaks(data(:,1), data(:,2));
        for j = 1 : size(pks)
            x = -locs(j);
            ymax = 0;
            for edgeFind_i = 1:size(PhCdata.p,2)
                if(abs(PhCdata.p(1,edgeFind_i)-x)<Params{1}{8}.value && abs(PhCdata.p(2,edgeFind_i)) > abs(ymax))
                    ymax = PhCdata.p(2,edgeFind_i);
                end
            end
            cutcoords = zeros(3,21);
            cutcoords(1,:) = cutcoords(1,:)+x;
            cutcoords(2,:) = 0:ymax/20:ymax;
            transverseCut = mphinterp(model,'w','coord',cutcoords,'solnum',rowi);
            transverseCut = transverseCut(find(~isnan(transverseCut)));
            %sprintf('%i:%i:%d',rowi,j,((max(transverseCut)-min(transverseCut))/abs(mean(transverseCut))))
            if ((max(transverseCut)-min(transverseCut))/abs(mean(transverseCut)) > 0.3)
                flapFlag = 0;
                break;
            end
        end
        judge(rowi) = 1*flapFlag;
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