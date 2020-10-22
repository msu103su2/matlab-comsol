function SingleRunResult = reconstruct(params, links)
import com.comsol.model.*
import com.comsol.model.util.*
eps = 1e-10;

% reset defect params and others
links.model.param.set('DL',[num2str(params.defect.length) '[m]']);
links.model.param.set('DW',[num2str(params.defect.width) '[m]']);
links.model.param.set('Dx',[num2str(params.defect.x) '[m]']);
links.model.param.set('Dy',[num2str(params.defect.y) '[m]']);
links.model.param.set('Dz',[num2str(params.defect.z) '[m]']);
links.model.param.set('MS',[num2str(params.MS) '[m]']);
links.model.param.set('NumofUC',[num2str(params.NumofUC) '[1]']);

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

heights = [];
geomNames = {};
[heights, geomNames] = SortHeights(heights, geomNames, params.defect.A);
[heights, geomNames] = SortHeights(heights, geomNames, params.defect.B);
[heights, geomNames] = SortHeights(heights, geomNames, params.defect.C);
for i = 1 : params.NumofUC*2
    [heights, geomNames] = SortHeights(heights, geomNames, params.UCs(i).A);
    [heights, geomNames] = SortHeights(heights, geomNames, params.UCs(i).B);
    [heights, geomNames] = SortHeights(heights, geomNames, params.UCs(i).C);
end

if size(heights,2) == 1
    links.exts = [links.exts, links.geom1.feature.create('ext1','Extrude')];
    links.exts(1).set('workplane', 'wp1');
    links.exts(1).selection('input').set({'wp1'});
    links.exts(1).set('distance', heights(1));
elseif size(heights,2) == 2
    if(heights(1) > heights(2))
        heights = flip(heights);
        geomNames = flip(geomNames);
    end 
    heights(2) = heights(2) -heights(1); 
    %do the higher part firstly, the extra height part
    links.exts = [links.exts, links.geom1.feature.create('ext1','Extrude')];
    links.exts(1).set('workplane', 'wp1');
    links.exts(1).set('reverse', true);
    links.exts(1).selection('input').set('wp1.'+string(geomNames{2}));
    links.exts(1).set('distance', heights(2));
    
    links.exts = [links.exts, links.geom1.feature.create('ext2','Extrude')];
    links.exts(2).set('extrudefrom', 'faces');
    for i = 1:size(geomNames{2},2)
        links.exts(2).selection('inputface').set(['ext1(',num2str(i),')'],4);
    end
    for i = 1:size(geomNames{1},2)
        links.exts(2).selection('inputface').set('wp1.'+string(geomNames{1}{i}),1);
    end
    links.exts(2).set('distance', heights(1));
end
links.geom1.run;

%prestress condiciton
links.iss1.set('Sil', cellstr(string(reshape(params.stressTensor,1,[]))));

%study node
links.eig.set('neigs', 100);

%extra control for obtaining localmode through symmetry
%{
difblock = links.geom1.create('difblock','Block');
difblock.set('size',[rightEndCoord(1)-leftEndCoord(1) ...
    params.defect.B.width*10 params.defect.B.height]);
difblock.set('pos',[0 params.defect.B.width*5 params.defect.B.height/2]);
difblock.set('base','center');
dif1 = links.geom1.create('dif1', 'Difference');
dif1.selection('input').set({'ext1'});
dif1.selection('input2').set({'difblock'});
links.geom1.run;
sym1 = links.solid.create('sym1','SymmetrySolid',2);
symmetryface = mphselectbox(links.model,'geom1',[leftEndCoord(1)-eps,...
    rightEndCoord(1)+eps;-eps,eps;-eps,params.defect.B.height+eps],'boundary');
sym1.selection.set(symmetryface);
%}

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
%{
sweldestibox = [leftEndCoord(1)-eps, rightEndCoord(1)+eps;...
    -params.defect.B.width*5, params.defect.B.width*5;...
    -eps, eps];
    %}
idx_bnd1 = mphselectbox(links.model,'geom1', bnd1box, 'boundary');
idx_bnd2 = mphselectbox(links.model,'geom1', bnd2box, 'boundary');
idx_ftri = mphselectbox(links.model,'geom1', ftribox, 'boundary');
%idx_sweldestiface = mphselectbox(links.model,'geom1', sweldestibox, 'boundary');
links.fix1.selection.set([idx_bnd1 idx_bnd2]);
links.Msize.set('hmax', 'MS');
links.Msize.set('hmin', 'MS/4');
links.Msize.set('hcurve', '0.2');
links.ftri.selection.set(idx_ftri);

