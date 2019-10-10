function [AllUCParams, AllUCnames, coords] = UCarrayfromsingle(workplane, names, UCParams, Positions, Links, DefectParams)
%create Unit cell array according to specific function and unit cell model
BaseParams = UCParams;
Basenames = names;
model = Links{1};
for i = 1:size(Positions,2)
    names = {};
    for j = 1:size(Basenames ,2)
        names = [names, strcat(Basenames{j}, '_', num2str(i))];
    end
    UCParams{4}.value = Positions(i);
    [AllUCParams{i}, AllUCnames{i}] = unitcellgeom(workplane, DefectParams, UCParams, names);
end
%return the entity indices for boundary fixed boundary and mesh
tolerance = BaseParams{3}.value/10;
coords_bnd1 = [Positions(1)-AllUCParams{1}{1}.value/2-tolerance, Positions(1)-AllUCParams{1}{1}.value/2+tolerance;...
    -AllUCParams{1}{2}.value/2-tolerance, AllUCParams{1}{2}.value/2+tolerance;...
    -tolerance, AllUCParams{1}{3}.value+tolerance];
coords_bnd2 = [Positions(end)+AllUCParams{end}{1}.value/2-tolerance, Positions(end)+AllUCParams{end}{1}.value/2+tolerance;...
    -AllUCParams{end}{2}.value/2-tolerance, AllUCParams{end}{2}.value/2+tolerance;...
    -tolerance, AllUCParams{end}{3}.value+tolerance];
coords_ftriface = [Positions(1)-AllUCParams{1}{1}.value/2-tolerance, Positions(end)+AllUCParams{end}{1}.value/2+tolerance;...
    -AllUCParams{1}{8}.value/2-tolerance, AllUCParams{end}{8}.value/2+tolerance;...
    AllUCParams{end}{3}.value-tolerance, AllUCParams{end}{3}.value+tolerance];
coords_sweldestiface = [Positions(1)-AllUCParams{1}{1}.value/2-tolerance, Positions(end)+AllUCParams{end}{1}.value/2+tolerance;...
    -AllUCParams{1}{8}.value/2-tolerance, AllUCParams{end}{8}.value/2+tolerance;...
    -tolerance, +tolerance];
ls1coords1 =[Positions(1)-AllUCParams{1}{1}.value/2,0];
ls1coords2 =[Positions(end)+AllUCParams{end}{1}.value/2,0];
coords = {coords_bnd1, coords_bnd2, coords_ftriface, coords_sweldestiface,...
    ls1coords1, ls1coords2};
end