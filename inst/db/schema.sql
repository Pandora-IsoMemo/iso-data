-- --------------------------------------------------------
-- Host:                         inwt-db1.inwt.de
-- Server Version:               10.2.18-MariaDB-1:10.2.18+maria~bionic - mariadb.org binary distribution
-- Server Betriebssystem:        debian-linux-gnu
-- HeidiSQL Version:             9.3.0.5116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Exportiere Datenbank Struktur für mpiIso
CREATE DATABASE IF NOT EXISTS `mpiIso` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `mpiIso`;

-- Exportiere Struktur von Tabelle mpiIso.data
CREATE TABLE IF NOT EXISTS `data` (
  `source` varchar(50) NOT NULL,
  `id` varchar(50) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `d13C` decimal(12,6) DEFAULT NULL,
  `d15N` decimal(12,6) DEFAULT NULL,
  `latitude` decimal(7,4) DEFAULT NULL,
  `longitude` decimal(7,4) DEFAULT NULL,
  `site` varchar(100) DEFAULT NULL,
  `dateMean` decimal(12,4) DEFAULT NULL,
  `dateLower` decimal(12,4) DEFAULT NULL,
  `dateUpper` decimal(12,4) DEFAULT NULL,
  `dateUncertainty` decimal(12,4) DEFAULT NULL,
  `datingType` varchar(50) DEFAULT NULL,
  `calibratedDate` decimal(12,4) DEFAULT NULL,
  `calibratedDateLower` decimal(12,4) DEFAULT NULL,
  `calibratedDateUpper` decimal(12,4) DEFAULT NULL,
  PRIMARY KEY (`source`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle mpiIso.extraCharacter
CREATE TABLE IF NOT EXISTS `extraCharacter` (
  `mappingId` varchar(50) NOT NULL,
  `source` varchar(50) NOT NULL,
  `id` varchar(100) NOT NULL,
  `variable` varchar(100) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`source`,`id`,`variable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle mpiIso.extraNumeric
CREATE TABLE IF NOT EXISTS `extraNumeric` (
  `mappingId` varchar(50) NOT NULL,
  `source` varchar(50) NOT NULL,
  `id` varchar(100) NOT NULL,
  `variable` varchar(100) NOT NULL,
  `value` decimal(20,4) DEFAULT NULL,
  PRIMARY KEY (`source`,`id`,`variable`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle mpiIso.mapping
CREATE TABLE IF NOT EXISTS `mapping` (
  `mappingId` varchar(50) NOT NULL,
  `shiny` varchar(50) NOT NULL,
  `fieldType` varchar(50) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`shiny`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle mpiIso.updated
CREATE TABLE IF NOT EXISTS `updated` (
  `mappingId` varchar(50) NOT NULL,
  `source` varchar(50) NOT NULL,
  `timestamp` datetime NOT NULL,
  `rows` int(10) DEFAULT NULL,
  PRIMARY KEY (`source`,`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Daten Export vom Benutzer nicht ausgewählt
-- Exportiere Struktur von Tabelle mpiIso.warning
CREATE TABLE IF NOT EXISTS `warning` (
  `mappingId` varchar(50) NOT NULL,
  `source` varchar(50) NOT NULL,
  `id` varchar(50) NOT NULL,
  `warning` varchar(255) NOT NULL,
  PRIMARY KEY (`source`,`id`,`warning`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Daten Export vom Benutzer nicht ausgewählt
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
