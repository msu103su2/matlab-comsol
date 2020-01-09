z=[-10:0.05:0];
r1=arrayfun(@(z) gauss(z),z);
r2=arrayfun(@(z) testF(z),z);
r3=arrayfun(@(z) gauss2(z),z);
plot(z,r1,z,r2,z,r3)
function r = gauss(z)
    z = atan(z)-z;
    r = sqrt(z);
end
function r = testF(z)
    z = -z;
    r = sqrt(z);
end
function r = gauss2(z)
    z = 2*atan(z)-z;
    r = sqrt(z);
end