particle.x = Params;
particle.xre = meritFunction(particle.x);
particle.p = particle.x;
particle.pre = particle.xre;
g = particle.x;
gre = particle.xre;
particle.v = zeros(size(Params));
particles = repmat(particle, 1, 50);
for i = 1:size(particles,2)
    [particles(i).x, particles(i).v] = GenerateNewParams(Params);
    particles(i).xre = meritFunction(particles(i).x); 
    particles(i).p = particles(i).x;
    particles(i).pre = particles(i).xre;
end

figure()
hold on
for x = 0.3:0.025:0.8
    [SearchResult, evolution] = PSO_general(Params,0.3,0.2,0.6,particles);
    display(evolution);
    plot(x, evolution,'*')
end


function meritValue = meritFunction(Params)
k = Params(1,:);
k = [k,2*pi];
L = Params(2,:);
Matrix = N(k(1),2*pi);
for i = 1 : size(L,2)
    Matrix = N(k(i+1),k(i))*M(k(i),L(i))*Matrix;
end
meritValue.r = -Matrix(2,1)/Matrix(2,2);
meritValue.t = Matrix(1,1)+Matrix(1,2)*meritValue.r;
end

function matrix = M(kn,Ln)
    matrix = [[exp(1i*kn*Ln),0];[0,exp(-1i*kn*Ln)]];
end

function matrix = N(k2,k1)
    matrix = 0.5*[[1+k1/k2,1-k1/k2];[1-k1/k2,1+k1/k2]];
end

function [newParams, v] = GenerateNewParams(Params)
newParams = zeros(size(Params));
v = zeros(size(Params));
global variation;
lo = 1/(1+variation);
hi = 1+variation;

newParams(1,1) = ((rand-0.5)*(hi-lo)+(hi+lo)/2)*2*pi;
v(1,1) = (2*rand-1)*(hi-lo)*2*pi;
newParams(2,1) = rand*pi/newParams(1,1);
v(2,1) = (2*rand-1)*pi/newParams(1,1);
for i = 2 : size(Params,2)
    newParams(1,i) = ((rand-0.5)*(hi-lo)+(hi+lo)/2)*newParams(1,i-1);
    v(1,i) =(2*rand-1)*(hi-lo)*newParams(1,i-1);
    newParams(2,i) = rand*pi/newParams(1,i);
    v(2,i) = (2*rand-1)*pi/newParams(1,i);
end

end