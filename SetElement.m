function SetElement(i, AllElementParams, UCs)
import com.comsol.model.*
import com.comsol.model.util.*
ElementParams = AllElementParams(i,:);
UCs(i).set('size', [ElementParams(2).value ElementParams(3).value]);
UCs(i).set('base', 'center');
UCs(i).set('pos', [ElementParams(5).value ElementParams(6).value]);
end