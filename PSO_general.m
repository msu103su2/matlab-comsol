function [SearchResult, evolution] = PSO_general(Params, omega, phi_p, phi_g, seedParticles)

global variation;
variation = 0.5;

showDetail = 1;
if nargin < 5
    optimize = 0;
else
    optimize = 1;
end

if showDetail
    figure()
    hold on
    tic;
end

NumberOfParticles = 10;
Ti = 5;
Tf = 1e-2;
r = 0.9;
T = Ti;
%omega = 0.3;
%phi_p = 0.2;
%phi_g = 0.6;

if optimize
    particles = seedParticles;
    g = particles(1).x;
    gre = particles(1).xre;
    Alldata.params = [particles(1).x];
    Alldata.SingleResults = [particles(1).xre];
    for i = 1:size(particles,2)
        if abs(particles(i).xre.r) > abs(gre.r)
            g = particles(i).x;
            gre = particles(i).xre;
        end
        Alldata.params = [Alldata.params; particles(i).x];
        Alldata.SingleResults = [Alldata.SingleResults,particles(i).xre];
    end
else
    particle.x = Params;
    particle.xre = meritFunction(particle.x);
    particle.p = particle.x;
    particle.pre = particle.xre;
    particle.log = 0;
    g = particle.x;
    gre = particle.xre;
    particle.v = zeros(size(Params));
    particles = repmat(particle, 1, NumberOfParticles);

    Alldata.params = [particle.x];
    Alldata.SingleResults = [particle.xre];

    for i = 1:size(particles,2)
        [particles(i).x, particles(i).v] = GenerateNewParams(Params);
        particles(i).xre = meritFunction(particles(i).x); 
        particles(i).p = particles(i).x;
        particles(i).pre = particles(i).xre;

        if showDetail
            toc;
            x = sprintf('i = %1.f\n',i);
            disp(x);
            x=sprintf('new = %d, global best = %d, personal best = %d\n', abs(particles(i).xre.r), abs(gre.r), abs(particles(i).pre.r));
            disp(x);
        end

        if abs(particles(i).xre.r) > abs(gre.r)
            g = particles(i).x;
            gre = particles(i).xre;
        end

        Alldata.params = [Alldata.params; particles(i).x];
        Alldata.SingleResults = [Alldata.SingleResults,particles(i).xre];
    end
end

