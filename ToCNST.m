function ToCNST(Params, filename)
DefectParams = Params{1};
UCParams = Params{2};
[DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC] = DefectParams{1:end};
[UL, UW, UH, Ux, Uy, Uz, UrecL, UrecW, ChamferR, FilletR] = UCParams{1:end};

fileID = fopen([filename,'.cnst'], 'w');
fprintf(fileID, '0.001 gdsReso\n');
fprintf(fileID, '0.001 shapeReso\n');
name = singleDie(Params, [1,1],[70e-6, 210e-6], 200, [-3.6e3,3.6e3],'testDie',6,fileID);

fprintf(fileID, '# define the overall wafer structure\n');
fprintf(fileID, '<wafer struct>\n');%define the overall wafer layout, how dies are organized, the size of dies
fprintf(fileID, '1 layer\n');%marker layer, define the boundary
fprintf(fileID, '100 layer\n');
fprintf(fileID, '0 0 1e5 1e5 -71.3 251.3 0 arcVector\n');
fprintf(fileID, '<partA wafer 100 genArea>\n');
fprintf(fileID, '101 layer\n');
fprintf(fileID, '0 0 1e5 1e5 -108.7 -71.3 1 0 arc\n');
fprintf(fileID, '<partB wafer 101 genArea>\n');
fprintf(fileID, '<partA partB 0 or>\n');


fclose(fileID);

command = sprintf('java -jar C:\\Users\\purdylab\\Desktop\\CNSTNanolithographyToolboxV2016.10.01\\CNSTNanolithographyToolboxV2016.10.01.jar cnstscripting %s.cnst %s.gds',filename,filename);
[status,cmdout] = dos(command);
status, cmdout
command = sprintf('C:\\Users\\purdylab\\AppData\\Roaming\\KLayout\\klayout_app C:\\Users\\purdylab\\%s.gds',filename);
[status,cmdout] = dos(command);
status, cmdout

end

function name = singleBeam(Params, SBname, SBlayer, fileID)
name = SBname;
DefectParams = Params{1};
UCParams = Params{2};
[DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC] = DefectParams{1:end};
[UL, UW, UH, Ux, Uy, Uz, UrecL, UrecW, ChamferR, FilletR] = UCParams{1:end};

fprintf(fileID, sprintf('<UC_%s struct>\n',SBname));
fprintf(fileID, '128 layer\n');
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',0, 0, UL.value*1e6, UW.value*1e6));
fprintf(fileID, '129 layer\n');
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',0, 0, UrecL.value*1e6, UrecW.value*1e6));
fprintf(fileID, '130 layer\n');
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 45 rectangleC\n',UrecL.value*1e6/2, UrecW.value*1e6/2, ChamferR.value*1e6*sqrt(2), ChamferR.value*1e6*sqrt(2)));
fprintf(fileID, '131 layer\n');
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 45 rectangleC\n',-UrecL.value*1e6/2, UrecW.value*1e6/2, ChamferR.value*1e6*sqrt(2), ChamferR.value*1e6*sqrt(2)));
fprintf(fileID, '132 layer\n');
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 45 rectangleC\n',UrecL.value*1e6/2, -UrecW.value*1e6/2, ChamferR.value*1e6*sqrt(2), ChamferR.value*1e6*sqrt(2)));
fprintf(fileID, '133 layer\n');
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 45 rectangleC\n',-UrecL.value*1e6/2, -UrecW.value*1e6/2, ChamferR.value*1e6*sqrt(2), ChamferR.value*1e6*sqrt(2)));
fprintf(fileID, sprintf('<UCpart001 UC_%s 128 genArea>\n',SBname));
fprintf(fileID, sprintf('<UCpart002 UC_%s 129 genArea>\n',SBname));
fprintf(fileID, sprintf('<UCpart003 UC_%s 130 genArea>\n',SBname));
fprintf(fileID, sprintf('<UCpart004 UC_%s 131 genArea>\n',SBname));
fprintf(fileID, sprintf('<UCpart005 UC_%s 132 genArea>\n',SBname));
fprintf(fileID, sprintf('<UCpart006 UC_%s 133 genArea>\n',SBname));

