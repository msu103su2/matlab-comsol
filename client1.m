import com.comsol.model.*
import com.comsol.model.util.*

sql = SQL;
[Params, Links] = init_shan();
Params = sql.SelectDevice(sql, '000', 13, 2);
result = reconstruct(Params, Links);
s = result;