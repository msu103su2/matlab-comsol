function CalcuParameterRange()
    ChamferR.value;
    FilletR.value;
    UrectWMax = 2*UW;
    UrectWMin = 1.01*UW;
    UrectLMax = UL-2*FilletR.value*tan(22.5*pi/180);
    UrectLMin = 2*(UrectW-UW+FilletR.value*tan(22.5*pi/180));
end