DROP TABLE `phone_adverts`
DROP TABLE `player_mails`
DROP TABLE `mail_accounts`
DROP TABLE `phone_services`
DROP TABLE `simcard`
DROP TABLE `phone_racing`
DROP TABLE `phone_messages`

CREATE TABLE IF NOT EXISTS `phone_adverts` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `job` varchar(50) DEFAULT 'default',
  `author` varchar(255) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `content` varchar(512) DEFAULT NULL,
  `data` varchar(255) DEFAULT NULL,
  `image` varchar(255) NOT NULL DEFAULT '',
  `expired` varchar(255) NOT NULL DEFAULT 'false',
  `time` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `player_mails` (
  `id` int(11) NOT NULL,
  `mailID` int(11) DEFAULT NULL,
  `emailID` int(10) NOT NULL,
  `reciever` varchar(50) NOT NULL,
  `sender` varchar(50) DEFAULT NULL,
  `subject` longtext DEFAULT NULL,
  `message` text DEFAULT NULL,
  `data` longtext DEFAULT NULL,
  `read` tinyint(1) DEFAULT 0,
  `sender_deleted` tinyint(1) DEFAULT 0,
  `reciever_deleted` tinyint(1) DEFAULT NULL,
  `date` text DEFAULT NULL,
  `button` longtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `mail_accounts` (
  `emailID` int(11) NOT NULL,
  `name` varchar(56) DEFAULT NULL,
  `password` varchar(56) DEFAULT NULL,
  `telephone` varchar(56) DEFAULT NULL,
  `data` longtext DEFAULT '[]',
  `last_logged` longtext DEFAULT '[]',
  `blocked` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE IF NOT EXISTS `phone_services` (
    `id` INT (11) NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL,
    `messages` TEXT NOT NULL,
    `created` TIMESTAMP NOT NULL DEFAULT current_timestamp(),
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE `simcard` (
    `id` INT (11) NOT NULL AUTO_INCREMENT,
    `simid` VARCHAR(200) COLLATE utf8mb4_unicode_ci NOT NULL,
    `telephoneNumber` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL,
    `ip` VARCHAR(20) COLLATE utf8mb4_unicode_ci NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `unique_simid` (`simid`),
    UNIQUE KEY `unique_telephoneNumber` (`telephoneNumber`),
    UNIQUE KEY `unique_ip` (`ip`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE `phone_racing` (
    `charid` INT (11) NOT NULL,
    `races` TEXT COLLATE utf8mb4_unicode_ci NOT NULL,
    `routes` TEXT COLLATE utf8mb4_unicode_ci NOT NULL,
    PRIMARY KEY (`charid`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `phone_messages` (
  `simid` INT(11) NOT NULL,
  `number` VARCHAR(255) NOT NULL,
  `target` VARCHAR(255) NOT NULL,
  `messages` TEXT NOT NULL,
  `time` BIGINT(20) DEFAULT NULL,
  PRIMARY KEY (`simid`, `number`, `target`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;