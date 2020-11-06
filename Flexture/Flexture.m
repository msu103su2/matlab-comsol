function SingleRunResult = Flexture(params, links)
import com.comsol.model.*
import com.comsol.model.util.*
eps = 1e-10;

links.fix1.active(false);
% reset defect params and others
links.model.param.set('DL',[num2str(params.defect.length) '[m]']);
links.model.param.set('DW',[num2str(params.defect.width) '[m]']);
links.model.param.set('Dx',[num2str(params.defect.x) '[m]']);
links.model.param.set('Dy',[num2str(params.defect.y) '[m]']);
links.model.param.set('Dz',[num2str(params.defect.z) '[m]']);
links.model.param.set('MS',[num2str(params.MS) '[m]']);
links.model.param.set('NumofUC',[num2str(params.NumofUC) '[1]']);
links.model.param.set('Kf',[num2str(params.NumofUC) '[rad/m]']);

%recreate workplane, recreate defect
for i = 1:size(links.exts)
    links.geom1.feature.remove(links.exts(i).tag);
end
links.exts = [];
links.geom1.feature.remove('wp1');
links.wp1 = links.geom1.feature.create('wp1', 'WorkPlane');
links.geom1.feature.move('wp1',0);
links.wp1.set('quickplane', 'xy');
unitcellgeom(links.wp1, params.defect);

%deal with the geomtry array
for i = 1 : 2*params.NumofUC
    unitcellgeom(links.wp1, params.UCs(i));
end

if (params.NumofUC == 0)
    leftEndCoord = [params.defect.x - ...
        params.defect.length/2 0];
    rightEndCoord = [params.defect.x + ...
        params.defect.length/2 0];
else
    leftEndCoord = [params.UCs(2*params.NumofUC).x - ...
        params.UCs(2*params.NumofUC).length/2 0];
    rightEndCoord = [params.UCs(2*params.NumofUC-1).x + ...
        params.UCs(2*params.NumofUC-1).length/2 0];
end
ls1 = links.wp1.geom.create('ls1','LineSegment');
ls1.set('specify1', 'coord');
ls1.set('specify2', 'coord');
ls1.set('coord1', leftEndCoord);
ls1.set('coord2', [0,0]);

ls2 = links.wp1.geom.create('ls2','LineSegment');
ls2.set('specify1', 'coord');
ls2.set('specify2', 'coord');
ls2.set('coord1', [0,0]);
ls2.set('coord2', rightEndCoord);

%count how many extrusions are needed

%extrude
%it seems from comsol, for 2D object on wp1, there only being 1 face with
%indice 1

if params.extra.higherH == 0
    links.exts = [links.exts, links.geom1.feature.create('ext1','Extrude')];
    links.exts(1).set('workplane', 'wp1');
    links.exts(1).selection('input').set({'wp1'});
    links.exts(1).set('distance',  params.defect.B.height);
else
    ls3 = links.wp1.geom.create('ls3','LineSegment');
    ls3.set('specify1', 'coord');
    ls3.set('specify2', 'coord');
    ls3.set('coord1', [-params.extra.higherL/2,params.defect.width/2]);
    ls3.set('coord2', [-params.extra.higherL/2,-params.defect.width/2]);

    ls4 = links.wp1.geom.create('ls4','LineSegment');
    ls4.set('specify1', 'coord');
    ls4.set('specify2', 'coord');
    ls4.set('coord1', [params.extra.higherL/2,params.defect.width/2]);
    ls4.set('coord2', [params.extra.higherL/2,-params.defect.width/2]);

    par1 = links.wp1.geom.create('par1', 'Partition');
    par1.selection('input').set({'defectfilC'});
    par1.selection('tool').set({'ls3' 'ls4'});

    %do the higher part firstly, the extra height part
    links.exts = [links.exts, links.geom1.feature.create('ext1','Extrude')];
    links.exts(1).set('workplane', 'wp1');
    links.exts(1).selection('input').set('wp1.par1');
    links.exts(1).set('distance', params.defect.B.height);
    
    links.exts = [links.exts, links.geom1.feature.create('ext2','Extrude')];
    links.exts(2).set('extrudefrom', 'faces');
    links.exts(2).set('reverse', true);
    links.exts(2).selection('inputface').set('ext1',8);
    links.exts(2).set('distance', params.extra.higherH-params.defect.B.height);
end
links.geom1.run;

%prestress condiciton
links.iss1.set('Sil', cellstr(string(reshape(params.stressTensor,1,[]))));

%study node
links.eig.set('neigs', 20);

