function modes = sortModes_noSweep(model, params)
    L =  params.getLength;
    minW = params.getMinWidth;
    maxW = params.getMaxWidth;
    
    upEdge_coords = [];
    center_coords = [];
    lowEdge_coords = [];
    upEdge = mphselectbox(model, 'geom1',[-L/2-eps,L/2+eps;minW/2-eps,maxW/2+eps;-eps,eps] ,'edge');
    upEdge_data = mpheval(model,'w','edim',1,'selection',upEdge, 'dataset', 'dset1', 'solnum',1);
    coords = upEdge_data.p;
    
    coords = coords(:, find(coords(1,:)<0));
    coords = sortrows(coords')';
    temp = coords;
    temp(1,:) = -temp(1,:);
    temp = sortrows(temp')';
    coords = [coords, temp];
    
    for i = 1:size(coords,2)
        coord = coords(:,i);
        upEdge_coords = [upEdge_coords, coord];
        coord(2) = -coord(2);
        lowEdge_coords = [lowEdge_coords, coord];
        coord(2) = 0;
        center_coords = [center_coords, coord];
    end
    tilt_coords = upEdge_coords;
    tilt_coords(2,:) = minW/2;

    coefmin = 0.98;
    modes.InPlane_x.freq = [];
    modes.InPlane_y.freq= [];
    modes.OutOfPlane.freq = [];
    modes.tilt.freq = [];
    modes.InPlane_x.k = [];
    modes.InPlane_y.k= [];
    modes.OutOfPlane.k = [];
    modes.tilt.k = [];
    modes.InPlane_x.index = [];
    modes.InPlane_y.index = [];
    modes.OutOfPlane.index = [];
    modes.tilt.index = [];
    modes.trash.freq = [];
    modes.OutOfPlane.Q_S = [];
    
    data = mpheval(model,{'u','v','w'});
    Eigenfreq = mphglobal(model,'solid.freq');
    centerline_data_x = mphinterp(model,'u','coord',center_coords);
    centerline_data_y = mphinterp(model,'v','coord',center_coords);
    centerline_data_z = mphinterp(model,'w','coord',center_coords);
    upEdge_data_z = mphinterp(model,'w','coord',upEdge_coords);
    lowEdge_data_z = mphinterp(model,'w','coord',lowEdge_coords); 
    tilt_data_z = mphinterp(model,'w','coord',tilt_coords);
    
    for i = 1:size(data.d1,1)
        u = abs(data.d1(i,:));
        v = abs(data.d2(i,:));
        w = abs(data.d3(i,:));
        ubar = mean(u);
        vbar = mean(v);
        wbar = mean(w);
        [~,dim] = max([ubar, vbar, wbar]);
        if (dim == 1)
            modes.InPlane_x.freq = [modes.InPlane_x.freq, Eigenfreq(i)];
            [~,pklocs] = findpeaks(abs(centerline_data_x(i,:)));
            modes.InPlane_x.k = [modes.InPlane_x.k, pi*size(pklocs, 2)/L];
            modes.InPlane_x.index = [modes.InPlane_x.index, i];
        elseif(dim == 2)
            modes.InPlane_y.freq = [modes.InPlane_y.freq, Eigenfreq(i)];
            [~,pklocs] = findpeaks(abs(centerline_data_y(i,:)));
            modes.InPlane_y.k = [modes.InPlane_y.k, pi*size(pklocs, 2)/L];
            modes.InPlane_y.index = [modes.InPlane_y.index, i];
        else
            coef = corrcoef(upEdge_data_z(i,:),lowEdge_data_z(i,:));
            coef = coef(1,2);
            half = size(center_coords,2)/2;
            coef2 = min(abs([corrcoef(flip(upEdge_data_z(i,1:half)),upEdge_data_z(i,half+1:end)),...
                corrcoef(flip(lowEdge_data_z(i,1:half)),lowEdge_data_z(i,half+1:end))]));
            coef2 = coef2(1,2);
            
            count = 0;
            side1mean = mean(abs(upEdge_data_z(i,:)));
            for j = 1:size(centerline_data_z(i,:),2)
                if (sign(upEdge_data_z(i,j))*sign(lowEdge_data_z(i,j))>0 && ...
                        sign(upEdge_data_z(i,j))*sign(centerline_data_z(i,j))<0 &&...
                        abs(upEdge_data_z(i,j))>side1mean)
                    count = count+1;
                end
            end
            
            if(coef < -coefmin && coef2 > coefmin && count < 3)
                modes.tilt.freq = [modes.tilt.freq, Eigenfreq(i)];
                n = antinodes(real(tilt_data_z(i,:))) - 1;
                modes.tilt.k = [modes.tilt.k, pi*n/L];
                modes.tilt.index = [modes.tilt.index, i];
            elseif(coef > coefmin && coef2 > coefmin && count < 3)
                modes.OutOfPlane.freq = [modes.OutOfPlane.freq, Eigenfreq(i)];
                [~,pklocs] = findpeaks(abs(centerline_data_z(i,:)));
                modes.OutOfPlane.k = [modes.OutOfPlane.k, pi*size(pklocs, 2)/L];
                modes.OutOfPlane.index = [modes.OutOfPlane.index, i];
                modes.OutOfPlane.Q_S = [modes.OutOfPlane.Q_S, ];
            else
                modes.trash.freq = [modes.trash.freq, Eigenfreq(i)];
            end
        end
    end  
end

function n = antinodes(y)
    n = 2;
    len_y = max([size(y,1),size(y,2)]);
    checkLength = 3;
    for i = checkLength + 1 : len_y - (checkLength - 1)
        if y(i)*y(i-1) < 0
            flag = true;
            for j = 1:checkLength - 1
                flag = flag & (y(i)*y(i+j) > 0) & (y(i-1)*y(i-1-j) > 0);
            end
            if flag
                n = n + 1;
            end
        end
    end
end