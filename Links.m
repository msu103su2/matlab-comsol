classdef Links < handle
    properties
        model;
        geom1;
        wp1;
        exts;
        mesh;
        Msize;
        ftri;
        swel;
        swe2;
        iss1;
        fix1;
        std;
        eig;
        solid;
        ref;
        pc1;
    end
    methods
        function obj = Links(model, geom1, wp1, exts, mesh, Msize, ...
                ftri,swel, swe2, iss1, fix1, std, eig, solid, ref)
            obj.model = model;
            obj.geom1 = geom1;
            obj.wp1 = wp1;
            obj.exts = exts;
            obj.mesh = mesh;
            obj.Msize = Msize;
            obj.ftri = ftri;
            obj.swel = swel;
            obj.swe2 = swe2;
            obj.iss1 = iss1;
            obj.fix1 = fix1;
            obj.std = std;
            obj.eig = eig;
            obj.solid = solid;
            obj.ref = ref;
        end
    end
end