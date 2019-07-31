function result = Localmode(Eigenfreq)
% function need to figure out which is the local model and how good it is,
% need to return a number to indicate how good the result is. the number
% shall be smaller the better.
products = zeros(1,size(Eigenfreq',2));
gapsize = zeros(1,size(Eigenfreq',2));
for i = 2 : (size(Eigenfreq',2)-1)
    products(i) = (Eigenfreq(i+1)-Eigenfreq(i))*(Eigenfreq(i)-Eigenfreq(i-1));
end
for i = 2 : (size(Eigenfreq',2)-1)
    gapsize(i) = (Eigenfreq(i+1)-Eigenfreq(i-1));
end
result = 1/max(products);
max(gapsize)
end