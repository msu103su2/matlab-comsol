conn = setupConn();
databasename = 'DeviceDB';
Init_BigTables(databasename,conn);

WaferSN = '000';
Filename = ['WaferSN_',WaferSN];
GDSdir = sprintf('Z:\\\\User\\\\Shan\\\\Devices\\\\WaferSN_%s\\\\GDSfile',WaferSN);
GDSpath = [GDSdir,'\\\\',Filename,'.gds'];
sqlquery = sprintf(['INSERT INTO Wafer (WaferSN, GDSFilePath)',...
    'VALUES (''%s'',''%s'')'],WaferSN,GDSpath);
execute(conn,sqlquery);
Tablename = sprintf('Die_on_Wafer%s',WaferSN);
sqlquery = sprintf('DROP TABLE IF EXISTS %s;\n',Tablename);
execute(conn,sqlquery);
sqlquery = sprintf('CREATE TABLE %s LIKE Die',Tablename);
execute(conn,sqlquery);
sqlquery = sprintf(['ALTER TABLE %s\n'...
    '\tADD FOREIGN KEY (Wafer_id) REFERENCES Wafer(id);\n'],Tablename);
execute(conn,sqlquery);

LithoCompensation = 4e-7;%m
AvaliableDies = [5:10,12:17,20:25,28:33,36:41,43:48];
DiesParams=[];


DiesParams = generateDiesfromData('PSO\data.mat',[5:10],DiesParams, WaferSN,conn,Tablename,2);
DiesParams = generateDiesfromData('PSO\data_1mm.mat',[12:17],DiesParams,WaferSN,conn,Tablename,1);
DiesParams = generateDiesfromData('PSO\data.mat',[20:25],DiesParams, WaferSN,conn,Tablename,2);
DiesParams = generateDiesfromData('PSO\data_1mm.mat',[28:33],DiesParams,WaferSN,conn,Tablename,1);

load('PSO\data.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
Membranesize = 2e-3;
DieParams.Params{2}{1}.value = (Membranesize - DieParams.Params{1}{1}.value)/(2*DieParams.Params{1}{9}.value);
DieParams.Params{1}{2}.value = Membranesize;
DieParams.Params{2}{2}.value = Membranesize;
DieParams.Params{2}{2}.value = DieParams.Params{2}{8}.value;
VPname = 'Membrane';
RVRL = 0;
RVRH = 0;
Ystep = 200;%um
Yrange = [0,1];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 36, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('A membrane of size %.3fmm by %.3fmm', Membranesize*1e3,Membranesize*1e3);
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 2, Tablename, Synopsis);
clear Result;


load('PSO\data.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
DieParams.Params{1}{2}.value = DieParams.Params{1}{2}.value*0.5;
DieParams.Params{2}{2}.value = DieParams.Params{2}{2}.value*0.5;
DieParams.Params{2}{8}.value = DieParams.Params{2}{8}.value*0.5;
DieParams.Params{2}{9}.value = DieParams.Params{2}{9}.value*0.5;
DieParams.Params{2}{10}.value = DieParams.Params{2}{10}.value*0.5;
VPname = 'DL';
RVRL = -0.2;
RVRH = 0.2;
Ystep = 200;%um
Yrange = [-1900,1900];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 37, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('Scale width down to 50%%, Vary unit cell length from %s%% to +%s%%', num2str(RVRL*100), num2str(RVRH*100));
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 2, Tablename, Synopsis);
clear Result;

load('PSO\data.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
totallength = DieParams.Params{1}{1}.value+DieParams.Params{1}{9}.value*2*DieParams.Params{2}{1}.value;
DieParams.Params{1}{1}.value = DieParams.Params{1}{1}.value*0.5;
DieParams.Params{2}{1}.value = DieParams.Params{2}{1}.value*0.5;
DieParams.Params{2}{7}.value = DieParams.Params{2}{7}.value*0.5;
DieParams.Params{1}{9}.value = floor((totallength-DieParams.Params{1}{1}.value)/(2*DieParams.Params{2}{1}.value));
VPname = 'DL';
RVRL = -0.2;
RVRH = 0.2;
Ystep = 200;%um
Yrange =[-1900,1900];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 38, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('Scale length down to 50%%, adjust NumofUC to keep DeviceLength roughly unchanged, Vary unit cell length from %s%% to +%s%%', num2str(RVRL*100), num2str(RVRH*100));
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 2, Tablename, Synopsis);
clear Result;

