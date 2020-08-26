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
        EFs = [EFs jsondecode(result{1,1}{1,1})];
        result = sql.Select('DeviceSN',DeviceSN','UL',Tablename);
        x = [x,result{1,1}];
    end
    figure('Name','simulated Modes');
    plot(x,EFs,'*')
    ylim([1e5 4.9e6]);
end
