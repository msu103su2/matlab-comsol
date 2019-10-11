function ToCNST(DiesParams, filename, Dielayer, Backlayer, WaferSN, CNSTdir, GDSdir)%DiesParams(i).Params,DiesParams(i).ParamIndex,DiesParams(i).YStep, DiesParams(i).Yrange, DiesParams(i).Dienumber,DiesParams(i).Diename

if ~exist(CNSTdir, 'dir')
    mkdir(CNSTdir);
end
if ~exist(GDSdir, 'dir')
    mkdir(GDSdir);
end
workingdir = pwd;

CNSTpath = [CNSTdir,'\',filename,'.cnst'];
GDSpath = [GDSdir,'\',filename,'.gds'];
TempCNSTpath = [workingdir,'\\',filename,'.cnst'];
fileID = fopen(TempCNSTpath, 'w');
fprintf(fileID, '0.001 gdsReso\n');
fprintf(fileID, '0.1 shapeReso\n');
[numberstrucs,numberspaceL,numberspaceW] = DieCharacter(fileID, Dielayer);
[SmallNumberLength, SmallNumberWidth, SmallNumberse]=DieCharacterSmall(fileID,Dielayer);
charactergap = 100;

for i = 1:size(DiesParams, 2)
    [temp,IntervalWidth,EtchWidth,SingleDieLength,SingleDieWidth] = ...
        singleDie(DiesParams(i).Params,DiesParams(i).ParamsIndex,...
        DiesParams(i).ParamsRange, DiesParams(i).Ystep,...
        DiesParams(i).Yrange,DiesParams(i).Diename,Dielayer,fileID,...
        Backlayer, charactergap,numberspaceW,numberspaceL,...
        DiesParams(i).Dienumber, WaferSN);
end

%marker
MarkerLayer = 1;
FX_dx = 5e3;
MarkerC = CreateMarker (MarkerLayer, fileID,'0');
for i = 1:9
    MarkerFXs(2*i-1).name= CreateMarker (MarkerLayer, fileID,num2str(i));
    MarkerFXs(2*i-1).x = i*FX_dx;
    MarkerFXs(2*i).name= CreateMarker (MarkerLayer, fileID,['-',num2str(i)]);
    MarkerFXs(2*i).x = -i*FX_dx;
end
MarkerFEX = 33e3;
MarkerFEY = 33e3;
MarkerDis = 300;
for i = 1:8
    MarkerFEs(i).name = CreateMarker(MarkerLayer, fileID,['FE',num2str(i)]);
end
MarkerFEs(1).x = MarkerFEX + MarkerDis;
MarkerFEs(1).y = MarkerFEY - MarkerDis;
MarkerFEs(2).x = MarkerFEX - MarkerDis;
MarkerFEs(2).y = MarkerFEY + MarkerDis;
MarkerFEs(3).x = -MarkerFEX + MarkerDis;
MarkerFEs(3).y = MarkerFEY + MarkerDis;
MarkerFEs(4).x = -MarkerFEX - MarkerDis;
MarkerFEs(4).y = MarkerFEY - MarkerDis;
MarkerFEs(5).x = -MarkerFEX - MarkerDis;
MarkerFEs(5).y = -MarkerFEY + MarkerDis;
MarkerFEs(6).x = -MarkerFEX + MarkerDis;
MarkerFEs(6).y = -MarkerFEY - MarkerDis;
MarkerFEs(7).x = MarkerFEX - MarkerDis;
MarkerFEs(7).y = -MarkerFEY - MarkerDis;
MarkerFEs(8).x = MarkerFEX + MarkerDis;
MarkerFEs(8).y = -MarkerFEY + MarkerDis;

%[DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC] = DefectParams{1:end};
%[UL, UW, UH, Ux, Uy, Uz, UrecL, UrecW, ChamferR, FilletR] = UCParams{1:end};
%name = singleDie(Params,[1,1],[70e-6, 210e-6], 200, [-400,400],'testDie',Dielayer,fileID,Backlayer);

fprintf(fileID, '# define the overall wafer structure\n');
WaferR = 50e3;
[DieCenters,Rots] = FitDieInWafer (WaferR, SingleDieLength, SingleDieWidth);

fprintf(fileID, '<wafer struct>\n');%define the overall wafer layout, how dies are organized, the size of dies
fprintf(fileID, '1 layer\n');%marker layer, define the boundary
fprintf(fileID, '100 layer\n');
fprintf(fileID, sprintf('0 0 %.3f %.3f -71.3 251.3 0 arcVector\n',WaferR, WaferR));
fprintf(fileID, '<partA wafer 100 genArea>\n');
fprintf(fileID, '101 layer\n');
fprintf(fileID, sprintf('0 0 %.3f %.3f -108.7 -71.3 1 0 arc\n',WaferR, WaferR));
fprintf(fileID, '<partB wafer 101 genArea>\n');
fprintf(fileID, '<partA partB 0 or>\n');
fprintf(fileID, '2 layer\n');

for i = 1:size(DiesParams,2)
    fprintf(fileID,sprintf('<%s %.3f %.3f N 1 %.3f instance>\n',DiesParams(i).Diename,DieCenters{DiesParams(i).Dienumber}(1),DieCenters{DiesParams(i).Dienumber}(2), Rots(DiesParams(i).Dienumber)));
    fprintf(fileID,sprintf('<{{%1.f}} {{Arial}} 4000 %.3f %.3f textgdsC>\n',DiesParams(i).Dienumber,DieCenters{DiesParams(i).Dienumber}(1),DieCenters{DiesParams(i).Dienumber}(2)));
end

fprintf(fileID, sprintf('<%s 0 0 N 1 0 instance>\n',...
    MarkerC));
for i = 1:size(MarkerFXs,2)
    fprintf(fileID, sprintf('<%s %d 0 N 1 0 instance>\n',...
    MarkerFXs(i).name,MarkerFXs(i).x));
end
for i = 1:size(MarkerFEs,2)
    fprintf(fileID, sprintf('<%s %d %d N 1 0 instance>\n',...
    MarkerFEs(i).name,MarkerFEs(i).x,MarkerFEs(i).y));
end


fclose(fileID);
fclose('all');
tic;
command = sprintf('java -jar C:\\Users\\purdylab\\Desktop\\CNSTNanolithographyToolboxV2016.10.01\\CNSTNanolithographyToolboxV2016.10.01.jar cnstscripting %s.cnst %s.gds',filename,filename);
[status,cmdout] = dos(command);
status, cmdout
toc;
%command = sprintf('C:\\Users\\purdylab\\AppData\\Roaming\\KLayout\\klayout_app C:\\Users\\purdylab\\%s.gds', filename);
%[status,cmdout] = dos(command);
%status, cmdout
movefile(sprintf('%s.cnst',filename),CNSTdir);
movefile(sprintf('C:\\Users\\purdylab\\%s.gds',filename),GDSdir);
movefile(sprintf('C:\\Users\\purdylab\\%s.gds.log',filename),GDSdir);
end

function name = singleBeam(Params, SBname, SBlayer, fileID)
name = SBname;
DefectParams = Params{1};
UCParams = Params{2};
[DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC] = DefectParams{1:end};
[UL, UW, UH, Ux, Uy, Uz, UrecL, UrecW, ChamferR, FilletR] = UCParams{1:end};

if ~(Params{2}{2}.value==Params{2}{8}.value)
    fprintf(fileID, sprintf('<UC_%s struct>\n',SBname));
    fprintf(fileID, '128 layer\n');
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',0, 0, UL.value*1e6, UW.value*1e6));
    fprintf(fileID, '129 layer\n');
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',0, 0, UrecL.value*1e6, UrecW.value*1e6));
    fprintf(fileID, '130 layer\n');
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 45 rectangleC\n',UrecL.value*1e6/2, UrecW.value*1e6/2, ChamferR.value*1e6*sqrt(2), ChamferR.value*1e6*sqrt(2)));
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 45 rectangleC\n',-UrecL.value*1e6/2, UrecW.value*1e6/2, ChamferR.value*1e6*sqrt(2), ChamferR.value*1e6*sqrt(2)));
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 45 rectangleC\n',UrecL.value*1e6/2, -UrecW.value*1e6/2, ChamferR.value*1e6*sqrt(2), ChamferR.value*1e6*sqrt(2)));
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 45 rectangleC\n',-UrecL.value*1e6/2, -UrecW.value*1e6/2, ChamferR.value*1e6*sqrt(2), ChamferR.value*1e6*sqrt(2)));
    fprintf(fileID, sprintf('<UCpart001 UC_%s 128 genArea>\n',SBname));
    fprintf(fileID, sprintf('<UCpart002 UC_%s 129 genArea>\n',SBname));
    fprintf(fileID, sprintf('<UCpart003 UC_%s 130 genArea>\n',SBname));

    fprintf(fileID, '<UCpart001 UCpart002 134 or>\n');
    fprintf(fileID, sprintf('<Union UC_%s 134 genArea>\n',SBname));
    fprintf(fileID, '<Union UCpart003 138 subtract>\n');
    fprintf(fileID, sprintf('<Union UC_%s 138 genArea>\n',SBname));
    %__________________________________________________
    L1 = FilletR.value*tan(pi/8);
    fprintf(fileID, '139 layer\n');
    fprintf(fileID,sprintf('%.3f %.3f %.3f %.3f %.3f %.3f points2shape\n',...
        -UrecL.value/2*1e6,UW.value/2*1e6,...
        (-UrecL.value/2-L1)*1e6,UW.value/2*1e6,...
        (-UrecL.value/2+L1/sqrt(2))*1e6,(UW.value/2+L1/sqrt(2))*1e6));
    fprintf(fileID, '140 layer\n');
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f %.3f %.3f %.3f arcVector\n',...
        (-UrecL.value/2-L1)*1e6,(UW.value/2+FilletR.value)*1e6,...
        FilletR.value*1e6,FilletR.value*1e6,-90,-45,0));
    fprintf(fileID, sprintf('<Tri UC_%s 139 genArea>\n',SBname));
    fprintf(fileID, sprintf('<Arc UC_%s 140 genArea>\n',SBname));
    fprintf(fileID, '<Tri Arc 160 subtract>\n');
    fprintf(fileID, sprintf('<CurveOr UC_%s 160 genArea>\n',SBname));
    fprintf(fileID, '<CurveOr 0 0 X 1 0 0 160 genAreaCopy>\n');
    fprintf(fileID, '<CurveOr 0 0 Y 1 0 0 160 genAreaCopy>\n');
    fprintf(fileID, '<CurveOr 0 0 0 1 180 0 160 genAreaCopy>\n');
    fprintf(fileID, sprintf('<CurveOr UC_%s 160 genArea>\n',SBname));

    L1 = FilletR.value*tan(pi/8);
    fprintf(fileID, '141 layer\n');
    fprintf(fileID,sprintf('%.3f %.3f %.3f %.3f %.3f %.3f points2shape\n',...
        (-UrecL.value/2+ChamferR.value)*1e6,(UW.value/2+ChamferR.value)*1e6,...
        (-UrecL.value/2+ChamferR.value+L1)*1e6,(UW.value/2+ChamferR.value)*1e6,...
        (-UrecL.value/2+ChamferR.value-L1/sqrt(2))*1e6,(UW.value/2+ChamferR.value-L1/sqrt(2))*1e6));
    fprintf(fileID, '142 layer\n');
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f %.3f %.3f %.3f arcVector\n',...
        (-UrecL.value/2+ChamferR.value+L1)*1e6,(UW.value/2+ChamferR.value-FilletR.value)*1e6,...
        FilletR.value*1e6,FilletR.value*1e6,-90,-45,180));
    fprintf(fileID, sprintf('<Tri UC_%s 141 genArea>\n',SBname));
    fprintf(fileID, sprintf('<Arc UC_%s 142 genArea>\n',SBname));
    fprintf(fileID, '<Tri Arc 161 subtract>\n');
    fprintf(fileID, sprintf('<CurveSub UC_%s 161 genArea>\n',SBname));
    fprintf(fileID, '<CurveSub 0 0 X 1 0 0 161 genAreaCopy>\n');
    fprintf(fileID, '<CurveSub 0 0 Y 1 0 0 161 genAreaCopy>\n');
    fprintf(fileID, '<CurveSub 0 0 0 1 180 0 161 genAreaCopy>\n');
    fprintf(fileID, sprintf('<CurveSub UC_%s 161 genArea>\n',SBname));
    %_________________________________________________________________________

    fprintf(fileID, '<Union CurveOr 168 or>\n');
    fprintf(fileID, sprintf('<Union UC_%s 168 genArea>\n',SBname));

    fprintf(fileID, sprintf('<Union CurveSub %i subtract>\n',SBlayer));
    fprintf(fileID, sprintf('<Union UC_%s %i genArea>\n',SBname,SBlayer));

    fprintf(fileID, '# define device(beam)\n');
    fprintf(fileID, sprintf('<%s struct>\n', SBname));%single device
    fprintf(fileID, sprintf('%1.f layer\n', SBlayer));
    fprintf(fileID, sprintf('0 0 %.3f %.3f 0 rectangleC\n', DL.value*1e6, DW.value*1e6));
    x = (DL.value+UL.value)/2;
    y=0;
    dx = UL.value;
    dy = 0;
    fprintf(fileID, sprintf('<UC_%s %.3f %.3f %1.f %1.f %.3f %.3f 1 arrayRect>\n',SBname,x*1e6,y*1e6,NumofUC.value,1,dx*1e6,dy*1e6));
    x = -(DL.value+UL.value)/2;
    dx = -UL.value;
    fprintf(fileID, sprintf('<UC_%s %.3f %.3f %1.f %1.f %.3f %.3f 1 arrayRect>\n',SBname,x*1e6,y*1e6,NumofUC.value,1,dx*1e6,dy*1e6));
