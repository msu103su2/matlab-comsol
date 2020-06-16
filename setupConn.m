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