load('PSO\data.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
totallength = DieParams.Params{1}{1}.value+DieParams.Params{1}{9}.value*2*DieParams.Params{2}{1}.value;
DieParams.Params{1}{2}.value = totallength;
DieParams.Params{2}{2}.value = DieParams.Params{1}{2}.value;
DieParams.Params{2}{8}.value = DieParams.Params{2}{2}.value;
VPname = 'Null';
RVRL = 0;
RVRH = 0;
Ystep = 200;%um
Yrange = [0,1];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 39, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('A wide strip, Lenght=%.3fum, width=%.3fum',totallength*1e6,totallength*1e6);
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 2, Tablename, Synopsis);
clear Result;


load('PSO\data.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
totallength = 4e-3;
DieParams.Params{2}{1}.value = (totallength - DieParams.Params{1}{1}.value)/(2*DieParams.Params{1}{9}.value);
DieParams.Params{2}{8}.value = DieParams.Params{2}{2}.value;
VPname = 'Null';
RVRL = 0;
RVRH = 0;
Ystep = 200;%um
Yrange = [-1900,1900];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 40, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('A bunch of trival straight beams of %.3fmm',totallength*1e3);
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 4, Tablename, Synopsis);

load('PSO\data.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
totallength = 0.5e-3;
DieParams.Params{2}{1}.value = (totallength - DieParams.Params{1}{1}.value)/(2*DieParams.Params{1}{9}.value);
DieParams.Params{2}{8}.value = DieParams.Params{2}{2}.value;
VPname = 'Null';
RVRL = 0;
RVRH = 0;
Ystep = 200;%um
Yrange = [-1900,1900];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 41, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('A bunch of trival straight beams of %.3fmm',totallength*1e3);
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 0.5, Tablename, Synopsis);

load('PSO\data.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
totallength = 0.5e-3;
DieParams.Params{2}{1}.value = (totallength - DieParams.Params{1}{1}.value)/(2*DieParams.Params{1}{9}.value);
DieParams.Params{2}{8}.value = DieParams.Params{2}{2}.value;
VPname = 'Null';
RVRL = 0;
RVRH = 0;
Ystep = 200;%um
Yrange = [-1900,1900];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 47, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('A bunch of trival straight beams of %.3fmm',totallength*1e3);
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 0.5, Tablename, Synopsis);

load('PSO\data.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
totallength = 0.5e-3;
DieParams.Params{2}{1}.value = (totallength - DieParams.Params{1}{1}.value)/(2*DieParams.Params{1}{9}.value);
DieParams.Params{2}{8}.value = DieParams.Params{2}{2}.value;
VPname = 'Null';
RVRL = 0;
RVRH = 0;
Ystep = 200;%um
Yrange = [-1900,1900];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 48, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('A bunch of trival straight beams of %.3fmm',totallength*1e3);
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 0.5, Tablename, Synopsis);

load('PSO\data_1mm.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
Membranesize = 1e-3;
DieParams.Params{2}{1}.value = (Membranesize - DieParams.Params{1}{1}.value)/(2*DieParams.Params{1}{9}.value);
DieParams.Params{1}{2}.value = Membranesize;
DieParams.Params{1}{2}.value = Membranesize;
DieParams.Params{2}{2}.value = Membranesize;
DieParams.Params{2}{2}.value = DieParams.Params{2}{8}.value;
VPname = 'Membrane';
RVRL = 0;
RVRH = 0;
Ystep = 200;%um
Yrange = [0,1];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 43, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('A membrane of size %.3fmm by %.3fmm', Membranesize*1e3,Membranesize*1e3);
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 1, Tablename, Synopsis);
clear Result;

