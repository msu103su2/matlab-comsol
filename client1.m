import com.comsol.model.*
import com.comsol.model.util.*

sql = SQL;
WaferSN = '000';
[Params, Links] = init_shan();
DN = [13];

for Index = 1:size(DN,2)
    DieNumber = DN(Index);
    Tablename = sprintf('Device_on_Die%s_%i',WaferSN, DieNumber);
    if(~sql.IsFieldExsist(Tablename, 'Eigenfreq'))
        sql.AddField(Tablename, 'Eigenfreq', 'json')
    end

    if(~sql.IsFieldExsist(Tablename, 'localmodefreq'))
        sql.AddField(Tablename, 'localmodefreq', 'DOUBLE')
    end

    result = sql.query(sprintf('SELECT COUNT(*) FROM %s.%s;',sql.databasename, Tablename));
    Lengths = sql.query(sprintf('SELECT DeviceLength FROM %s.%s;',sql.databasename, Tablename));
    cutoffLength = min(table2array(Lengths)) - 1e-6;
    NumberOfDevices = result{1,1};

    for i = 1:NumberOfDevices
        DeviceSN = sprintf('%s_%i_%02i',WaferSN, DieNumber, i);

        Params = sql.SelectDevice(WaferSN, DieNumber, i);
        Params{2}{9}.value = min(Params{2}{9}.value, (Params{2}{8}.value - Params{2}{2}.value)/2);
        result = realconstruct(Params, Links, cutoffLength);
        jsontxt = jsonencode(real(result.Eigenfreq));

        sql.UpdateJSONField('Eigenfreq', jsontxt, DeviceSN);
        sql.UpdateNumberField('localmodefreq', real(result.localmodefreq), DeviceSN);
    end
end