else
    fprintf(fileID, sprintf('<%s struct>\n', SBname));%single device
    fprintf(fileID, sprintf('%1.f layer\n', SBlayer));
    fprintf(fileID, sprintf('0 0 %.3f %.3f 0 rectangleC\n', (DL.value+NumofUC.value*2*UL.value)*1e6, DW.value*1e6));
end
end

function [name,IntervalWidth,EtchWidth,SingleDieLength,SingleDieWidth] = singleDie(Params, IndexofParamToBeVaried, VaryRange, BeamArrayYstep, BeamArrayYrange, Diename, Dielayer, fileID, Backlayer, charactergap, numberspaceW, numberspaceL, Dienumber, WaferSN)
DieSN = [WaferSN,'_',num2str(Dienumber)];
name = Diename;
SingleDieLength = 11e3;
SingleDieWidth = 11e3;
WaferHeight = 400;%um
EtchAngle = 54.7;%degree
EtchWidth = WaferHeight/tan(EtchAngle/180*pi);
DiceWidth = EtchWidth*1.5*2;
IntervalWidth = 4e3;
HoldGapWidth = 2e2;
BeamHolderWidth = 1e3;
BeamEndsReserveWidth = 20;

numberofdevices = (BeamArrayYrange(2)-BeamArrayYrange(1))/BeamArrayYstep+1;
numberofstrings = floor(numberofdevices/7);
numberofdevices = numberofdevices - numberofstrings;