fprintf(fileID, '<UCpart001 UCpart002 134 or>\n');
fprintf(fileID, sprintf('<Union UC_%s 134 genArea>\n',SBname));
fprintf(fileID, '<Union UCpart003 135 subtract>\n');
fprintf(fileID, sprintf('<Union UC_%s 135 genArea>\n',SBname));
fprintf(fileID, '<Union UCpart004 136 subtract>\n');
fprintf(fileID, sprintf('<Union UC_%s 136 genArea>\n',SBname));
fprintf(fileID, '<Union UCpart005 137 subtract>\n');
fprintf(fileID, sprintf('<Union UC_%s 137 genArea>\n',SBname));
fprintf(fileID, '<Union UCpart006 138 subtract>\n');
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
fprintf(fileID, '<CurveOr 0 0 X 1 0 0 162 genAreaCopy>\n');
fprintf(fileID, '<CurveOr 0 0 Y 1 0 0 164 genAreaCopy>\n');
fprintf(fileID, '<CurveOr 0 0 0 1 180 0 166 genAreaCopy>\n');
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
fprintf(fileID, '<CurveSub 0 0 X 1 0 0 163 genAreaCopy>\n');
fprintf(fileID, '<CurveSub 0 0 Y 1 0 0 165 genAreaCopy>\n');
fprintf(fileID, '<CurveSub 0 0 0 1 180 0 167 genAreaCopy>\n');
%_________________________________________________________________________

fprintf(fileID, '<Union CurveOr 168 or>\n');
fprintf(fileID, sprintf('<Union UC_%s 168 genArea>\n',SBname));
fprintf(fileID, sprintf('<CurveOr UC_%s 162 genArea>\n',SBname));
fprintf(fileID, '<Union CurveOr 169 or>\n');
fprintf(fileID, sprintf('<Union UC_%s 169 genArea>\n',SBname));
fprintf(fileID, sprintf('<CurveOr UC_%s 164 genArea>\n',SBname));
fprintf(fileID, '<Union CurveOr 170 or>\n');
fprintf(fileID, sprintf('<Union UC_%s 170 genArea>\n',SBname));
fprintf(fileID, sprintf('<CurveOr UC_%s 166 genArea>\n',SBname));
fprintf(fileID, '<Union CurveOr 171 or>\n');
fprintf(fileID, sprintf('<Union UC_%s 171 genArea>\n',SBname));
fprintf(fileID, sprintf('<CurveSub UC_%s 161 genArea>\n',SBname));
fprintf(fileID, '<Union CurveSub 172 subtract>\n');
fprintf(fileID, sprintf('<Union UC_%s 172 genArea>\n',SBname));
fprintf(fileID, sprintf('<CurveSub UC_%s 163 genArea>\n',SBname));
fprintf(fileID, '<Union CurveSub 173 subtract>\n');
fprintf(fileID, sprintf('<Union UC_%s 173 genArea>\n',SBname));
fprintf(fileID, sprintf('<CurveSub UC_%s 165 genArea>\n',SBname));
fprintf(fileID, '<Union CurveSub 174 subtract>\n');
fprintf(fileID, sprintf('<Union UC_%s 174 genArea>\n',SBname));
fprintf(fileID, sprintf('<CurveSub UC_%s 167 genArea>\n',SBname));
fprintf(fileID, sprintf('<Union CurveSub %1.f subtract>\n', SBlayer));