load('PSO\data_1mm.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
DieParams.Params{1}{2}.value = DieParams.Params{1}{2}.value*0.5;
DieParams.Params{2}{2}.value = DieParams.Params{2}{2}.value*0.5;
DieParams.Params{2}{8}.value = DieParams.Params{2}{8}.value*0.5;
DieParams.Params{2}{9}.value = DieParams.Params{2}{9}.value*0.5;
DieParams.Params{2}{10}.value = DieParams.Params{2}{10}.value*0.5;
VPname = 'Null';
RVRL = -0.2;
RVRH = 0.2;
Ystep = 200;%um
Yrange = [-1900,1900];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 44, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('Scale width down to 50%%, Vary unit cell length from %s%% to +%s%%', num2str(RVRL*100), num2str(RVRH*100));
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 1, Tablename, Synopsis);
clear Result;

load('PSO\data_1mm.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
totallength = DieParams.Params{1}{1}.value+DieParams.Params{1}{9}.value*2*DieParams.Params{2}{1}.value;
DieParams.Params{1}{1}.value = DieParams.Params{1}{1}.value*0.5;
DieParams.Params{2}{1}.value = DieParams.Params{2}{1}.value*0.5;
DieParams.Params{2}{7}.value = DieParams.Params{2}{7}.value*0.5;
DieParams.Params{1}{9}.value = floor((totallength-DieParams.Params{1}{1}.value)/(2*DieParams.Params{2}{1}.value));
VPname = 'Null';
RVRL = -0.2;
RVRH = 0.2;
Ystep = 200;%um
Yrange = [-1900,1900];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 45, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('Scale length down to 50%%, adjust NumofUC to keep DeviceLength roughly unchanged, Vary unit cell length from %s%% to +%s%%', num2str(RVRL*100), num2str(RVRH*100));
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 1, Tablename, Synopsis);
clear Result;

load('PSO\data_1mm.mat');
DieParams.Params = Result.params(Result.searchresult,1:2);
totallength = DieParams.Params{1}{1}.value+DieParams.Params{1}{9}.value*2*DieParams.Params{2}{1}.value;
DieParams.Params{1}{2}.value = totallength;
DieParams.Params{2}{2}.value = DieParams.Params{1}{2}.value;
DieParams.Params{2}{8}.value = DieParams.Params{2}{2}.value;
VPname = 'Null';
RVRL = 0;
RVRH = 0;
Ystep = 200;%um
Yrange = [0,1];%um
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, 46, WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('A wide strip, Lenght=%.3fum, width=%.3fum',totallength*1e6,totallength*1e6);
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, 1, Tablename, Synopsis);
clear Result;

sqlquery = sprintf('SET FOREIGN_KEY_CHECKS=1;\n');
execute(conn,sqlquery);
CNSTdir = sprintf('Z:\\User\\Shan\\Devices\\WaferSN_%s\\CNSTscript',WaferSN);
GDSdir = sprintf('Z:\\User\\Shan\\Devices\\WaferSN_%s\\GDSfile',WaferSN);
ToCNST(DiesParams, Filename, 6, 11, WaferSN, CNSTdir, GDSdir);


function Index = ParamTable(ParamName)
switch ParamName
    case 'DL'
        Index = [1,1];
    case 'DW'
        Index = [1,2];
    case 'DH'
        Index = [1,3];
    case 'Dx'
        Index = [1,4];
    case 'Dy'
        Index = [1,5];
    case 'Dz'
        Index = [1,6];
    case 'kx'
        Index = [1,7];
    case 'MS'
        Index = [1,8];
    case 'NumofUC'
        Index = [1,9];
    case 'UL'
        Index = [2,1];
    case 'UW'
        Index = [2,2];
    case 'UH'
        Index = [2,3];
    case 'Ux'
        Index = [2,4];
    case 'Uy'
        Index = [2,5];
    case 'Uz'
        Index = [2,6];
    case 'UrecL'
        Index = [2,7];
    case 'UrecW'
        Index = [2,8];
    case 'ChamferR'
        Index = [2,9];
    case 'FilletR'
        Index = [2,10];
    case 'Null'
        Index = [0,0];
    case 'Membrane'
        Index = [0,1];