if ~isequal(IndexofParamToBeVaried(1),0)
    stringParams = Params;
    stringParams{2}{8}.value = stringParams{2}{2}.value;
    string = singleBeam(stringParams, sprintf('%s_%sstrb',Diename,'Null'),175,fileID);
    Params{IndexofParamToBeVaried(1)}{IndexofParamToBeVaried(2)}.value = VaryRange(1);
    ParamStep = (VaryRange(2)-VaryRange(1))/(numberofdevices-1);
    counter = 1;
    for y = BeamArrayYrange(1) : BeamArrayYstep : BeamArrayYrange(2)
        if mod(counter,7)==0
            SBname{counter} = string;
            Lengths(counter) = 2*stringParams{1}{9}.value*stringParams{2}{1}.value*1e6+stringParams{1}{1}.value*1e6;
            counter = counter + 1;
        else
            Params{IndexofParamToBeVaried(1)}{IndexofParamToBeVaried(2)}.value = VaryRange(1)+(counter-1)*ParamStep;
            Params = UpdateDependencies(Params, IndexofParamToBeVaried);
            SBname{counter} = singleBeam(Params, sprintf('%s_%s00%1.f',Diename,...
                Params{IndexofParamToBeVaried(1)}{IndexofParamToBeVaried(2)}.name,...
                counter),175,fileID);
            Lengths(counter) = 2*Params{1}{9}.value*Params{2}{1}.value*1e6+Params{1}{1}.value*1e6;
            counter = counter + 1;
        end
    end
