function compatible = CheckChamferFillet (LL, LW, RL, RW, ChamferD, FilletR)
compatible = true;

if(ChamferD > abs(LW-RW)/2)
    compatible = false;
end

if(LW > RW)
    if (ChamferD > LL)
        compatible = false;
        Fillet_Max = min([(LL - ChamferD)/tan(22.5*pi/180),RL/tan(22.5*pi/180)]);
    end
else
    if (ChamferD > RL)
        compatible = false;
        Fillet_Max = min([(RL - ChamferD)/tan(22.5*pi/180),LL/tan(22.5*pi/180)]);
    else
        Fillet_Max = 0;
    end
end

if (FilletR > min([ChamferD*cos(pi/4)/tan(22.5*pi/180),Fillet_Max]))
    compatible = false;
end
end