function result = UCarrayfromsingle(workplane, names, UCParams, Positions)
%create Unit cell array according to specific function and unit cell model
BaseParams = UCParams;
Basenames = names;
for i = 1:size(Positions,2)
    names = {strcat(Basenames{1}, '_', num2str(i)) strcat(Basenames{2}, '_', num2str(i))...
        strcat(Basenames{3}, '_', num2str(i)) strcat(Basenames{4}, '_', num2str(i))...
        strcat(Basenames{5}, '_', num2str(i))};
    UCParams{4}.value = Positions(i);
    [AllUCParams{i}, AllUCnames{i}] = unitcellgeom(workplane, names, UCParams);
end
result = AllUCnames;
end