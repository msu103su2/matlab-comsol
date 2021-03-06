%MATLAB 5.0 MAT-file, Platform: PCWIN64, Created on: Fri Jul 12 11:16:55 2019                                                 IM
function SearchResult = PSO(Params, Links)
import com.comsol.model.*
import com.comsol.model.util.*
model = Links{1};
template = Params;
global totallength;

NumberOfParticles = 10;
omega = 0.3;
phi_p = 0.6;
phi_g = 0.8;
Ti = 5;
Tf = 1e-2;
r = 0.9;
T = Ti;

particle.x = template;
particle.xre = reconstruct(particle.x, Links);
particle.p = particle.x;
particle.pre = particle.xre;
particle.v = [0,0,0,0];
particle.index = [{[1,1]},{[2,1]},{[2,8]},{[2,7]}];
particles = repmat(particle, 1, NumberOfParticles);
g = particle.x;
gre = particle.xre;

Alldata.params = [particle.x];
Alldata.SingleResults = [particle.xre];
Alldata.Allfreq = [mphglobal(model,'solid.freq')];

DLMin = 50e-6;
DLMax = 200e-6;
hold on;
MaxCop = [particle.xre.cooperation];

for i = 1:size(particles,2)
    [particles(i).x, particles(i).v] = GenerateNewParams(template,DLMin,DLMax);
    particles(i).xre = reconstruct(particles(i).x, Links); 
    if particles(i).xre.cooperation > particles(i).xre.cooperation 
        particles(i).p = particles(i).x;
        particles(i).pre = particles(i).xre;
    end
    toc;
    x = sprintf('i = %1.f\n',i);
    disp(x);
    x = sprintf('new = %d, global best = %d, personal best = %d\n', particles(i).xre.cooperation, gre.cooperation, particles(i).pre.cooperation);
    disp(x);
    MaxCop = [MaxCop, particles(i).xre.cooperation];
    
    if particles(i).xre.cooperation > gre.cooperation
        g = particles(i).x;
        gre = particles(i).xre;
        Alldata.searchresult=size(Alldata.params,2);
    end
    
    Alldata.params = [Alldata.params; particles(i).x];
    Alldata.SingleResults = [Alldata.SingleResults,particles(i).xre];
    Alldata.Allfreq = [Alldata.Allfreq,mphglobal(model,'solid.freq')];
end
converged = 1;
while converged < size(particles,2)+1
    converged = 1;
    for i = 1 : size(particles,2)
        inrange = 0;
        while inrange == 0
            for d = 1 : size(particle.v,2)
                rp = rand;
                rg = rand;
                particles(i).v(d) = omega*particles(i).v(d) + ...
                    phi_p*rp*(particles(i).p{particle.index{d}(1)}{particle.index{d}(2)}.value - particles(i).x{particle.index{d}(1)}{particle.index{d}(2)}.value) +...
                    phi_g*rg*(g{particle.index{d}(1)}{particle.index{d}(2)}.value - particles(i).x{particle.index{d}(1)}{particle.index{d}(2)}.value);
                particles(i).x{particle.index{d}(1)}{particle.index{d}(2)}.value = particles(i).x{particle.index{d}(1)}{particle.index{d}(2)}.value + particles(i).v(d);
            end
            particles(i).x{1}{9}.value = floor((totallength-particles(i).x{1}{1}.value)/(2*particles(i).x{2}{1}.value));
            particles(i).x{2}{9}.value = (particles(i).x{2}{8}.value-particles(i).x{2}{2}.value)/2;
            particles(i).x{2}{10}.value = particles(i).x{2}{9}.value*cos(pi/4)/tan(22*pi/180);
            inrange = checkparams(particles(i).x, DLMin, DLMax);
        end
        particles(i).xre = reconstruct(particles(i).x, Links);
        
        toc;
        x=sprintf('T=%d, i = %1.f',T,i);
        disp(x);
        x=sprintf('new = %d, global best = %d, personal best = %d', particles(i).xre.cooperation, gre.cooperation, particles(i).pre.cooperation);
        disp(x);
        MaxCop = [MaxCop, particles(i).xre.cooperation];
        delta = (abs(real(particles(i).xre.cooperation)) - abs(real(particles(i).pre.cooperation)))/1e12;
        x=sprintf('personal exp(delta/T) = %d', exp(delta/T));
        disp(x);
        
        if abs(real(particles(i).xre.cooperation) - real(gre.cooperation))/real(gre.cooperation) < 0.03
            converged = converged + 1;
        end
        
        if particles(i).xre.cooperation > particles(i).pre.cooperation || exp(delta/T) > rand
            particles(i).p = particles(i).x;
            particles(i).pre = particles(i).xre;
        end
    
        delta = (abs(real(particles(i).xre.cooperation)) - abs(real(gre.cooperation)))/1e12;
        x=sprintf('global exp(delta/T) = %d\n', exp(delta/T));
        disp(x);
       
        if particles(i).xre.cooperation > gre.cooperation || exp(delta/T) > rand
            g = particles(i).x;
            gre = particles(i).xre;
            Alldata.searchresult=size(Alldata.params,1);
        end
    
        Alldata.params = [Alldata.params; particles(i).x];
        Alldata.SingleResults = [Alldata.SingleResults,particles(i).xre];
        Alldata.Allfreq = [Alldata.Allfreq,mphglobal(model,'solid.freq')];
        save('PSO\converge_5mm_ongoing.mat','MaxCop');
        save('PSO\data_5mm_ongoing.mat','Alldata');
    end
    T = T*r;