%boundary condition
bnd1box = [leftEndCoord(1)-eps, leftEndCoord(1)+eps;...
    -params.defect.B.width*5, params.defect.B.width*5;...
    -eps, params.defect.B.height*5];
bnd2box = [rightEndCoord(1)-eps, rightEndCoord(1)+eps;...
    -params.defect.B.width*5, params.defect.B.width*5;...
    -eps, params.defect.B.height*5];
ftribox = [leftEndCoord(1)-eps, rightEndCoord(1)+eps;...
    -params.defect.B.width*5, params.defect.B.width*5;...
    -eps, eps];
idx_bnd1 = mphselectbox(links.model,'geom1', bnd1box, 'boundary');
idx_bnd2 = mphselectbox(links.model,'geom1', bnd2box, 'boundary');
idx_ftri = mphselectbox(links.model,'geom1', ftribox, 'boundary');
idx_anchor = mphselectbox(links.model,'geom1', [-eps, eps;-eps,eps;-eps,eps;], 'point');


pc1 = links.solid.create('pc1', 'PeriodicCondition', 2);
pc1.selection.set([idx_bnd1 idx_bnd2]);
pc1.set('PeriodicType', 'Floquet');
pc1.set('kFloquet', {'Kf'; '0'; '0'});

fix2 = links.solid.create('fix2', 'Fixed', 0);
fix2.selection.set(idx_anchor);

links.Msize.set('hmax', 'MS');
links.Msize.set('hmin', 'MS/4');
links.Msize.set('hcurve', '0.2');
links.ftri.selection.set(idx_ftri);

links.ref{1}.active(false);
links.ref{2}.active(false);
links.ref{3}.active(false);
links.ref{4}.active(false);

idx_ext1 = mphselectbox(links.model,'geom1', ftribox+[0,0;0,0;0,params.defect.B.height], 'domain');
links.swel.selection.geom('geom1', 3);
links.swel.selection.set(idx_ext1);
links.swel.create('dis1', 'Distribution');
links.swel.feature('dis1').set('numelem', 2);

if (params.extra.higherH ~= 0)
    idx_ref1 = mphselectbox(links.model,'geom1', [-params.extra.higherL/2-eps, -params.extra.higherL/2+eps;...
        -params.defect.width/2-eps,params.defect.width/2+eps;-eps,eps;], 'edge');
    idx_ref1 = [idx_ref1,mphselectbox(links.model,'geom1', [params.extra.higherL/2-eps, params.extra.higherL/2+eps;...
        -params.defect.width/2-eps,params.defect.width/2+eps;-eps,eps;], 'edge')];
    links.ref{1}.active(true);
    links.ref{1}.selection.geom('geom1', 1);
    links.ref{1}.selection.set(idx_ref1);
    links.ref{1}.set('numrefine', 5);
    
    idx_ext2 = mphselectbox(links.model,'geom1', ftribox-[0,0;0,0;params.extra.higherH-params.defect.B.height,0], 'domain');
    links.swe2.selection.geom('geom1', 3);
    links.swe2.selection.set(idx_ext2);
    links.swe2.create('dis1', 'Distribution');
    links.swe2.feature('dis1').set('numelem', 2);
end

swp = links.std.create('param', 'Parametric');
swp.set('pname', {'Kf'});
swp.set('plistarr', {'range(0,pi/(20*DL),pi/DL)'});
swp.set('punit', {'rad/m'});
links.eig.set('disabledphysics', {'solid/fix2'});

links.mesh.run;
links.std.run;
lowercenterline = mphselectbox(links.model,'geom1', [leftEndCoord(1)-eps,eps;-eps,eps;-eps,eps;], 'edge');


%export data
SingleRunResult.floSol = sortModes(links, params, lowercenterline);
links.swel.feature.remove('dis1');
links.solid.feature.remove('pc1');
links.solid.feature.remove('fix2');
links.fix1.active(true);
links.ref{1}.active(true);
links.ref{2}.active(true);
links.ref{3}.active(true);
links.ref{4}.active(true);
links.std.feature.remove('param')
end

function [heights, geomNames] = SortHeights(heights, geomNames, rec)
    newHeight = rec.height;
    newGeomName = rec.comsol_Rec_name;
    re = find(heights == newHeight);
    if isempty(re)
        heights = [heights, newHeight];
        geomNames{end+1} = {newGeomName};
    else
        geomNames{re}{end+1} = newGeomName;
    end
end