elseif isequal(IndexofParamToBeVaried,[0,0])
    counter = 1;
    for y = BeamArrayYrange(1) : BeamArrayYstep : BeamArrayYrange(2)
        SBname{counter} = singleBeam(Params, sprintf('%s_%s00%1.f',Diename,'Null',counter),175,fileID);
        Lengths(counter) = 2*Params{1}{9}.value*Params{2}{1}.value*1e6+Params{1}{1}.value*1e6;
        counter = counter + 1;
    end
elseif isequal(IndexofParamToBeVaried,[0,1])
    SBname{1} = singleBeam(Params, sprintf('%s_%s00%1.f',Diename,'Membrane',1),175,fileID);
end

fprintf(fileID, sprintf('# %s\n',Diename));
fprintf(fileID, sprintf('<%s struct>\n',Diename));%single die of different params
counter = 1;
for y = BeamArrayYrange(1) : BeamArrayYstep : BeamArrayYrange(2)
    fprintf(fileID,sprintf('<%s %.3f %.3f 0 1 0 instance>\n',SBname{counter},-IntervalWidth/4+numberspaceL/2,y));
    counter = counter + 1;
end
fprintf(fileID, sprintf('%1.f layer\n',Dielayer));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f %.3f %.3f %.3f rectSUshape\n',...
    (SingleDieLength-IntervalWidth-DiceWidth)/2, HoldGapWidth/2,...
    (SingleDieWidth-DiceWidth-HoldGapWidth)/2,...
    -(SingleDieLength-IntervalWidth/2-DiceWidth),...
    -(SingleDieLength-DiceWidth)/2,...
    DiceWidth,0));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f %.3f %.3f %.3f rectSUshape\n',...
    (SingleDieLength-IntervalWidth-DiceWidth)/2, -HoldGapWidth/2,...
    -(SingleDieWidth-DiceWidth-HoldGapWidth)/2,...
    -(SingleDieLength-IntervalWidth/2-DiceWidth),...
    (SingleDieLength-DiceWidth)/2,...
    DiceWidth,0));
