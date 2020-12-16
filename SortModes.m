function floSol = SortModes(model)
    eps = 1e-10;
    Kfs = mphglobal(model,'kx', 'dataset', 'dset3', 'outersolnum', 'all', 'solnum',1);
    L =  mphglobal(model,'a', 'dataset', 'dset1', 'solnum',1);
    minW = mphglobal(model,'p2', 'dataset', 'dset1', 'solnum',1)*2;
    maxW = mphglobal(model,'b', 'dataset', 'dset1', 'solnum',1);
    
    upEdge = mphselectbox(model, 'geom1',[-L/2-eps,L/2+eps;minW/2-eps,maxW/2+eps;-eps,eps] ,'edge');
    upEdge_coords = [];
    center_coords = [];
    lowEdge_coords = [];
    upEdge_data = mpheval(model,'w2','edim',1,'selection',upEdge, 'dataset', 'dset3', 'outersolnum', 1, 'solnum',1);
    coords = upEdge_data.p;
    for i = 1:size(coords,2)
        if true
            coord = coords(:,i);
            upEdge_coords = [upEdge_coords, coord];
            coord(2) = -coord(2);
            lowEdge_coords = [lowEdge_coords, coord];
            coord(2) = 0;
            center_coords = [center_coords, coord];
        end
    end
    
    sweepNum = size(Kfs,2);
    floSol = [];
    for sweep = 1:sweepNum
        upEdge_data = mphinterp(model,'w2','coord',upEdge_coords, 'dataset', 'dset3', 'outersolnum', sweep);
        lowEdge_data = mphinterp(model,'w2','coord',lowEdge_coords, 'dataset', 'dset3', 'outersolnum', sweep); 
        center_data = mphinterp(model,'w2','coord',center_coords, 'dataset', 'dset3', 'outersolnum', sweep); 
        Eigenfreq = mphglobal(model,'solid.freq', 'dataset', 'dset3', 'outersolnum', sweep);
        solid_data = mpheval(model,{'u2','v2','w2'}, 'dataset', 'dset3', 'outersolnum', sweep);

        coefmin = 0.98;
        modes.InPlane_x.freq = [];
        modes.InPlane_y.freq= [];
        modes.OutOfPlane.freq = [];
        modes.tilt.freq = [];
        modes.trash.freq = [];
        modes.InPlane_x.k = [];
        modes.InPlane_y.k= [];
        modes.OutOfPlane.k = [];
        modes.tilt.k = [];
        modes.trash.k = [];
        
        for i = 1:size(solid_data.d1,1)
            u = abs(solid_data.d1(i,:));
            v = abs(solid_data.d2(i,:));
            w = abs(solid_data.d3(i,:));
            ubar = mean(u);
            vbar = mean(v);
            wbar = mean(w);
            [~,dim] = max([ubar, vbar, wbar]);
            if (dim == 1)
                modes.InPlane_x.freq = [modes.InPlane_x.freq, Eigenfreq(i)];
                modes.InPlane_x.k = [modes.InPlane_x.k, Kfs(sweep)];
            elseif(dim == 2)
                modes.InPlane_y.freq = [modes.InPlane_y.freq, Eigenfreq(i)];
                modes.InPlane_y.k = [modes.InPlane_y.k, Kfs(sweep)];
            else
                coef = corrcoef(upEdge_data(i,:),lowEdge_data(i,:));
                coef = coef(1,2);
                %{
                half = size(coords,2)/2;
                coef2 = min(abs([corrcoef(flip(side1_data(i,1:half)),side1_data(i,half+1:end)),...
                    corrcoef(flip(side2_data(i,1:half)),side2_data(i,half+1:end))]));
                coef2 = coef2(1,2);
                
%}
                count = 0;
                for j = 1:size(center_data(i,:),2)
                    if (sign(upEdge_data(i,j)-center_data(i,j))*sign(lowEdge_data(i,j)-center_data(i,j))>0 && ...
                            max([abs(upEdge_data(i,j)-center_data(i,j)),abs(lowEdge_data(i,j)-center_data(i,j))])/max(abs(center_data(i,:)))>0.05)
                        count = count+1;
                    end
                end

                if(coef < -coefmin && count<1)
                    modes.tilt.freq = [modes.tilt.freq, Eigenfreq(i)];
                    modes.tilt.k = [modes.tilt.k, Kfs(sweep)];
                elseif(coef > coefmin && count<1)
                    modes.OutOfPlane.freq = [modes.OutOfPlane.freq, Eigenfreq(i)];
                    modes.OutOfPlane.k = [modes.OutOfPlane.k, Kfs(sweep)];
                else
                    modes.trash.freq = [modes.trash.freq, Eigenfreq(i)];
                    modes.trash.k = [modes.trash.k, Kfs(sweep)];
                end
            end
        end
        if (sweep == 1)
            floSol = modes;
        else
            floSol = [floSol,modes];
        end
    end
end

function re = ProjectionOnCenter(model, x)
    re = false;
    L =  mphglobal(model,'a', 'dataset', 'dset1', 'solnum',1);
    centerLine = mphselectbox(model, 'geom1',[-L/2-eps,L/2+eps;-eps,eps;-eps,eps] ,'edge');
    for i = 1:size(centerLine)
        data = mpheval(model,'w2','edim',1,'selection', centerLine(i), 'dataset', 'dset3', 'outersolnum', 1, 'solnum',1);
        coords = data.p;
        if x > min(coords(1,:)) && x < max(coords(1,:))
            re = true;
        end
    end
end