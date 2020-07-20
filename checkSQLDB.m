sql = SQL;
WaferSN = '000'
DieNumber = 21;
Tablename = sprintf('Device_on_Die%s_%i',WaferSN, DieNumber);
ids = sql.query(sprintf('Select id FROM %s.%s;',sql.databasename, Tablename));
numOfDevices = height(ids);

for id = table2array(ids)'
    DeviceSN = sprintf("%s_%i_%02i", WaferSN, DieNumber, id);
    UW = sql.Select('DeviceSN', DeviceSN, 'UW', Tablename);
    UrecW = sql.Select('DeviceSN', DeviceSN, 'UrecW', Tablename);
    ChamferR = sql.Select('DeviceSN', DeviceSN, 'ChamferR', Tablename);
    FilletR = sql.Select('DeviceSN', DeviceSN, 'FilletR', Tablename);
    UW = UW{1,1};UrecW = UrecW{1,1};ChamferR = ChamferR{1,1}; FilletR = FilletR{1,1};
    if (ChamferR > (UrecW - UW)/2)
        ChamferR = (UrecW - UW)/2;
        sql.UpdateNumberField('ChamferR', ChamferR, DeviceSN)
    end
    
    if (FilletR > ChamferR/(sqrt(2) * tan(pi/8)))
        FilletR = ChamferR/(sqrt(2) * tan(pi/8));
        sql.UpdateNumberField('FilletR', FilletR, DeviceSN)
    end
end