fprintf(fileID, sprintf('<Dices %s %1.f genArea>\n',Diename, Dielayer));
fprintf(fileID, sprintf('<Dices 0 0 0 1 0 0 %1.f genAreaCopy>\n',Backlayer));

fprintf(fileID, '176 layer\n');
if ~isequal(IndexofParamToBeVaried,[0,1])
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',...
        -IntervalWidth/4+numberspaceL/2,(BeamArrayYrange(2)+BeamArrayYrange(1))/2,...
        min(Lengths)-1,BeamArrayYrange(2)-BeamArrayYrange(1)+Params{2}{8}.value*1e6+BeamArrayYstep*2));
elseif isequal(IndexofParamToBeVaried,[0,1])
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',...
        -IntervalWidth/4+numberspaceL/2,(BeamArrayYrange(2)+BeamArrayYrange(1))/2,...
        (Params{1}{1}.value+Params{1}{9}.value*2*Params{2}{1}.value)*1e6-1,...
        Params{1}{2}.value*1e6-1));
end

if ~isequal(IndexofParamToBeVaried,[0,1])
    counter =1;
    x = min(Lengths)/2 + 10-IntervalWidth/4+numberspaceL/2;
    for y = BeamArrayYrange(1) : BeamArrayYstep : BeamArrayYrange(2)
        smallnumber = sprintf('%02i',counter);
        for i = 1:size(smallnumber,2)
            fprintf(fileID,sprintf('<Small%s %.3f %.3f N 1 0 instance>\n',smallnumber(i),x+i*7,y));
        end
        counter = counter + 1;
    end