converged = 1;
evolution = 0;
counter = 0;
flag = 1;
while converged < size(particles,2) && counter < size(particles,2)*30
    converged = 0;
    counter = counter + flag;
    evolution = evolution +1;
    T=T*r;
    for i = 1 : size(particles,2)
        for d = 1 : size(particles(i).v,2)
            inrange = 0;
            while ~inrange
                
                vmax = omega*particles(i).v(1,d) + ...
                    phi_p*abs(particles(i).p(1,d) - particles(i).x(1,d)) +...
                    phi_g*abs(g(1,d) - particles(i).x(1,d));
                vmin = omega*particles(i).v(1,d) - ...
                    phi_p*abs(particles(i).p(1,d) - particles(i).x(1,d)) -...
                    phi_g*abs(g(1,d) - particles(i).x(1,d));
                if (d == 1)
                    targetRange = [2*pi/(1+variation), 2*pi*(1+variation)];
                else
                    targetRange = [particles(i).x(1,d-1)/(1+variation), particles(i).x(1,d-1)*(1+variation)];
                end
                
                if (vmax + particles(i).x(1,d) < targetRange(1))
                    particles(i).x(1,d) = targetRange(1);
                elseif (vmin + particles(i).x(1,d) > targetRange(2))
                    particles(i).x(1,d) = targetRange(2);
                else
                    rp = rand;
                    rg = rand;
                    particles(i).v(1,d) = omega*particles(i).v(1,d) + ...
                        phi_p*rp*(particles(i).p(1,d) - particles(i).x(1,d)) +...
                        phi_g*rg*(g(1,d) - particles(i).x(1,d));
                    particles(i).x(1,d) = particles(i).x(1,d) + particles(i).v(1,d);
                end
                
                if (d == 1)
                    if(particles(i).x(1,d) <= 2*pi*(1+variation)  && 2*pi/(1+variation) <= particles(i).x(1,d))
                    inrange = 1;
                    end
                else
                    if(particles(i).x(1,d) <= particles(i).x(1,d-1)*(1+variation)  && particles(i).x(1,d-1)/(1+variation) <= particles(i).x(1,d))
                    inrange = 1;
                    end
                end
                
                vmin = omega*particles(i).v(2,d) - ...
                    phi_p*abs(particles(i).p(2,d) - particles(i).x(2,d)) -...
                    phi_g*abs(g(2,d) - particles(i).x(2,d));
                targetRange = [1/4*pi/particles(i).x(1,d), 3/4*pi/particles(i).x(1,d)];
                vmax = omega*particles(i).v(2,d) + ...
                    phi_p*abs(particles(i).p(2,d) - particles(i).x(2,d)) +...
                    phi_g*abs(g(2,d) - particles(i).x(2,d));
                targetRange = [1/4*pi/particles(i).x(1,d), 3/4*pi/particles(i).x(1,d)];
                if (vmin + particles(i).x(2,d) > targetRange(2))
                    particles(i).x(2,d) = targetRange(2);
                elseif (vmax + particles(i).x(2,d) < targetRange(1))
                    particles(i).x(2,d) = targetRange(1);
                else
                    rp = rand;
                    rg = rand;
                    particles(i).v(2,d) = omega*particles(i).v(2,d) + ...
                        phi_p*rp*(particles(i).p(2,d) - particles(i).x(2,d)) +...
                        phi_g*rg*(g(2,d) - particles(i).x(2,d));
                    particles(i).x(2,d) = particles(i).x(2,d) + particles(i).v(2,d);

                    if(particles(i).x(2,d) <= targetRange(2)  && targetRange(1) <= particles(i).x(2,d))
                        inrange = 1*inrange;
                    else
                        inrange = 0;
                    end
                end
            end
        end
        particles(i).xre = meritFunction(particles(i).x);
        
        if showDetail
            %plot(evolution, particles(i).x(2,1)*particles(i).x(1,1)/pi,'g*')
            %plot(evolution, particles(i).x(2,5)/(2*pi),'b*')
            %plot(evolution, g(2,5)/(2*pi),'r*')
            %plot(evolution, particles(i).x(2,1),'r*')
            plot(evolution, abs(particles(i).xre.r),'r*')
            toc;
            x=sprintf('new = %d, global best = %d, personal best = %d, particle = %i, T = %d, counter = %i\n', abs(particles(i).xre.r), abs(gre.r), abs(particles(i).pre.r),i, T, counter);
            disp(x);
        end
        
        if abs(particles(i).xre.r - gre.r)/abs(gre.r) < 0.02
            converged = converged + 1;
        end
        
        delta = abs(particles(i).xre.r) - abs(particles(i).pre.r);
        if abs(particles(i).xre.r) > abs(particles(i).pre.r) || exp(delta/T) > rand
            particles(i).p = particles(i).x;
            particles(i).pre = particles(i).xre;
        end
        
        if abs(particles(i).xre.r) > abs(gre.r) %|| exp(delta/T) > rand
            g = particles(i).x;
            gre = particles(i).xre;
            counter = 0;
            flag = 1;
        else
            flag = 1;
        end
    
        Alldata.params = [Alldata.params; particles(i).x];
        Alldata.SingleResults = [Alldata.SingleResults,particles(i).xre];
        
        delta = abs(particles(i).xre.r) - abs(gre.r);
        if (delta < abs(gre.r) && abs(particles(i).xre.r - gre.r)/abs(gre.r) >= 0.02 )
            particles(i).log = particles(i).log + 1;
        end
        
        if particles(i).log > 5
            particles(i).log = 0;
            [particles(i).x, particles(i).v] = GenerateNewParams(Params);
            particles(i).xre = meritFunction(particles(i).x); 
            particles(i).p = particles(i).x;
            particles(i).pre = particles(i).xre;
        end
    end
end

SearchResult = gre.r;
drawParams = g;
drawParams = [[2*pi;1],drawParams,[2*pi;1]];
rectangle('Position',[0,-drawParams(1,1)/(4*pi),drawParams(2,1),drawParams(1,1)/(2*pi)])
x = 0;
for i =2:size(drawParams,2)
    x = x + drawParams(2,i-1);
    rectangle('Position',[x,-drawParams(1,i)/(4*pi),drawParams(2,i),drawParams(1,i)/(2*pi)])
end
end

function meritValue = meritFunction(Params)
k = Params(1,:);
k = [k,200*pi];
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
newParams(2,1) = (rand-0.5)*pi/(2*newParams(1,1))+pi/(2*newParams(1,1));
v(2,1) = (2*rand-1)*pi/(2*newParams(1,1));
for i = 2 : size(Params,2)
    newParams(1,i) = ((rand-0.5)*(hi-lo)+(hi+lo)/2)*newParams(1,i-1);
    v(1,i) =(2*rand-1)*(hi-lo)*newParams(1,i-1);
    newParams(2,i) = (rand-0.5)*pi/(2*newParams(1,1))+pi/(2*newParams(1,1));
    v(2,i) = (2*rand-1)*pi/(2*newParams(1,1));
end
end