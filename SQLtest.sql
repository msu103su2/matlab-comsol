use test;
set names utf8;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS Wafer;
CREATE TABLE Wafer
(
id INT AUTO_INCREMENT PRIMARY KEY,
WaferSN VARCHAR(30) UNIQUE,
GDSFilePath VARCHAR(255) UNIQUE
);

DROP TABLE IF EXISTS Die;
CREATE TABLE Die
(
id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
DieSN VARCHAR(30) UNIQUE,
Wafer_id INT NOT NULL,
DesignedLength INT NOT NULL COMMENT '[mm]',
VariedParam VARCHAR(30),
NumberOfDevices TINYINT,
Synopsis TEXT,
FOREIGN KEY (Wafer_id) REFERENCES Wafer(id)
);

DROP TABLE IF EXISTS Device;
CREATE TABLE Device
(
id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
DeviceSN VARCHAR(30) UNIQUE,
Die_id INT NOT NULL,
FOREIGN KEY (Die_id) REFERENCES Die(id)
);
