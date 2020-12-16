function PlotModes(WaferSN, DieNumber)
    sql = SQL;
    Tablename = sprintf('Device_on_Die%s_%2i',WaferSN, DieNumber);
    result = sql.query(sprintf('SELECT COUNT(*) FROM %s.%s;',sql.databasename, Tablename));
    NumberOfDevices = result{1,1};
    EFs = [];
    x=[];
    for i = 1:NumberOfDevices
        DeviceSN = sprintf('%s_%02i_%02i',WaferSN, DieNumber, i);
        result = sql.Select('DeviceSN',DeviceSN','Eigenfreq',Tablename);
        EF = jsondecode(result{1,1}{1,1});
        EF = EF(1:50,1);
        EFs = [EFs EF];
        result = sql.Select('DeviceSN',DeviceSN','UL',Tablename);
        x = [x,result{1,1}];
    end
    figure('Name','simulated Modes');
    plot(x*10e6,EFs/1e6,'*')
end