end

fprintf(fileID, '0 layer\n');
fprintf(fileID, sprintf('0 0 %.3f %.3f 0 rectangleC\n',SingleDieLength, SingleDieWidth));

fprintf(fileID, sprintf('<base %s 176 genArea>\n',Diename));
fprintf(fileID, sprintf('<beams %s 175 genArea>\n',Diename));
fprintf(fileID, sprintf('<base beams %1.f subtract>\n',Dielayer));

fprintf(fileID, sprintf('%1.f layer\n',Backlayer));
if ~isequal(IndexofParamToBeVaried,[0,1])
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',...
        -IntervalWidth/4+numberspaceL/2,(BeamArrayYrange(2)+BeamArrayYrange(1))/2, ...
        min(Lengths)-2*BeamEndsReserveWidth+2*EtchWidth,...
        BeamArrayYrange(2)-BeamArrayYrange(1)+BeamArrayYstep*2+2*EtchWidth+Params{2}{8}.value*1e6));
elseif isequal(IndexofParamToBeVaried,[0,1])
    fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',...
        -IntervalWidth/4+numberspaceL/2,(BeamArrayYrange(2)+BeamArrayYrange(1))/2, ...
        (Params{1}{1}.value+Params{1}{9}.value*2*Params{2}{1}.value)*1e6-2*BeamEndsReserveWidth+2*EtchWidth,...
        Params{1}{2}.value*1e6-2*BeamEndsReserveWidth+2*EtchWidth));
end

fprintf(fileID, sprintf('%1.f layer\n',Dielayer));
x=-SingleDieLength/2+DiceWidth+charactergap+numberspaceW/2;
y=SingleDieWidth/2-DiceWidth-charactergap-numberspaceL/2;
for j = 1:size(DieSN,2)
    fprintf(fileID,sprintf('<%s %.3f %.3f N 1 -90 instance>\n',DieSN(j),x,y));
    y = y - charactergap - numberspaceL;
end
end

function [ListofDies,Rots] = FitDieInWafer (WaferR, DieLength, DieWidth)
n = 2*ceil(WaferR/DieWidth);
m = 2*ceil(WaferR/DieLength);
counter = 1;
for i = 1:n
    for j = 1:m
        f = 1;
        [theta,rho] = cart2pol((j-m/2-0.5)*DieLength + DieLength/2,(-i+n/2+0.5)*DieWidth + DieWidth/2);
        if rho>WaferEdge(theta,WaferR)
            f = 0;
        end
        [theta,rho] = cart2pol((j-m/2-0.5)*DieLength - DieLength/2,(-i+n/2+0.5)*DieWidth + DieWidth/2);
        if rho>WaferEdge(theta,WaferR)
            f = 0;
        end
        [theta,rho] = cart2pol((j-m/2-0.5)*DieLength + DieLength/2,(-i+n/2+0.5)*DieWidth - DieWidth/2);
        if rho>WaferEdge(theta,WaferR)
            f = 0;
        end
        [theta,rho] = cart2pol((j-m/2-0.5)*DieLength - DieLength/2,(-i+n/2+0.5)*DieWidth - DieWidth/2);
        if rho>WaferEdge(theta,WaferR)
            f = 0;
        end
        if f==1
            ListofDies(counter) = {[(j-m/2-0.5)*DieLength,(-i+n/2+0.5)*DieWidth]};
            if mod(i,2)==1
                Rots(counter) = -90;
            else
                Rots(counter) = 90;
            end
            counter = counter + 1;
        end
    end
end
end

function R = WaferEdge(theta, WaferR)
if 251.3/180*pi<=mod(theta,2*pi) && mod(theta,2*pi)<=288.7/180*pi
    L = WaferR * cos(18.7/180*pi);
    R = L / cos(abs(mod(theta,2*pi)-1.5*pi));