links.ref{1}.set('rmethod', 'regular');
links.ref{1}.set('numrefine', 3);
links.ref{1}.set('boxcoord', true);
links.ref{1}.set('xmax', bnd1box(1,1)+params.MS);
links.ref{1}.set('xmin', bnd1box(1,1));
links.ref{1}.set('ymax', bnd1box(2,2));
links.ref{1}.set('ymin', bnd1box(2,1));
links.ref{1}.set('zmax', bnd1box(3,2));
links.ref{1}.set('zmin', bnd1box(3,1));
links.ref{1}.selection.geom('geom1', 2);
links.ref{1}.selection.set(idx_ftri);

links.ref{2}.set('rmethod', 'regular');
links.ref{2}.set('numrefine', 1);
links.ref{2}.set('boxcoord', true);
links.ref{2}.set('xmax', bnd1box(1,1)+params.MS/3);
links.ref{2}.set('xmin', bnd1box(1,1));
links.ref{2}.set('ymax', bnd1box(2,2));
links.ref{2}.set('ymin', bnd1box(2,1));
links.ref{2}.set('zmax', bnd1box(3,2));
links.ref{2}.set('zmin', bnd1box(3,1));
links.ref{2}.selection.geom('geom1', 2);
links.ref{2}.selection.set(idx_ftri);

links.ref{3}.set('rmethod', 'regular');
links.ref{3}.set('numrefine', 3);
links.ref{3}.set('boxcoord', true);
links.ref{3}.set('xmax', bnd2box(1,2));
links.ref{3}.set('xmin', bnd2box(1,2)-params.MS);
links.ref{3}.set('ymax', bnd2box(2,2));
links.ref{3}.set('ymin', bnd2box(2,1));
links.ref{3}.set('zmax', bnd2box(3,2));
links.ref{3}.set('zmin', bnd2box(3,1));
links.ref{3}.selection.geom('geom1', 2);
links.ref{3}.selection.set(idx_ftri);

links.ref{4}.set('rmethod', 'regular');
links.ref{4}.set('numrefine', 1);
links.ref{4}.set('boxcoord', true);
links.ref{4}.set('xmax', bnd2box(1,2));
links.ref{4}.set('xmin', bnd2box(1,2)-params.MS/3);
links.ref{4}.set('ymax', bnd2box(2,2));
links.ref{4}.set('ymin', bnd2box(2,1));
links.ref{4}.set('zmax', bnd2box(3,2));
links.ref{4}.set('zmin', bnd2box(3,1));
links.ref{4}.selection.geom('geom1', 2);
links.ref{4}.selection.set(idx_ftri);

idx_ext1 = mphselectbox(links.model,'geom1', ftribox+[0,0;0,0;0,heights(1)], 'domain');
links.swel.selection.geom('geom1', 3);
links.swel.selection.set(idx_ext1);
links.swel.create('dis1', 'Distribution');
links.swel.feature('dis1').set('numelem', 2);

if (size(heights, 2) == 2)
    idx_ext2 = mphselectbox(links.model,'geom1', ftribox-[0,0;0,0;heights(2),0], 'domain');
    links.swe2.selection.geom('geom1', 3);
    links.swe2.selection.set(idx_ext2);
    links.swe2.create('dis1', 'Distribution');
    links.swe2.feature('dis1').set('numelem', 2);
end

links.mesh.run;
links.std.run;
lowercenterline = mphselectbox(links.model,'geom1', [leftEndCoord(1)-eps,eps;-eps,eps;-eps,eps;], 'edge');
[localmodefreq, localmodeEffMass] = Localmode_center_tilt(links,params,lowercenterline);
%{
...

The following code do the calculation without symmetrizing the geom
geom1.run;

%get indicies
idx_bnd1 = mphselectbox(model,'geom1', coords{1}, 'boundary');
idx_bnd2 = mphselectbox(model,'geom1', coords{2}, 'boundary');
idx_ftri = mphselectbox(model,'geom1', coords{3}, 'boundary');
idx_sweldestiface = mphselectbox(model,'geom1', coords{4}, 'boundary');
%physics interface
fix1.selection.set([idx_bnd1 idx_bnd2]);

%meshing
Msize.set('hmax', 'MS');
Msize.set('hmin', 'MS/4');
Msize.set('hcurve', '0.2');
ftri.selection.set(idx_ftri);
swel.selection('sourceface').set(idx_ftri);
swel.selection('targetface').set(idx_sweldestiface);
mesh.run;
eig.set('neigs', 100);
eig.set('shift',[num2str(localmodefreq) '[Hz]']);
tic;
std.run;
toc;
...
...
%}

