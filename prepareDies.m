databasename = 'test';
DSN = 'MariaDB_test';
username = 'shanhao';
pwd = 'nepnep';
ServerAddress = '136.142.206.151';
host = 'PurdylabDATA';
port = 3306;
JDBCdriver = 'mysql-connector-java-5.1.48.jar';
MariaDBConnection = configureJDBCDataSource('Vendor','MySQL');
MariaDBConnection = setConnectionOptions(MariaDBConnection,'DataSourceName',DSN,'Server',ServerAddress, ...
    'PortNumber',port,'JDBCDriverLocation','C:\Program Files\MATLAB\R2019b\java\jar\mysql-connector-java-5.1.48.jar');
status = testConnection(MariaDBConnection,username,pwd);
saveAsJDBCDataSource(MariaDBConnection);
conn = database(DSN, username, pwd);
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
    'Wafer_id INT UNIQUE,\n',...
    'FOREIGN KEY (Wafer_id) REFERENCES Wafer(id)\n',...
    ');\n\n']));
fprintf(SQLscript,sprintf([...
    'DROP TABLE IF EXISTS Device;\n',...
    'CREATE TABLE Device\n',...
    '(\n',...
    'id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,\n',...
    'DeviceSN VARCHAR(30) UNIQUE,\n',...
    'Die_id INT UNIQUE,\n',...
    'FOREIGN KEY (Die_id) REFERENCES Die(id)\n',...
    ');\n\n']));
fprintf(SQLscript,'SET FOREIGN_KEY_CHECKS=1;\n');

WaferSN = '000';
Filename = WaferSN;

load('PSO\data.mat');
VPname = 'DL';
DieParams.Params = Result.params(Result.searchresult,1:2);
DieParams.ParamsIndex = ParamTable('DL');
RVR = 0.2;
DieParams.ParamsRange = [(1-RVR)*DieParams.Params{DieParams.ParamsIndex(1)}{DieParams.ParamsIndex(2)}.value,...
    (1+RVR)*DieParams.Params{DieParams.ParamsIndex(1)}{DieParams.ParamsIndex(2)}.value];
DieParams.Ystep = 200;%um
DieParams.Yrange = [-200,200];%um
DieParams.Dienumber = 25;
DieParams.Diename = [WaferSN,'_',num2str(DieParams.Dienumber)];
DiesParams = [DieParams];

load('PSO\data_1mm.mat');
VPname = 'DL';
DieParams.Params = Result.params(Result.searchresult,1:2);
DieParams.ParamsIndex = ParamTable(VPname);
RVR = 0.2;
DieParams.ParamsRange = [(1-RVR)*DieParams.Params{DieParams.ParamsIndex(1)}{DieParams.ParamsIndex(2)}.value,...
    (1+RVR)*DieParams.Params{DieParams.ParamsIndex(1)}{DieParams.ParamsIndex(2)}.value];
DieParams.Ystep = 200;%um
DieParams.Yrange = [-400,400];%um
DieParams.Dienumber = 24;
DieParams.Diename = [WaferSN,'_',num2str(DieParams.Dienumber)];
DiesParams = [DiesParams, DieParams];

%ToCNST(DiesParams, Filename, 6, 11, WaferSN);
result = executeSQLScript(conn, 'sqltest.sql');
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
end
end
function WriteDieInfo(SQLscript, DieParams)
fprintf(SQLscript,'');
end