fprintf(fileID, '# define device(beam)\n');
fprintf(fileID, sprintf('<%s struct>\n', SBname));%single device
fprintf(fileID, sprintf('%1.f layer\n', SBlayer));
fprintf(fileID, sprintf('%s %s %s %s 0 rectangleC\n',num2str(Dx.value*1e6), num2str(Dy.value*1e6), num2str(DL.value*1e6), num2str(DW.value*1e6)));
x = (DL.value+UL.value)/2;
y=0;
dx = UL.value;
dy = 0;
fprintf(fileID, sprintf('<UC_%s %.3f %.3f %1.f %1.f %.3f %.3f 1 arrayRect>\n',SBname,x*1e6,y*1e6,NumofUC.value,1,dx*1e6,dy*1e6));
x = -(DL.value+UL.value)/2;
dx = -UL.value;
fprintf(fileID, sprintf('<UC_%s %.3f %.3f %1.f %1.f %.3f %.3f 1 arrayRect>\n',SBname,x*1e6,y*1e6,NumofUC.value,1,dx*1e6,dy*1e6));
end

function name = singleDie(Params, IndexofParamToBeVaried, VaryRange, BeamArrayYstep, BeamArrayYrange, Diename, Dielayer, fileID)
name = Diename;
SingleDieLength = 11e3;
SingleDieWidth = 11e3;
DiceWidth = 1.5e3;
IntervalWidth = 4e3;
HoldGapWidth = 2e3;
BeamHolderWidth = 1e3;
Params{IndexofParamToBeVaried(1)}{IndexofParamToBeVaried(1)}.value = VaryRange(1);
ParamStep = (VaryRange(2)-VaryRange(1))/((BeamArrayYrange(2)-BeamArrayYrange(1))/BeamArrayYstep);
counter = 1;
for y = BeamArrayYrange(1) : BeamArrayYstep : BeamArrayYrange(2)
    Params{IndexofParamToBeVaried(1)}{IndexofParamToBeVaried(1)}.value = VaryRange(1)+(counter-1)*ParamStep;
    SBname{counter} = singleBeam(Params, sprintf('%s_%s00%1.f',Diename,...
        Params{IndexofParamToBeVaried(1)}{IndexofParamToBeVaried(1)}.name,...
        counter),175,fileID);
    Lengths(counter) = 2*Params{1}{9}.value*Params{2}{1}.value*1e6+Params{1}{1}.value*1e6;
    counter = counter + 1;
end
fprintf(fileID, sprintf('# %s\n',Diename));
fprintf(fileID, sprintf('<%s struct>\n',Diename));%single die of different params
counter = 1;
for y = BeamArrayYrange(1) : BeamArrayYstep : BeamArrayYrange(2)
    fprintf(fileID,sprintf('<%s %.3f %.3f 0 1 0 instance>\n',SBname{counter},-IntervalWidth/4,y));
    counter = counter + 1;
end
fprintf(fileID, '175 layer\n');
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
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',...
    -IntervalWidth/4-min(Lengths)/2-BeamHolderWidth/2,...
    (BeamArrayYrange(2)+BeamArrayYrange(1))/2,...
    BeamHolderWidth,BeamArrayYrange(2)-BeamArrayYrange(1)+Params{2}{8}.value*1e6));
fprintf(fileID, sprintf('%.3f %.3f %.3f %.3f 0 rectangleC\n',...
    -IntervalWidth/4+min(Lengths)/2+BeamHolderWidth/2,...
    (BeamArrayYrange(2)+BeamArrayYrange(1))/2,...
    BeamHolderWidth,BeamArrayYrange(2)-BeamArrayYrange(1)+Params{2}{8}.value*1e6));

fprintf(fileID, sprintf('<beams %s 175 genArea>\n',Diename));
fprintf(fileID, '176 layer\n');
fprintf(fileID, sprintf('0 0 %.3f %.3f 0 rectangleC\n',SingleDieLength, SingleDieWidth));
fprintf(fileID, sprintf('<base %s 176 genArea>\n',Diename));
fprintf(fileID, sprintf('<base beams %1.f subtract>\n',Dielayer));

end