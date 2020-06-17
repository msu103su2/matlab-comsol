import com.comsol.model.*
import com.comsol.model.util.*

sql = SQL;
WaferSN = '000';
DieNumber = 13;
DeviceNumber = 2;

DeviceSN = sprintf('%s_%02i_%02i',WaferSN, DieNumber, DeviceNumber);
out = regexp(DeviceSN,'([0-9]+_[0-9]+)_[0-9]+','tokens');
Tablename = sprintf('Device_on_Die%s',out{1,1}{1,1});

[Params, Links] = init_shan();

Params = sql.SelectDevice(WaferSN, DieNumber, DeviceNumber);
result = reconstruct(Params, Links);

Fieldname = 'Eigenfreq';
jsontxt = jsonencode(result.Eigenfreq);

if(~sql.IsFieldExsist(Tablename, Fieldname))
    sql.AddField(Tablename, Fieldname, 'json')
end

sql.UpdateJSONField(Eigengreq, jsontxt, DeviceSN);