%export data
SingleRunResult = evaluategeom(links,params,localmodefreq,localmodeEffMass,leftEndCoord, rightEndCoord);
SingleRunResult.EffMass = localmodeEffMass;
SingleRunResult.modes = sortModes(links, params, lowercenterline);
%links.geom1.feature.remove('difblock');
%links.geom1.feature.remove('dif1');
%links.solid.feature.remove('sym1');
links.swel.feature.remove('dis1');
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

function modes = sortModes(links, params, lowercenterline)
    lowlinedata_disp = mpheval(links.model,'w','edim',1,'selection',lowercenterline);
    coords = lowlinedata_disp.p;
    locoords = sortrows(coords');
    hicoords = flip(-locoords);
    coords = [locoords(1:end-1,:);hicoords(2:end,:)]';
    minEdgeD = 0.5*min(params.getMinWidth);
    side1coords = [coords(1,:);coords(2,:)+minEdgeD;coords(3,:)];
    side2coords = [coords(1,:);coords(2,:)-minEdgeD;coords(3,:)];
    centerline_data_x = mphinterp(links.model,'u','coord',coords);
    centerline_data_y = mphinterp(links.model,'v','coord',coords);
    centerline_data_z = mphinterp(links.model,'w','coord',coords);
    side1_data = mphinterp(links.model,'w','coord',side1coords);
    side2_data = mphinterp(links.model,'w','coord',side2coords); 
    Eigenfreq = mphglobal(links.model,'solid.freq');
    data = mpheval(links.model,{'u','v','w'});
    %{
    Index = find(judge);
    data.d1 = data.d1(Index,:);
    data.d2 = data.d2(Index,:);
    data.d3 = data.d3(Index,:);
    Eigenfreq = Eigenfreq(Index);
    centerline_data = centerline_data(Index);
    side1_data = side1_data(Index);
    side2_data = side2_data(Index);
    %}
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
            [pks,pklocs,pkw,pkp] = findpeaks(abs(centerline_data_x(i,:)));
            modes.InPlane_x.k = [modes.InPlane_x.k, pi*size(pklocs, 2)/deviceLength];
        elseif(dim == 2)
            modes.InPlane_y.freq = [modes.InPlane_y.freq, Eigenfreq(i)];
            [pks,pklocs,pkw,pkp] = findpeaks(abs(centerline_data_y(i,:)));
            modes.InPlane_y.k = [modes.InPlane_y.k, pi*size(pklocs, 2)/deviceLength];
        else
            coef = corrcoef(side1_data(i,:),side2_data(i,:));
            coef = coef(1,2);
            half = size(coords,2)/2;
            coef2 = min(abs([corrcoef(flip(side1_data(i,1:half)),side1_data(i,half+1:end)),...
                corrcoef(flip(side2_data(i,1:half)),side2_data(i,half+1:end))]));
            coef2 = coef2(1,2);
            
            count = 0;
            side1mean = mean(abs(side1_data(i,:)));
            for j = 1:size(centerline_data_z(i,:),2)
                if (sign(side1_data(i,j))*sign(side2_data(i,j))>0 && ...
                        sign(side1_data(i,j))*sign(centerline_data_z(i,j))<0 &&...
                        abs(side1_data(i,j))>side1mean)
                    count = count+1;
                end
            end
            
            if(coef < -coefmin && coef2 > coefmin && count < 1)
                modes.tilt.freq = [modes.tilt.freq, Eigenfreq(i)];
                [pks,pklocs,pkw,pkp] = findpeaks(abs(side1_data(i,:)));
                modes.tilt.k = [modes.tilt.k, pi*size(pklocs, 2)/deviceLength];
            elseif(coef > coefmin && coef2 > coefmin && count < 1)
                modes.OutOfPlane.freq = [modes.OutOfPlane.freq, Eigenfreq(i)];
                [pks,pklocs,pkw,pkp] = findpeaks(abs(centerline_data_z(i,:)));
                modes.OutOfPlane.k = [modes.OutOfPlane.k, pi*size(pklocs, 2)/deviceLength];
            else
                modes.trash.freq = [modes.trash.freq, Eigenfreq(i)];
            end
        end
    end
    
    
end

function converted = convertNames(geomNames)
    converted = [];
    for i = 1:size(geomNames,2)
        uniNames = [];
        indexs = [];
        for  j = 1:size(geomNames{i},2)
            out = regexp(geomNames{i}{j},'(defect|R[0-9]+|L[0-9]+)+rec([ABC]+)','tokens');
            if out{1}{2} == 'A'
                index = 1;
            elseif out{1}{2} == 'B'
                index = 2;
            else
                index = 3;
            end
            indexs{j} = index;
            uniNames{j} = ['wp1.', out{1}{1}, 'Uni'];
        end
        extrude.indexs = indexs;
        extrude.uniNames = uniNames;
        converted{i} = extrude;
    end
end