end
end
function LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, DesignedLength, Tablename, Synopsis)
sqlquery = sprintf('SELECT id FROM Wafer WHERE WaferSN=''%s''', WaferSN);
result = fetch(conn,sqlquery);
DieSN = [WaferSN,'_',num2str(DieParams.Dienumber)];
sqlquery = sprintf(['INSERT INTO Die (DieSN, Wafer_id, DesignedLength, VariedParam, NumberOfDevices, Synopsis) ',...
    'VALUES (''%s'', %i, %.3f, ''%s'', %i, ''%s'')'],DieSN,...
    result{1,1}, DesignedLength, VPname, NumberOfDevices, Synopsis);
execute(conn,sqlquery);
sqlquery = sprintf(['INSERT INTO %s (DieSN, Wafer_id, DesignedLength, VariedParam, NumberOfDevices, Synopsis)',...
    'VALUES (''%s'', %i, %.3f, ''%s'', %i, ''%s'')'],Tablename, DieSN,...
    result{1,1}, DesignedLength, VPname, NumberOfDevices, Synopsis);
execute(conn,sqlquery);

DTablename = sprintf('Device_on_Die%s_%s', WaferSN, num2str(DieParams.Dienumber));
sqlquery = sprintf('DROP TABLE IF EXISTS %s;\n',DTablename);
execute(conn,sqlquery);
sqlquery = sprintf('CREATE TABLE %s LIKE Device;\n',DTablename);
execute(conn,sqlquery);

sqlquery = sprintf('SELECT id FROM %s WHERE DieSN=''%s''',Tablename, DieSN);
result = fetch(conn,sqlquery);
sqlquery = sprintf(['ALTER TABLE %s\n'...
    '\tADD FOREIGN KEY (Die_id) REFERENCES %s(id),\n'...
    '\tALTER Die_id SET DEFAULT %i\n;'],DTablename, Tablename, result{1,1});
execute(conn,sqlquery);

i = 1;
for j = 1:size(DieParams.Params{i},2)
    sqlquery = sprintf(['ALTER TABLE %s\n'...
        '\tADD COLUMN %s DOUBLE COMMENT ''%s|| in unit of %s'';\n'],DTablename, DieParams.Params{i}{j}.name,DieParams.Params{i}{j}.comment,DieParams.Params{i}{j}.unit);
    execute(conn,sqlquery);
    Paramnames{j}= DieParams.Params{i}{j}.name;
    Paramvalues{j}=DieParams.Params{i}{j}.value;
end

i = 2;
for j = 1:size(DieParams.Params{i},2)
    sqlquery = sprintf(['ALTER TABLE %s\n'...
        '\tADD COLUMN %s DOUBLE COMMENT ''%s|| in unit of %s'';\n'],DTablename, DieParams.Params{i}{j}.name,DieParams.Params{i}{j}.comment,DieParams.Params{i}{j}.unit);
    execute(conn,sqlquery);
    Paramnames{size(DieParams.Params{1},2)+j}= DieParams.Params{i}{j}.name;
    Paramvalues{size(DieParams.Params{1},2)+j}=DieParams.Params{i}{j}.value;
end

sqlquery = sprintf(['ALTER TABLE %s\n'...
        '\tADD COLUMN %s DOUBLE COMMENT ''%s|| in unit of %s'';\n'],DTablename, 'DeviceLength','The length of the device, the actual device lenght might be different since the ends might be compensated','[m]');
execute(conn,sqlquery);

for iteration = 1:NumberOfDevices
sqlquery = sprintf('INSERT INTO %s (',DTablename);
sqlquery2 = 'Values (';
for i = 1:size(Paramnames,2)-1
    sqlquery = [sqlquery,Paramnames{i},','];
    sqlquery2 = sprintf([sqlquery2,'%d,'],Paramvalues{i});
end
i = i+1;
sqlquery = [sqlquery,Paramnames{i},')'];
sqlquery2 = sprintf([sqlquery2,'%d);\n'],Paramvalues{i});
sqlquery = [sqlquery,sqlquery2];
execute(conn,sqlquery);
end