else
    R = WaferR;
end
end

function [names,numberspaceL,numberspaceW] = DieCharacter(fileID, Dielayer)
Length = 10;
interval = 2;
numberspaceL = 1e3;
thickness = 200;
numberspaceW = 2*numberspaceL-thickness;
m = round((thickness+interval)/(Length+interval));
n = round((numberspaceL-2*thickness-50+interval)/(Length+interval));
names = [{'1'},{'2'},{'3'},{'4'},{'5'},{'6'},{'7'},{'8'},{'9'},{'0'},{'_'}];


fprintf(fileID, '<square struct>\n');
fprintf(fileID, sprintf('%i layer\n',Dielayer));
fprintf(fileID, sprintf('0 0 %.3f %.3f 0 rectangleC\n',Length, Length));

fprintf(fileID, '<stick struct>\n');
x = -(m-1)*(Length+interval)/2;
y = -(n-1)*(Length+interval)/2;
fprintf(fileID, sprintf('<square %.3f %.3f %1.f %1.f %.3f %.3f 1 arrayRect>\n',x,y,m,n,interval+Length,interval+Length));
counter = m-2;
while counter > 0
    x= x + (Length+interval);
    y= y - (Length+interval);
    fprintf(fileID, sprintf('<square %.3f %.3f %1.f %1.f %.3f %.3f 1 arrayRect>\n',x,y,counter,1,interval+Length,interval+Length));
    counter = counter -2;
end

x = -(m-1)*(Length+interval)/2;
y = (n-1)*(Length+interval)/2;
counter = m-2;
while counter > 0
    x= x + (Length+interval);
    y= y + (Length+interval);
    fprintf(fileID, sprintf('<square %.3f %.3f %1.f %1.f %.3f %.3f 1 arrayRect>\n',x,y,counter,1,interval+Length,interval+Length));
    counter = counter -2;
end

fprintf(fileID, sprintf('<%s struct>\n',names{1}));
x = numberspaceL/2-thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = numberspaceL/2-thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{2}));
x = 0;
y = (numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x = numberspaceL/2-thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',0,0));
x = -numberspaceL/2+thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = 0;
y = -(numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{3}));
x = 0;
y = (numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x = numberspaceL/2-thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',0,0));
x = numberspaceL/2-thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
 x = 0;
y = -(numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{4}));
x = -numberspaceL/2+thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = numberspaceL/2-thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',0,0));
x = numberspaceL/2-thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{5}));
x = 0;
y = (numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x = -numberspaceL/2+thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',0,0));
x = numberspaceL/2-thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = 0;
y = -(numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{6}));
x = 0;
y = (numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x = -numberspaceL/2+thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',0,0));
x = numberspaceL/2-thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = 0;
y = -(numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x =  -numberspaceL/2+thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{7}));
x = numberspaceL/2-thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = numberspaceL/2-thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = 0;
y = (numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{8}));
x = 0;
y = (numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x = -numberspaceL/2+thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',0,0));
x = numberspaceL/2-thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = 0;
y = -(numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x =  -numberspaceL/2+thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = numberspaceL/2-thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{9}));
x = 0;
y = (numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x = -numberspaceL/2+thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',0,0));
x = numberspaceL/2-thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = numberspaceL/2-thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{10}));
x = 0;
y = (numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x = -numberspaceL/2+thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = numberspaceL/2-thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = 0;
y = -(numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));
x =  -numberspaceL/2+thickness/2;
y = -(numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));
x = numberspaceL/2-thickness/2;
y = (numberspaceW-thickness)/4;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 0 instance>\n',x,y));

fprintf(fileID, sprintf('<%s struct>\n',names{11}));
x = 0;
y = -(numberspaceW-thickness)/2;
fprintf(fileID, sprintf('<stick %.3f %.3f N 1 90 instance>\n',x,y));

end

function Name = CreateMarker (MarkerLayer, fileID, MarkerID)
PL = 100;%um
PW = 70;%um
W = 20;%um
L = 50;%um
FW = 3;%um
FL = 11;
Name = ['Marker',MarkerID];
fprintf(fileID, sprintf('<%s struct>\n',Name));
fprintf(fileID, '100 layer\n');
fprintf(fileID, sprintf('<0 0 %.3f %.3f %.3f %.3f 0 0 0 0 alignCustC2>\n',...
    L, W, PL, PW));
