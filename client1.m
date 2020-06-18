import com.comsol.model.*
import com.comsol.model.util.*

sql = SQL;
WaferSN = '000';
DieNumber = 13;
[Params, Links] = init_shan();

Tablename = sprintf('Device_on_Die%s_%2i',WaferSN, DieNumber);
if(~sql.IsFieldExsist(Tablename, 'Eigenfreq'))
    sql.AddField(Tablename, 'Eigenfreq', 'json')
end

if(~sql.IsFieldExsist(Tablename, 'localmodefreq'))
    sql.AddField(Tablename, 'localmodefreq', 'DOUBLE')
end

result = sql.query(sprintf('SELECT COUNT(*) FROM %s.%s;',sql.databasename, Tablename));
NumberOfDevices = result{1,1};

for i = 1:NumberOfDevices
    DeviceSN = sprintf('%s_%02i_%02i',WaferSN, DieNumber, i);
    
    Params = sql.SelectDevice(WaferSN, DieNumber, i);
    result = reconstruct(Params, Links);
    jsontxt = jsonencode(result.Eigenfreq);
    
    sql.UpdateJSONField('Eigenfreq', jsontxt, DeviceSN);
    sql.UpdateNumberField('localmodefreq', result.localmodefreq, DeviceSN);
end