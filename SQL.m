classdef SQL
    properties
        DSN;
        username;
        userpwd;
        ServerAddress;
        port ;
        conn;
        ConnectionStatus;
        MariaDBConnection;
        databasename;
        Params;
    end
    methods
        function obj = SQL()
            obj.DSN = 'MariaDB10';
            obj.username = 'shanhao';
            obj.userpwd = 'SloanGW@138';
            obj.ServerAddress = '136.142.206.151';
            obj.port = 3307;
            obj.databasename = 'DeviceDB';
            obj.MariaDBConnection = configureJDBCDataSource('Vendor','MySQL');
            obj.MariaDBConnection = setConnectionOptions(obj.MariaDBConnection,'DataSourceName',obj.DSN,'Server',obj.ServerAddress, ...
                'PortNumber',obj.port,'JDBCDriverLocation','C:\Program Files\MATLAB\R2020a\java\jar\mysql-connector-java-5.1.48.jar');
            obj.ConnectionStatus = testConnection(obj.MariaDBConnection,obj.username,obj.userpwd);
            saveAsJDBCDataSource(obj.MariaDBConnection);
            obj.conn = database(obj.DSN, obj.username, obj.userpwd);
            obj.Params = InitParams(obj);
        end
        
        function result = IsConnected(obj)
            obj.ConnectionStatus = testConnection(obj.MariaDBConnection,obj.username,obj.userpwd);
            result = obj.ConnectionStatus;
        end
        
        function result = Select(obj, tuple, tuplevalue, attribution, Table)
            sqlquery = sprintf('SELECT %s FROM %s.%s WHERE %s = ''%s'';',attribution, obj.databasename, Table, tuple, tuplevalue);
            result = fetch(obj.conn,sqlquery);
        end
        
        function Params = SelectDevice(obj, WaferSN, DieNumber, DeviceNumber)
            Table = sprintf('Device_on_Die%s_%s',WaferSN, num2str(DieNumber));
            sqlquery = sprintf('SELECT * FROM %s.%s WHERE id = %i;', obj.databasename, Table, DeviceNumber);
            data = fetch(obj.conn,sqlquery);
            data = data(1,4:22);
            for i = 1:9
                obj.Params{1}{i}.value = data{1,i};
            end
            for i = 1:10
                obj.Params{2}{i}.value = data{1,9+i};
            end
            Params = obj.Params;
        end
        
        function UpdateTable(obj, data, DeviceSN)
            out = regexp(DeviceSN,'([0-9]+_[0-9]+)_[0-9]+','tokens');
            PTablename = sprintf('Device_on_Die%s',out{1,1}{1,1});
            sqlquery = sprintf('SELECT id FROM %s.%s WHERE DeviceSN=''%s''',obj.databasename, PTablename, DeviceSN);
            result = fetch(obj.conn,sqlquery);
            DeviceNumber = result{1,1};
            
            CTablename = ['EigenFreq',DeviceSN];
            sqlquery = sprintf('DROP TABLE IF EXISTS %s;\n',CTablename);
            execute(obj.conn,sqlquery);
            sqlwrite(obj.conn,CTablename,data);
            sqlquery = sprintf(['ALTER TABLE %s\n'...
                '\tADD FOREIGN KEY (Device_id) REFERENCES %s(id),\n'...
                '\tALTER Device_id SET DEFAULT %i\n;'],[obj.databasename,'.',CTablename], [obj.databasename,'.',PTablename], DeviceNumber);
            execute(obj.onn,sqlquery);
        end
        
        function bool = IsFieldExsist(obj, Tablename, Fieldname)
            command = sprintf('SHOW COLUMNS FROM %s.%s LIKE ''%s'';',obj.databasename, Tablename, Fieldname);
            bool = ~isempty(fetch(obj.conn,command));
        end
        
        function AddField(obj, Tablename, Fieldname, FieldType)
            command = sprintf('ALTER TABLE %s.%s ADD COLUMN %s %s DEFAULT NULL;',obj.databasename, Tablename, Fieldname, FieldType);
            execute(obj.conn, command);
        end
        
        function UpdateJSONField(obj, Fieldname, json, DeviceSN)
            out = regexp(DeviceSN,'([0-9]+_[0-9]+)_[0-9]+','tokens');
            Tablename = sprintf('Device_on_Die%s',out{1,1}{1,1});
            sqlquery = sprintf('UPDATE %s.%s SET %s=''%s'' WHERE DeviceSN=''%s'';',...
                obj.databasename, Tablename, Fieldname, json, DeviceSN);
            execute(obj.conn,sqlquery);
        end
        
        function UpdateNumberField(obj, Fieldname, value, DeviceSN)
            out = regexp(DeviceSN,'([0-9]+_[0-9]+)_[0-9]+','tokens');
            Tablename = sprintf('Device_on_Die%s',out{1,1}{1,1});
            sqlquery = sprintf('UPDATE %s.%s SET %s=%s WHERE DeviceSN=''%s'';',...
                obj.databasename, Tablename, Fieldname, value, DeviceSN);
            execute(obj.conn,sqlquery);
        end
        
        function run(obj,command)
            execute(obj.conn,command);
        end
        
        function result = query(obj,command)
            result = fetch(obj.conn,command);
        end
       
        
        function result = InitParams(obj)
            f1 = 'name';   f2 = 'value';    f3 = 'unit';    f4 = 'comment';
            DL = struct(f1, 'DL', f2, 0, f3, '[m]', f4, 'Defect length');
            DW = struct(f1, 'DW', f2, 0, f3, '[m]', f4, 'Defect width');
            DH = struct(f1, 'DH', f2, 0, f3, '[m]', f4, 'Defect height');
            Dx = struct(f1, 'Dx', f2, 0, f3, '[m]', f4, 'Defect x position');
            Dy = struct(f1, 'Dy', f2, 0, f3, '[m]', f4, 'Defect y position');
            Dz = struct(f1, 'Dz', f2, 0, f3, '[m]', f4, 'Defect z position');
            kx = struct(f1, 'kx', f2, 0, f3, '[1/m]', f4, 'Defect length');
            MS = struct(f1, 'MS', f2, 0, f3, '[m]', f4, 'Mesh typical size');
            NumofUC = struct(f1, 'NumofUC', f2, 0, f3, '[1]', f4, 'Unitcell number on one side');
            cache1 = {DL, DW, DH, Dx, Dy, Dz, kx, MS, NumofUC};
            UL = struct(f1, 'UL', f2, 0, f3, '[m]', f4, 'Unitcell length');
            UW = struct(f1, 'UW', f2, 0, f3, '[m]', f4, 'Unitcell width');
            UH = struct(f1, 'UH', f2, 0, f3, '[m]', f4, 'Unitcell height');
            Ux = struct(f1, 'Ux', f2, 0, f3, '[m]', f4, 'Unitcell x position');
            Uy = struct(f1, 'Uy', f2, 0, f3, '[m]', f4, 'Unitcell y position');
            Uz = struct(f1, 'Uz', f2, 0, f3, '[m]', f4, 'Unitcell z position');
            UrecL = struct(f1, 'UrecL', f2, 0, f3, '[m]', f4, 'the length of a rectangle unit in Unitcell');
            UrecW = struct(f1, 'UrecW', f2, 0, f3, '[m]', f4, 'the width of a rectangle unit in Unitcell');
            ChamferR = struct(f1, 'ChamferR', f2, 0, f3, '[m]', f4, 'Chamfer radius');
            FilletR = struct(f1, 'FilletR', f2, 0, f3, '[m]', f4, 'fillet radius');
            cache2 = {UL UW UH Ux Uy Uz UrecL UrecW ChamferR FilletR};
            obj.Params = {cache1, cache2};
            result = obj.Params;
        end
    end
end