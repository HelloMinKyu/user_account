-- MySQL Administrator dump 1.4
--
-- ------------------------------------------------------
-- Server version	5.5.40


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


--
-- Create schema user_account
--

CREATE DATABASE IF NOT EXISTS user_account;
USE user_account;

--
-- Definition of table `admin`
--

DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin` (
  `id` varchar(50) NOT NULL,
  `pwd` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `admin`
--

/*!40000 ALTER TABLE `admin` DISABLE KEYS */;
INSERT INTO `admin` (`id`,`pwd`) VALUES 
 ('root','root');
/*!40000 ALTER TABLE `admin` ENABLE KEYS */;


--
-- Definition of table `member_info`
--

DROP TABLE IF EXISTS `member_info`;
CREATE TABLE `member_info` (
  `srno` int(11) NOT NULL AUTO_INCREMENT COMMENT 'È¸¿ø °íÀ¯¹øÈ£ (PK)',
  `name` varchar(50) NOT NULL COMMENT 'È¸¿ø¸í',
  `gender` char(10) DEFAULT NULL COMMENT '¼ºº° (³²/¿©)',
  `region` varchar(20) DEFAULT NULL COMMENT 'Áö¿ª',
  `grade` varchar(20) DEFAULT 'ÀÏ¹Ý' COMMENT 'È¸¿øµî±Þ',
  `birth` date DEFAULT NULL COMMENT '»ý³â¿ùÀÏ',
  `join_date` date DEFAULT NULL COMMENT '°¡ÀÔÀÏ',
  `note` varchar(255) DEFAULT NULL COMMENT 'Æ¯ÀÌ»çÇ×',
  `photo_path` varchar(255) DEFAULT NULL COMMENT 'È¸¿ø»çÁø °æ·Î',
  `reg_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT 'µî·ÏÀÏ½Ã',
  `photo_path2` varchar(255) DEFAULT NULL,
  `photo_path3` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`srno`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8 COMMENT='È¸¿ø°ü¸® Å×ÀÌºí';

--
-- Dumping data for table `member_info`
--

/*!40000 ALTER TABLE `member_info` DISABLE KEYS */;
INSERT INTO `member_info` (`srno`,`name`,`gender`,`region`,`grade`,`birth`,`join_date`,`note`,`photo_path`,`reg_date`,`photo_path2`,`photo_path3`) VALUES 
 (22,'85 상철','남','진주','부반장','1985-02-05','2024-04-19','','C:\\user_account\\22\\IMG_8666.jpeg','2025-11-05 19:17:35',NULL,NULL),
 (23,'84 남핑','남','진주','일반','1984-09-25','2025-11-06','',NULL,'2025-11-06 10:01:30',NULL,NULL),
 (24,'91 승현','남','마산','방장','2025-11-06','2025-11-06','','C:\\user_account\\24\\IMG_9950.png','2025-11-06 10:45:45',NULL,NULL),
 (26,'97 민규','남','진주','일반','1997-06-18','2025-11-08','','C:\\user_account\\26\\KakaoTalk_20251013_203803826.jpg','2025-11-08 10:58:22',NULL,NULL);
/*!40000 ALTER TABLE `member_info` ENABLE KEYS */;


--
-- Definition of table `schedule_info`
--

DROP TABLE IF EXISTS `schedule_info`;
CREATE TABLE `schedule_info` (
  `srno` bigint(20) NOT NULL AUTO_INCREMENT,
  `schedule_date` date NOT NULL,
  `leader` varchar(50) NOT NULL,
  `fund_members` varchar(255) DEFAULT NULL,
  `nonfund_members` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`srno`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `schedule_info`
--

/*!40000 ALTER TABLE `schedule_info` DISABLE KEYS */;
INSERT INTO `schedule_info` (`srno`,`schedule_date`,`leader`,`fund_members`,`nonfund_members`,`created_at`) VALUES 
 (2,'2025-11-05','박민규','철균','박민규, 두레1, 철균','2025-11-05 20:49:29'),
 (4,'2025-11-06','84 남핑, 85 상철, 91 승현','84 남핑, 85 상철, 91 승현, 96김영민, 박민규','91 승현, 박민규','2025-11-06 18:33:02'),
 (7,'2025-11-08','85 상철','84 남핑, 85 상철, 91 승현','91 승현','2025-11-08 09:24:05'),
 (8,'2025-11-09','97 민규','91 승현','84 남핑','2025-11-08 10:58:47');
/*!40000 ALTER TABLE `schedule_info` ENABLE KEYS */;


--
-- Definition of table `tbl_fund`
--

DROP TABLE IF EXISTS `tbl_fund`;
CREATE TABLE `tbl_fund` (
  `srno` bigint(20) NOT NULL AUTO_INCREMENT,
  `fund_date` date NOT NULL,
  `withdraw_amount` int(11) NOT NULL DEFAULT '0',
  `deposit_amount` int(11) NOT NULL DEFAULT '0',
  `balance_amount` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`srno`),
  UNIQUE KEY `uk_fund_date` (`fund_date`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

--
-- Dumping data for table `tbl_fund`
--

/*!40000 ALTER TABLE `tbl_fund` DISABLE KEYS */;
INSERT INTO `tbl_fund` (`srno`,`fund_date`,`withdraw_amount`,`deposit_amount`,`balance_amount`) VALUES 
 (1,'2025-10-01',0,5000,5000),
 (2,'2025-10-02',2000,0,-2000),
 (3,'2025-11-05',3000,10000,7000),
 (4,'2025-11-06',0,10000,10000),
 (5,'2025-11-07',10000,30000,20000);
/*!40000 ALTER TABLE `tbl_fund` ENABLE KEYS */;




/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