function floSol = sortModes(links, params, lowercenterline)
    Kfs = mphglobal(links.model,'Kf', 'dataset', 'dset3', 'outersolnum', 'all', 'solnum',1);
    sweepNum = size(Kfs,2);
    
    temp_width = min([params.defect.A.width,params.defect.B.width,params.defect.C.width]);
    edge1box = [-params.defect.B.length/2-eps, params.defect.B.length/2+eps;...
        -params.defect.B.width/2-eps, -temp_width/2+eps;...
        -eps, eps];
    idx_edge1 = mphselectbox(links.model,'geom1', edge1box, 'edge');
    edge1_data = mpheval(links.model,'w','edim',1,'selection',idx_edge1, 'dataset', 'dset3', 'outersolnum', 1, 'solnum', 1);
    edge1coords = edge1_data.p;
    edge2coords = edge1coords;
    edge2coords(2,:) = -edge2coords(2,:);
    center_coords = edge1coords;
    center_coords(2,:) = center_coords(2,:)*0;
    
    floSol = [];
    for sweep = 1:sweepNum
        lowlinedata_disp = mpheval(links.model,'w','edim',1,'selection',lowercenterline, 'dataset', 'dset3', 'outersolnum', sweep);
        coords = lowlinedata_disp.p;
        locoords = sortrows(coords');
        hicoords = flip(-locoords);
        coords = [locoords(1:end-1,:);hicoords(2:end,:)]';
        minEdgeD = 0.5*min(params.getMinWidth);
        side1coords = [coords(1,:);coords(2,:)+minEdgeD;coords(3,:)];
        side2coords = [coords(1,:);coords(2,:)-minEdgeD;coords(3,:)];
        centerline_data_x = mphinterp(links.model,'u','coord',coords, 'dataset', 'dset3', 'outersolnum', sweep);
        centerline_data_y = mphinterp(links.model,'v','coord',coords, 'dataset', 'dset3', 'outersolnum', sweep);
        centerline_data_z = mphinterp(links.model,'w','coord',coords, 'dataset', 'dset3', 'outersolnum', sweep);
        side1_data = mphinterp(links.model,'w','coord',side1coords, 'dataset', 'dset3', 'outersolnum', sweep);
        side2_data = mphinterp(links.model,'w','coord',side2coords, 'dataset', 'dset3', 'outersolnum', sweep);
        edge1_data = mphinterp(links.model,'w','coord',edge1coords, 'dataset', 'dset3', 'outersolnum', sweep);
        edge2_data = mphinterp(links.model,'w','coord',edge2coords, 'dataset', 'dset3', 'outersolnum', sweep); 
        center_data = mphinterp(links.model,'w','coord',center_coords, 'dataset', 'dset3', 'outersolnum', sweep); 
        Eigenfreq = mphglobal(links.model,'solid.freq', 'dataset', 'dset3', 'outersolnum', sweep);
        data = mpheval(links.model,{'u','v','w'}, 'dataset', 'dset3', 'outersolnum', sweep);

        coefmin = 0.98;
        deviceLength = params.getLength;
        modes.InPlane_x.freq = [];
        modes.InPlane_y.freq= [];
        modes.OutOfPlane.freq = [];
        modes.tilt.freq = [];
        modes.InPlane_x.k = [];
        modes.InPlane_y.k= [];
        modes.OutOfPlane.k = [];
        modes.tilt.k = [];
        modes.trash.freq = [];
        modes.trash.k = [];
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
                modes.InPlane_x.k = [modes.InPlane_x.k, Kfs(sweep)];
            elseif(dim == 2)
                modes.InPlane_y.freq = [modes.InPlane_y.freq, Eigenfreq(i)];
                modes.InPlane_y.k = [modes.InPlane_y.k, Kfs(sweep)];
            else
                coef = corrcoef(side1_data(i,:),side2_data(i,:));
                coef = coef(1,2);
                %{
                half = size(coords,2)/2;
                coef2 = min(abs([corrcoef(flip(side1_data(i,1:half)),side1_data(i,half+1:end)),...
                    corrcoef(flip(side2_data(i,1:half)),side2_data(i,half+1:end))]));
                coef2 = coef2(1,2);
                
%}
                count = 0;
                for j = 1:size(center_data(i,:),2)
                    if (sign(edge1_data(i,j)-center_data(i,j))*sign(edge2_data(i,j)-center_data(i,j))>0 && ...
                            max([abs(edge1_data(i,j)-center_data(i,j)),abs(edge2_data(i,j)-center_data(i,j))])/max([abs(center_data(i,j)),abs(edge1_data(i,j)),abs(edge2_data(i,j))])>0.05)
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