if ~isequal(VPname,'Null') && ~isequal(VPname,'Membrane')
ParamStepSize = (DieParams.ParamsRange(2)-DieParams.ParamsRange(1))/(NumberOfDevices -1);
ListOfVP = [DieParams.ParamsRange(1):ParamStepSize:DieParams.ParamsRange(2)];
for i = 1:NumberOfDevices
    sqlquery = sprintf(['UPDATE %s\n'...
        '\tSET %s = %d\n'...
        '\tWHERE id = %i\n;'],DTablename, VPname, ListOfVP(i), i);
    execute(conn,sqlquery);
end
end

for i = 1:NumberOfDevices
    temp = sprintf('%02i',i);
    sqlquery = sprintf('SELECT DL, UL, NumofUC FROM %s WHERE id=''%i''',DTablename, i);
    result = fetch(conn,sqlquery);
    sqlquery = sprintf(['UPDATE %s\n'...
        '\tSET %s = %d,\n'...
        '\t%s = ''%s''\n'...
        '\tWHERE id = %i\n;'],DTablename, 'DeviceLength', result.DL(1)+result.NumofUC(1)*2*result.UL(1),'DeviceSN',[DieSN,'_',temp], i);
    execute(conn,sqlquery);
end

end
function [DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, Dienumber, WaferSN)
DieParams.ParamsIndex = ParamTable(VPname);
if ~isequal(DieParams.ParamsIndex(1), 0)
    DieParams.ParamsRange = [(1+RVRL)*DieParams.Params{DieParams.ParamsIndex(1)}{DieParams.ParamsIndex(2)}.value,...
        (1+RVRH)*DieParams.Params{DieParams.ParamsIndex(1)}{DieParams.ParamsIndex(2)}.value];
else
    DieParams.ParamsRange = [0,0];
end
DieParams.Ystep = Ystep;
DieParams.Yrange = Yrange;
DieParams.Dienumber = Dienumber;
DieParams.Diename = [WaferSN,'_',num2str(DieParams.Dienumber)];
NumberOfDevices = size([DieParams.Yrange(1):DieParams.Ystep:DieParams.Yrange(2)],2);
end
function conn = setupConn()
DSN = 'MariaDB_test';
username = 'shanhao';
userpwd = 'nepnep';
ServerAddress = '136.142.206.151';
port = 3306;
MariaDBConnection = configureJDBCDataSource('Vendor','MySQL');
MariaDBConnection = setConnectionOptions(MariaDBConnection,'DataSourceName',DSN,'Server',ServerAddress, ...
    'PortNumber',port,'JDBCDriverLocation','C:\Program Files\MATLAB\R2019b\java\jar\mysql-connector-java-5.1.48.jar');
status = testConnection(MariaDBConnection,username,userpwd);
saveAsJDBCDataSource(MariaDBConnection);
conn = database(DSN, username, userpwd);
end
function Init_BigTables(databasename,conn)
SQLscript = fopen('SQLtest.sql', 'w');
fprintf(SQLscript,sprintf('use %s;\n',databasename));
fprintf(SQLscript,'set names utf8;\n');
fprintf(SQLscript,'SET FOREIGN_KEY_CHECKS=0;\n');
fprintf(SQLscript,sprintf([...
    'DROP TABLE IF EXISTS Wafer;\n',...
    'CREATE TABLE Wafer\n',...
    '(\n',...
    'id INT AUTO_INCREMENT PRIMARY KEY,\n',...
    'WaferSN VARCHAR(30) UNIQUE,\n',...
    'GDSFilePath VARCHAR(255) UNIQUE\n',...
    ');\n\n']));
fprintf(SQLscript,sprintf([...
    'DROP TABLE IF EXISTS Die;\n',...
    'CREATE TABLE Die\n',...
    '(\n',...
    'id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,\n',...
    'DieSN VARCHAR(30) UNIQUE,\n',...
    'Wafer_id INT NOT NULL,\n',...
    'DesignedLength INT NOT NULL COMMENT ''[mm]'',\n',...
    'VariedParam VARCHAR(30),\n',...
    'NumberOfDevices TINYINT,\n',...
    'Synopsis TEXT,\n',...
    'FOREIGN KEY (Wafer_id) REFERENCES Wafer(id)\n',...
    ');\n\n']));
