function [localmodefreq, localmodeEffMass]= Localmode_center_tilt(links, params,lowercenterline)
eps = 1e-10;
import com.comsol.model.*
import com.comsol.model.util.*

PhCdata = mpheval(links.model,'w','edim',3);

lowlinedata_disp = mpheval(links.model,'w','edim',1,'selection',lowercenterline);
coords = lowlinedata_disp.p;
low_dp = lowlinedata_disp.d1;

highlinedata_disp = mphinterp(links.model,'w','coord',-coords);
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
                if(abs(PhCdata.p(1,edgeFind_i)-x)<params.MS && abs(PhCdata.p(2,edgeFind_i)) > abs(ymax))
                    ymax = PhCdata.p(2,edgeFind_i);
                end
            end
            cutcoords = zeros(3,21);
            cutcoords(1,:) = cutcoords(1,:)+x;
            cutcoords(2,:) = 0:ymax/20:ymax;
            transverseCut = mphinterp(links.model,'w','coord',cutcoords,'solnum',rowi);
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

centerlinedata_disp = mpheval(links.model,'u*u+v*v+w*w','edim',1,'selection',lowercenterline);
centerlinedata_disp.d1 = centerlinedata_disp.d1(find(judge),:);

if isequal(size(centerlinedata_disp.d1,1),0)
    fprintf('No mode identified');
    allfreq = mphglobal(links.model, 'solid.freq');
    localmodefreq = allfreq(1);
    localmodeEffMass = 1e-6;
else
    maxpointdata_disp = zeros(size(centerlinedata_disp.d1,1),1);
    for i=1:size(centerlinedata_disp.d1,1)
        maxpointdata_disp(i) = max(centerlinedata_disp.d1(i,:));
    end
    temp = mphint2(links.model,'solid.rho*(u*u+v*v+w*w)',3);
    temp = temp(find(judge));
    effectivemass = temp./(maxpointdata_disp)';
    [localmodeEffMass, index] = min(effectivemass);
    allfreq = mphglobal(links.model, 'solid.freq');
    allfreq = allfreq(find(judge));
    localmodefreq = allfreq(index);
end
end