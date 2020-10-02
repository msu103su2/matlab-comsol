classdef Links < handle
    properties
        model;
        geom1;
        wp1;
        ext1;
        mesh;
        Msize;
        ftri;
        swel;
        iss1;
        fix1;
        std;
        eig;
        solid;
        ref;
    end
    methods
        function obj = Links(model, geom1, wp1, ext1, mesh, Msize, ...
                ftri,swel, iss1, fix1, std, eig, solid, ref)
            obj.model = model;
            obj.geom1 = geom1;
            obj.wp1 = wp1;
            obj.ext1 = ext1;
            obj.mesh = mesh;
            obj.Msize = Msize;
            obj.ftri = ftri;
            obj.swel = swel;
            obj.iss1 = iss1;
            obj.fix1 = fix1;
            obj.std = std;
            obj.eig = eig;
            obj.solid = solid;
            obj.ref = ref;
        end
    end
end