fprintf(fileID, sprintf('<P1 %s 100 genArea>\n',Name));
fprintf(fileID, '101 layer\n');
fprintf(fileID, sprintf('0 0 %.3f %.3f 0 rectangleC\n',W+2,W+2));
fprintf(fileID,sprintf('<{{%s}} {{Arial}} 20 %.3f %.3f textgds>\n',MarkerID,-(PL+L),0));
fprintf(fileID, sprintf('<P2 %s 101 genArea>\n',Name));
fprintf(fileID, '<P1 P2 102 SUBTRACT>\n');
fprintf(fileID, sprintf('<P3 %s 102 genArea>\n',Name));
fprintf(fileID, '103 layer\n');
fprintf(fileID, sprintf('<0 0 %.3f %.3f %.3f 0 0 0 0 alignCustC1>\n',...
    FL, FW, FL));
fprintf(fileID, sprintf('<P4 %s 103 genArea>\n',Name));
fprintf(fileID, sprintf('<P3 P4 %i OR>\n',MarkerLayer));
end

function newParams = UpdateDependencies(Params, IndexofParamToBeVaried)
newParams = Params;
key = [num2str(IndexofParamToBeVaried(1)),num2str(IndexofParamToBeVaried(2))];
switch key
    case ['2','8']%UrecW, update charmfR and filletR, to filletR's maxminum
        newParams{2}{9}.value = (newParams{2}{8}.value-newParams{2}{2}.value)/2;
        candi = newParams{2}{9}.value*cos(pi/4)/tan(22.5*pi/180);
        temp = min([(newParams{2}{1}.value-newParams{2}{7}.value)/2,(newParams{2}{7}.value-newParams{2}{9}.value)/2]);
        if temp > newParams{2}{9}.value*cos(pi/4)
            newParams{2}{10}.value = candi;
        else
            newParams{2}{10}.value = temp/tan(22.5*pi/180);
        end
end
end

function  [Length, Width, se]=DieCharacterSmall(fileID,Dielayer)
Length = 3;
Width = 1;
se = 2.5;
fprintf(fileID, sprintf('%i layer\n',Dielayer));
fprintf(fileID, sprintf('<%s struct>\n','Small0'));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',se*2,Length, Width)); 
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',-se*2,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,-se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,-se,Length,Width));

fprintf(fileID, sprintf('<%s struct>\n','Small1'));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,-se,Length,Width));

fprintf(fileID, sprintf('<%s struct>\n','Small2'));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',se*2,Length, Width)); 
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',0,Length,Width));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',-se*2,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,-se,Length,Width));

fprintf(fileID, sprintf('<%s struct>\n','Small3'));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',se*2,Length, Width)); 
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',0,Length,Width));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',-se*2,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,-se,Length,Width));

fprintf(fileID, sprintf('<%s struct>\n','Small4'));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',0,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,-se,Length,Width));

fprintf(fileID, sprintf('<%s struct>\n','Small5'));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',se*2,Length, Width)); 
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',0,Length,Width));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',-se*2,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,-se,Length,Width));

fprintf(fileID, sprintf('<%s struct>\n','Small6'));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',0,Length,Width));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',-se*2,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,-se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,-se,Length,Width));

fprintf(fileID, sprintf('<%s struct>\n','Small7'));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',se*2,Length, Width)); 
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,-se,Length,Width));

fprintf(fileID, sprintf('<%s struct>\n','Small8'));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',se*2,Length, Width)); 
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',0,Length,Width));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',-se*2,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,-se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,-se,Length,Width));

fprintf(fileID, sprintf('<%s struct>\n','Small9'));
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',se*2,Length, Width)); 
fprintf(fileID, sprintf('0 %.3f %.3f %.3f 0 rectangleC\n',0,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',-se,se,Length,Width));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 90 rectangleC\n',se,-se,Length,Width));
end