function R = test(theta)
if 251.3/180*pi<=mod(theta,2*pi) && mod(theta,2*pi)<=288.7/180*pi
    L = cos(18.7/180*pi);
    R = L / cos(abs(mod(theta,2*pi)-1.5*pi));
else
    R = 1;
end
end