function Q = Q_string(model, params, modeIndex, sweepIndex)
    eps = 1e-10;
    L =  params.getLength;
    minW = params.getMinWidth;
    maxW = params.getMaxWidth;
    h = params.defect.B.height;
    
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
    coords(2,:) = 0;  
    expr = {'wX','wXX', 'solid.sx'};
    if nargin < 4
        E = mphglobal(model, 'Si3N4.def.E', 'dataset', 'dset1', ...
             'solnum', 1);   
        wX = abs(mphinterp(model, expr{1},'coord',coords,'dataset', 'dset1', 'solnum', modeIndex));
        wXX = abs(mphinterp(model, expr{2},'coord',coords,'dataset', 'dset1', 'solnum', modeIndex));
        sigma = abs(mphinterp(model, expr{3},'coord',coords,'dataset', 'dset1', 'solnum', modeIndex));
    elseif nargin == 4
        E = mphglobal(model, 'Si3N4.def.E', 'dataset', 'dset3', ...
            'outsolnum', 1, 'solnum', 1);
        wX = abs(mphinterp(model, expr{1},'coord',coords,'dataset', 'dset3','outsolnum', sweepIndex, 'solnum', modeIndex));
        wXX = abs(mphinterp(model, expr{2},'coord',coords,'dataset', 'dset3','outsolnum', sweepIndex, 'solnum', modeIndex));
        sigma = abs(mphinterp(model, expr{3},'coord',coords,'dataset', 'dset3','outsolnum', sweepIndex, 'solnum', modeIndex));
    end
    
    
    Q = 6900/1e-7*12/real(E)*trapz(coords(1,:),wX.^2./h)/trapz(coords(1,:),wXX.^2./sigma);
end