fprintf(SQLscript,sprintf([...
    'DROP TABLE IF EXISTS Device;\n',...
    'CREATE TABLE Device\n',...
    '(\n',...
    'id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,\n',...
    'DeviceSN VARCHAR(30) UNIQUE,\n',...
    'Die_id INT NOT NULL,\n',...
    'FOREIGN KEY (Die_id) REFERENCES Die(id)\n',...
    ');\n\n']));
fclose(SQLscript);
result = executeSQLScript(conn, 'sqltest.sql');
end
function newDiesParams = generateDiesfromData(DataPath,Dienumbers,DiesParams,WaferSN,conn,Tablename, DesignedLength)
load(DataPath);
Ystep = 200;%um
Yrange = [-1900,1900];%um

DieParams.Params = Result.params(Result.searchresult,1:2);
VPname = 'DL';
RVRL = -0.2;
RVRH = 0.2;
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, Dienumbers(1), WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('Vary defect Length from %s%% to +%s%%', num2str(RVRL*100), num2str(RVRH*100));
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, DesignedLength, Tablename, Synopsis);
clear Result;

load(DataPath);
VPname = 'UL';
Params = Result.params(Result.searchresult,1:2);
RVRL = Params{2}{1}.value-(Params{2}{7}.value+2*Params{2}{10}.value*tan(22.5*pi/180)+2*Params{2}{8}.value);
RVRL = max([-0.2, -RVRL]);
RVRH = 0.2;
clear Result;
DieParams.Params = Params;
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, Dienumbers(2), WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('Vary unit cell length from %s%% to +%s%%', num2str(RVRL*100), num2str(RVRH*100));
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, DesignedLength, Tablename, Synopsis);

load(DataPath);
VPname = 'UrecL';
Params = Result.params(Result.searchresult,1:2);
RVRL = (2+sqrt(2))*Params{2}{8}.value/Params{2}{7}.value;
RVRL = max([-0.2, -RVRL]);
RVRH = (Params{2}{1}.value-sqrt(2)&Params{2}{8}.value)/Params{2}{7}.value;
RVRH = min([0.2,RVRH]);
clear Result;
DieParams.Params = Params;
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, Dienumbers(3), WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('Vary width from %s%% to +%s%%', num2str(RVRL*100), num2str(RVRH*100));
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, DesignedLength, Tablename, Synopsis);


load(DataPath);
VPname = 'UrecW';
Params = Result.params(Result.searchresult,1:2);
RVRL = (Params{2}{8}.value-Params{2}{2}.value)/2;
RVRL = max([-0.2, -RVRL]);
RVRH = 0.2;
clear Result;
DieParams.Params = Params;
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, Dienumbers(4), WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('Vary UC width modulator length from %s%% to +%s%%', num2str(RVRL*100), num2str(RVRH*100));
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, DesignedLength, Tablename, Synopsis);

load(DataPath);
VPname = 'FilletR';
Params = Result.params(Result.searchresult,1:2);
RVRL = -0.7;
RVRH = 0;
clear Result;
DieParams.Params = Params;
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, Dienumbers(5), WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = sprintf('Vary FilletR from %s%% to +%s%%', num2str(RVRL*100), num2str(RVRH*100));
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, DesignedLength, Tablename, Synopsis);

load(DataPath);
VPname = 'Null';
Params = Result.params(Result.searchresult,1:2);
Params{2}{8}.value = Params{2}{2}.value;
RVRL = 0;
RVRH = 0;
clear Result;
DieParams.Params = Params;
[DieParams,NumberOfDevices] = PrepareDie(DieParams, VPname, RVRL, RVRH, Ystep, Yrange, Dienumbers(6), WaferSN);
DiesParams = [DiesParams, DieParams];
Synopsis = 'A bunch of trival straight beams';
LogDie(WaferSN, conn, DieParams, VPname, NumberOfDevices, DesignedLength, Tablename, Synopsis);

newDiesParams = DiesParams;
end