end
save('PSO\converge_5mm.mat','MaxCop');
SearchResult = Alldata;
end

function [newParams,v] = GenerateNewParams(template, DLMin, DLMax)
newParams = template;
global totallength;
outofrange = 1;

DLrange = DLMax - DLMin;
while outofrange == 1
newParams{1}{1}.value = rand*DLrange+DLMin;
v(1) = (2*rand-1)*DLrange;
if newParams{1}{1}.value>=DLMin && newParams{1}{1}.value<=DLMax
    outofrange = 0;
end
end

outofrange = 1;
while outofrange == 1
ULMin = template{1}{1}.value*0.5;
ULMax = template{1}{1}.value*2;
ULrange = ULMax - ULMin;
newParams{2}{1}.value = rand*ULrange+ULMin;
v(2) = (2*rand-1)*ULrange;
if newParams{2}{1}.value>=ULMin && newParams{2}{1}.value<=ULMax
    outofrange = 0;
end
end
newParams{1}{end}.value = floor((totallength-newParams{1}{1}.value)/(2*newParams{2}{1}.value));

outofrange = 1;
while outofrange == 1
UrecWMin = 1.01*newParams{2}{2}.value;
UrecWMax = 2*newParams{2}{2}.value;
UrecWrange = UrecWMax - UrecWMin;
newParams{2}{8}.value = rand*UrecWrange+UrecWMin;
v(3) = (2*rand-1)*UrecWrange;
if newParams{2}{8}.value>=UrecWMin && newParams{2}{8}.value<=UrecWMax
    outofrange = 0;
end
end
newParams{2}{9}.value = (newParams{2}{8}.value-newParams{2}{2}.value)/2;
newParams{2}{10}.value = newParams{2}{9}.value*cos(pi/4)/tan(22*pi/180);

outofrange = 1;
while outofrange == 1
UrecLMin = 2*(newParams{2}{8}.value-newParams{2}{2}.value+newParams{2}{10}.value*tan(22.5*pi/180));
UrecLMax = newParams{2}{1}.value-2*newParams{2}{10}.value*tan(22.5*pi/180)-2*newParams{1}{8}.value;
UrecLrange = UrecLMax - UrecLMin;
newParams{2}{7}.value = rand*UrecLrange+UrecLMin;
v(4) = (2*rand-1)*UrecLrange;
if newParams{2}{7}.value>=UrecLMin && newParams{2}{7}.value<=UrecLMax
    outofrange = 0;
end
end

end

function inrange = checkparams(Params, DLMin, DLMax)
inrange = 1;

if Params{1}{1}.value>=DLMin && Params{1}{1}.value<=DLMax
else
    inrange = 0;
end

ULMin = Params{1}{1}.value*0.5;
ULMax = Params{1}{1}.value*2;
if Params{2}{1}.value>=ULMin && Params{2}{1}.value<=ULMax
else
    inrange = 0;
end

UrecWMin = 1.01*Params{2}{2}.value;
UrecWMax = 2*Params{2}{2}.value;
if Params{2}{8}.value>=UrecWMin && Params{2}{8}.value<=UrecWMax
else
    inrange = 0;
end

UrecLMin = 2*(Params{2}{8}.value-Params{2}{2}.value+Params{2}{10}.value*tan(22.5*pi/180));
UrecLMax = Params{2}{1}.value-2*Params{2}{10}.value*tan(22.5*pi/180)-2*Params{1}{8}.value;
if Params{2}{7}.value>=UrecLMin && Params{2}{7}.value<=UrecLMax
else
    inrange = 0;
end

end