-- phpMyAdmin SQL Dump
-- version 5.2.0-rc1
-- https://www.phpmyadmin.net/
--
-- Počítač: localhost
-- Vytvořeno: Čtv 02. čen 2022, 20:55
-- Verze serveru: 10.3.34-MariaDB-0ubuntu0.20.04.1
-- Verze PHP: 8.0.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Databáze: `s12_framework_dev`
--

-- --------------------------------------------------------

--
-- Struktura tabulky `bank_access`
--

CREATE TABLE `bank_access` (
  `id` int(11) NOT NULL,
  `account` varchar(20) NOT NULL,
  `type` varchar(20) NOT NULL,
  `who` varchar(20) NOT NULL,
  `grade` smallint(6) NOT NULL,
  `priority` int(11) NOT NULL,
  `root` tinyint(4) NOT NULL,
  `view` tinyint(4) NOT NULL,
  `cards` tinyint(4) NOT NULL,
  `deposit` tinyint(4) NOT NULL,
  `withdraw` tinyint(4) NOT NULL,
  `edit` tinyint(4) NOT NULL,
  `send` tinyint(4) NOT NULL,
  `accesses` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `bank_accounts`
--

CREATE TABLE `bank_accounts` (
  `number` varchar(56) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '123456789',
  `name` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `founder` int(11) NOT NULL,
  `balance` bigint(20) NOT NULL DEFAULT 0,
  `free_card` tinyint(1) NOT NULL DEFAULT 1,
  `icon` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'fas fa-university'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `bank_cards`
--

CREATE TABLE `bank_cards` (
  `number` varchar(20) NOT NULL,
  `name` varchar(30) NOT NULL,
  `pin` varchar(4) NOT NULL,
  `withdraw_limit` int(11) NOT NULL DEFAULT 0,
  `account` varchar(56) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `bank_logs`
--

CREATE TABLE `bank_logs` (
  `id` int(11) NOT NULL,
  `source_acc` varchar(56) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` varchar(56) COLLATE utf8mb4_unicode_ci NOT NULL,
  `target_acc` varchar(56) COLLATE utf8mb4_unicode_ci NOT NULL,
  `negative` tinyint(4) NOT NULL,
  `char_id` int(11) NOT NULL,
  `balance` bigint(20) NOT NULL DEFAULT 0,
  `date` timestamp(1) NOT NULL DEFAULT current_timestamp(1) ON UPDATE current_timestamp(1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `banlist`
--

CREATE TABLE `banlist` (
  `id` int(11) NOT NULL,
  `admin_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci NOT NULL,
  `admin_identifiers` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `player_name` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci NOT NULL,
  `player_identifiers` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_initial` datetime NOT NULL DEFAULT current_timestamp(),
  `date_end` datetime NOT NULL,
  `reason` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci NOT NULL,
  `permanent` tinyint(4) NOT NULL DEFAULT 0,
  `unban` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `binds`
--

CREATE TABLE `binds` (
  `char_id` int(11) NOT NULL,
  `binds` longtext COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------
-- --------------------------------------------------------

--
-- Struktura tabulky `cardealer_vehicle`
--

CREATE TABLE `cardealer_vehicle` (
  `model` varchar(56) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(56) COLLATE utf8mb4_unicode_ci DEFAULT 'Missing',
  `price` int(20) NOT NULL DEFAULT 0,
  `maxspeed` decimal(10,0) NOT NULL DEFAULT 10,
  `seats` int(11) NOT NULL DEFAULT 4,
  `trunk` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '100',
  `class` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `manufacturer` varchar(56) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Tovota',
  `drivetrain` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'FWD',
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `license` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `blocked` int(1) DEFAULT 0,
  `addon` int(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `characters`
--

CREATE TABLE `characters` (
  `id` int(11) NOT NULL,
  `identifier` varchar(30) NOT NULL,
  `firstname` varchar(24) NOT NULL DEFAULT 'FIRSTNAME',
  `lastname` varchar(24) NOT NULL DEFAULT 'LASTNAME',
  `birth` varchar(12) NOT NULL DEFAULT 'DD/MM/YYYY',
  `sex` int(11) NOT NULL DEFAULT 0,
  `health` double NOT NULL DEFAULT 175,
  `logoff` int(11) NOT NULL DEFAULT 0,
  `armour` double NOT NULL DEFAULT 0,
  `jobs` longtext NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `jail` longtext NOT NULL DEFAULT '[]',
  `bonus` int(11) NOT NULL DEFAULT 0,
  `bossdata` varchar(512) NOT NULL,
  `needs` varchar(300) NOT NULL DEFAULT '[]',
  `outfit` longtext DEFAULT NULL,
  `tattoos` longtext NOT NULL DEFAULT '[]',
  `emotes` longtext NOT NULL,
  `skills` varchar(1000) NOT NULL DEFAULT '[]',
  `coords` longtext NOT NULL,
  `secret_token` varchar(100) NOT NULL,
  `in_property` varchar(54) NOT NULL DEFAULT '[]',
  `bank_accounts_left` int(11) NOT NULL DEFAULT 2,
  `created` timestamp NOT NULL DEFAULT current_timestamp(),
  `lastused` timestamp NULL DEFAULT current_timestamp(),
  `blocked` int(11) NOT NULL DEFAULT 0,
  `removed` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `clothes`
--

CREATE TABLE `clothes` (
  `id` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` longtext COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `consumables`
--

CREATE TABLE `consumables` (
  `id` int(100) NOT NULL,
  `label` text NOT NULL,
  `type` text NOT NULL,
  `description` text NOT NULL,
  `img` text NOT NULL,
  `unique2` tinyint(1) NOT NULL DEFAULT 0,
  `production` longtext NOT NULL DEFAULT '[]',
  `capacity` int(20) NOT NULL DEFAULT 700,
  `volume` int(20) NOT NULL DEFAULT 0,
  `restaurants` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '[]',
  `cost` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `daily_limits`
--

CREATE TABLE `daily_limits` (
  `char` smallint(6) NOT NULL,
  `day` date NOT NULL,
  `item` varchar(200) NOT NULL,
  `count` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `doors`
--

CREATE TABLE `doors` (
  `id` int(11) NOT NULL,
  `key_id` mediumtext NOT NULL,
  `text` longtext NOT NULL,
  `objects` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `locked` int(1) NOT NULL,
  `distance` int(10) NOT NULL,
  `note` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `drops`
--

CREATE TABLE `drops` (
  `coords` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastused` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `instance` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `drugs`
--

CREATE TABLE `drugs` (
  `id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `char_id` int(11) NOT NULL,
  `data` text COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `email_accounts`
--

CREATE TABLE `email_accounts` (
  `emailID` int(11) NOT NULL,
  `name` varchar(56) DEFAULT NULL,
  `password` varchar(56) DEFAULT NULL,
  `telephone` varchar(56) DEFAULT NULL,
  `data` longtext DEFAULT '[]',
  `last_logged` longtext DEFAULT '[]',
  `blocked` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `email_mails`
--

CREATE TABLE `email_mails` (
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

-- --------------------------------------------------------

--
-- Struktura tabulky `emsdb_calls`
--

CREATE TABLE `emsdb_calls` (
  `id` int(11) NOT NULL,
  `call_name` text DEFAULT NULL,
  `call_writer` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `call_date` datetime DEFAULT NULL,
  `call_place` text DEFAULT NULL,
  `call_intervening` text DEFAULT NULL,
  `call_participating` text DEFAULT NULL,
  `call_coop` text DEFAULT NULL,
  `call_relevance` int(11) DEFAULT NULL,
  `call_description` text DEFAULT NULL,
  `call_treatment` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `emsdb_coroner`
--

CREATE TABLE `emsdb_coroner` (
  `id` int(11) NOT NULL,
  `coroner` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `death_time` text DEFAULT NULL,
  `coroner_report` text DEFAULT NULL,
  `found` text DEFAULT NULL,
  `cause` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `emsdb_insurance`
--

CREATE TABLE `emsdb_insurance` (
  `id` int(11) NOT NULL,
  `by` int(11) DEFAULT NULL,
  `insurance_name` text DEFAULT NULL,
  `insurance_type` text DEFAULT NULL,
  `insurance_end` datetime DEFAULT NULL,
  `insurance_created` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `emsdb_log`
--

CREATE TABLE `emsdb_log` (
  `id` int(11) NOT NULL,
  `charid` int(11) DEFAULT NULL,
  `action` text DEFAULT NULL,
  `action_text` text DEFAULT NULL,
  `time` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `emsdb_medical_records`
--

CREATE TABLE `emsdb_medical_records` (
  `id` int(11) NOT NULL,
  `doctor` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `record_date` datetime DEFAULT NULL,
  `diagnosis` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `methods` text DEFAULT NULL,
  `medicament` text DEFAULT NULL,
  `team` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `emsdb_person`
--

CREATE TABLE `emsdb_person` (
  `id` int(11) NOT NULL,
  `charid` int(11) DEFAULT NULL,
  `doctor` int(11) DEFAULT NULL,
  `lastname` text DEFAULT NULL,
  `firstname` text DEFAULT NULL,
  `ssn` text DEFAULT NULL,
  `birthday` text DEFAULT NULL,
  `gender` text DEFAULT NULL,
  `address` text DEFAULT NULL,
  `blood_type` text DEFAULT NULL,
  `allergy` text DEFAULT NULL,
  `insurance_id` int(11) DEFAULT NULL,
  `contact` text DEFAULT NULL,
  `close_person` text DEFAULT NULL,
  `note` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `emsdb_psycho`
--

CREATE TABLE `emsdb_psycho` (
  `id` int(11) NOT NULL,
  `psycho` int(11) DEFAULT NULL,
  `person_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `psycho_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `emsdb_settings`
--

CREATE TABLE `emsdb_settings` (
  `setting_id` int(11) NOT NULL,
  `type` text DEFAULT NULL,
  `access_person` longtext DEFAULT '[]',
  `access_grades` longtext DEFAULT '[]',
  `all` tinyint(4) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `ems_examinations`
--

CREATE TABLE `ems_examinations` (
  `e_id` int(11) NOT NULL,
  `firstname` text NOT NULL,
  `lastname` text NOT NULL,
  `kind` longtext NOT NULL,
  `datetime` text NOT NULL,
  `solvable` int(1) NOT NULL,
  `solved` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `ems_insurances`
--

CREATE TABLE `ems_insurances` (
  `i_id` int(11) NOT NULL,
  `char_id` int(11) NOT NULL,
  `firstname` varchar(24) CHARACTER SET utf8 COLLATE utf8_czech_ci NOT NULL,
  `lastname` varchar(24) CHARACTER SET utf8 COLLATE utf8_czech_ci NOT NULL,
  `birth` varchar(12) CHARACTER SET utf8 COLLATE utf8_czech_ci NOT NULL,
  `from_date` date NOT NULL,
  `to_date` date NOT NULL,
  `id` int(11) NOT NULL,
  `infinity` tinyint(4) NOT NULL,
  `active` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `fddb_calls`
--

CREATE TABLE `fddb_calls` (
  `id` int(11) NOT NULL,
  `call_name` text DEFAULT NULL,
  `call_writer` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `call_date` datetime DEFAULT NULL,
  `call_place` text DEFAULT NULL,
  `call_intervening` text DEFAULT NULL,
  `call_participating` text DEFAULT NULL,
  `call_coop` text DEFAULT NULL,
  `call_relevance` int(11) DEFAULT NULL,
  `call_description` text DEFAULT NULL,
  `call_treatment` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `fddb_corporate`
--

CREATE TABLE `fddb_corporate` (
  `id` int(11) NOT NULL,
  `writer` int(11) DEFAULT NULL,
  `name` text DEFAULT NULL,
  `address` text DEFAULT NULL,
  `ceo` text DEFAULT NULL,
  `last_control` datetime DEFAULT NULL,
  `insurance_id` int(11) DEFAULT NULL,
  `contact` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `fddb_inspection`
--

CREATE TABLE `fddb_inspection` (
  `id` int(11) NOT NULL,
  `writer` int(11) DEFAULT NULL,
  `corporate_id` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `fddb_insurance`
--

CREATE TABLE `fddb_insurance` (
  `id` int(11) NOT NULL,
  `by` int(11) DEFAULT NULL,
  `insurance_name` text DEFAULT NULL,
  `insurance_type` text DEFAULT NULL,
  `insurance_end` datetime DEFAULT NULL,
  `insurance_created` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `fddb_log`
--

CREATE TABLE `fddb_log` (
  `id` int(11) NOT NULL,
  `charid` int(11) DEFAULT NULL,
  `action` text DEFAULT NULL,
  `action_text` text DEFAULT NULL,
  `time` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `fddb_settings`
--

CREATE TABLE `fddb_settings` (
  `setting_id` int(11) NOT NULL,
  `type` text DEFAULT NULL,
  `access_person` longtext DEFAULT NULL,
  `access_grades` longtext DEFAULT NULL,
  `all` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `fines`
--

CREATE TABLE `fines` (
  `id` int(11) NOT NULL,
  `label` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` int(11) NOT NULL,
  `person` int(11) NOT NULL,
  `officer` int(11) NOT NULL,
  `job` varchar(4) COLLATE utf8mb4_unicode_ci NOT NULL,
  `paid` int(11) NOT NULL DEFAULT 0,
  `date` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `fine_label`
--

CREATE TABLE `fine_label` (
  `name` varchar(56) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `paragraph` varchar(11) NOT NULL,
  `price_min` int(11) NOT NULL DEFAULT 1,
  `price_max` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktura tabulky `garages`
--

CREATE TABLE `garages` (
  `id` int(11) NOT NULL,
  `select_coords` varchar(512) COLLATE utf8mb4_czech_ci DEFAULT '',
  `spawn_locations` longtext COLLATE utf8mb4_czech_ci DEFAULT NULL,
  `owner` varchar(64) COLLATE utf8mb4_czech_ci DEFAULT 'public',
  `available` tinyint(4) DEFAULT 1,
  `type` varchar(16) COLLATE utf8mb4_czech_ci DEFAULT 'garage',
  `properties` varchar(256) COLLATE utf8mb4_czech_ci DEFAULT '',
  `job` varchar(256) COLLATE utf8mb4_czech_ci DEFAULT '',
  `postalcode` varchar(5) COLLATE utf8mb4_czech_ci NOT NULL,
  `houseId` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_czech_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `houses`
--

CREATE TABLE `houses` (
  `id` int(11) NOT NULL,
  `type` varchar(24) NOT NULL,
  `prices` text NOT NULL,
  `coords` mediumtext NOT NULL,
  `points` longtext NOT NULL,
  `mates` longtext NOT NULL,
  `settings` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `inventory`
--

CREATE TABLE `inventory` (
  `type` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `data` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `props` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '[]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `invoices`
--

CREATE TABLE `invoices` (
  `id` varchar(21) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` int(11) NOT NULL,
  `ownername` varchar(56) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Bez zadaného jména',
  `sender` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `sendername` varchar(54) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Bez zadaného jména',
  `senderchar` int(11) NOT NULL DEFAULT 0,
  `price` int(11) NOT NULL,
  `bank` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL,
  `items` text COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` int(11) NOT NULL,
  `paid` int(11) NOT NULL DEFAULT 0,
  `removed` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `items`
--

CREATE TABLE `items` (
  `name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(200) CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci NOT NULL,
  `type` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `class` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'unspecified',
  `weight` double NOT NULL,
  `rarity` smallint(6) NOT NULL DEFAULT 0,
  `removable` tinyint(4) NOT NULL,
  `usable` tinyint(4) NOT NULL,
  `destroyable` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `jobs`
--

CREATE TABLE `jobs` (
  `name` varchar(11) NOT NULL,
  `label` varchar(64) NOT NULL DEFAULT 'no name',
  `grades` longtext NOT NULL,
  `bank` varchar(12) NOT NULL DEFAULT '',
  `type` varchar(15) NOT NULL DEFAULT 'legal',
  `garages` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `requests` int(1) NOT NULL,
  `logs` longtext NOT NULL,
  `applications` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `licenses`
--

CREATE TABLE `licenses` (
  `charid` int(11) NOT NULL,
  `data` longtext COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `license_label`
--

CREATE TABLE `license_label` (
  `name` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(54) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `orders`
--

CREATE TABLE `orders` (
  `order` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Fa000001',
  `shop` int(20) NOT NULL,
  `ordered` int(50) NOT NULL,
  `delivered` int(50) NOT NULL,
  `bywho` varchar(56) COLLATE utf8mb4_unicode_ci NOT NULL,
  `products` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `price` int(11) NOT NULL,
  `recieved` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_address_history`
--

CREATE TABLE `pddb_address_history` (
  `id` int(11) NOT NULL,
  `charid` int(11) DEFAULT NULL,
  `address` varchar(150) DEFAULT NULL,
  `date_added` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_characters`
--

CREATE TABLE `pddb_characters` (
  `id` int(11) NOT NULL,
  `charid` int(11) DEFAULT NULL,
  `officer` int(11) DEFAULT NULL,
  `img` text DEFAULT NULL,
  `img2` text DEFAULT NULL,
  `caution` int(11) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp(),
  `phone` varchar(20) DEFAULT NULL,
  `address` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_criminalrecords`
--

CREATE TABLE `pddb_criminalrecords` (
  `id` int(11) NOT NULL,
  `citizen` int(11) NOT NULL,
  `officer` int(11) NOT NULL,
  `text` text CHARACTER SET utf8mb4 NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_documents`
--

CREATE TABLE `pddb_documents` (
  `id` int(11) NOT NULL,
  `creator` int(11) DEFAULT NULL,
  `owner` int(11) DEFAULT NULL,
  `access_person` longtext NOT NULL DEFAULT '[]',
  `primary_job` text DEFAULT NULL,
  `access_job_grade` longtext NOT NULL DEFAULT '[]',
  `name` text DEFAULT NULL,
  `sign` text DEFAULT NULL,
  `description` text DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_document_attachments`
--

CREATE TABLE `pddb_document_attachments` (
  `id` int(11) NOT NULL,
  `document_id` int(11) DEFAULT NULL,
  `writer` int(11) DEFAULT NULL,
  `type` text DEFAULT NULL,
  `content` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_log`
--

CREATE TABLE `pddb_log` (
  `id` int(11) NOT NULL,
  `charid` int(11) DEFAULT NULL,
  `action` text DEFAULT NULL,
  `action_text` text DEFAULT NULL,
  `time` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_notes`
--

CREATE TABLE `pddb_notes` (
  `uid` int(11) NOT NULL,
  `type` varchar(50) NOT NULL,
  `id` int(11) NOT NULL,
  `officer` int(11) NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_phone_history`
--

CREATE TABLE `pddb_phone_history` (
  `id` int(11) NOT NULL,
  `charid` int(11) DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `date_added` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_psc`
--

CREATE TABLE `pddb_psc` (
  `id` int(11) NOT NULL,
  `charid` int(11) DEFAULT NULL,
  `writer` int(11) DEFAULT NULL,
  `type` text DEFAULT NULL,
  `chart` int(11) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `date` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `pddb_wanted`
--

CREATE TABLE `pddb_wanted` (
  `uid` int(11) NOT NULL,
  `id` varchar(200) NOT NULL,
  `type` varchar(200) NOT NULL,
  `officer` int(11) NOT NULL,
  `datetime` datetime NOT NULL DEFAULT current_timestamp(),
  `state` tinyint(4) NOT NULL,
  `text` text CHARACTER SET utf8mb4 COLLATE utf8mb4_czech_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_ads`
--

CREATE TABLE `phone_ads` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `job` varchar(50) DEFAULT 'default',
  `author` varchar(255) DEFAULT NULL,
  `title` varchar(50) DEFAULT NULL,
  `content` varchar(512) DEFAULT NULL,
  `data` varchar(255) DEFAULT NULL,
  `image` varchar(255) NOT NULL DEFAULT '',
  `time` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_chats`
--

CREATE TABLE `phone_chats` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `number` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT 'Unknown',
  `muted` tinyint(1) DEFAULT 0,
  `lastOpened` bigint(20) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_contacts`
--

CREATE TABLE `phone_contacts` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `number` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL DEFAULT 'Unknown',
  `photo` varchar(512) DEFAULT '',
  `tag` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_darkgroups`
--

CREATE TABLE `phone_darkgroups` (
  `id` int(11) NOT NULL,
  `invitecode` varchar(50) DEFAULT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `photo` varchar(512) NOT NULL DEFAULT '',
  `maxmembers` int(11) DEFAULT 0,
  `members` mediumtext NOT NULL,
  `bannedmembers` mediumtext DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_darkmessages`
--

CREATE TABLE `phone_darkmessages` (
  `from` varchar(255) DEFAULT NULL,
  `to` int(11) DEFAULT NULL,
  `message` varchar(512) DEFAULT NULL,
  `attachments` mediumtext NOT NULL DEFAULT '[]',
  `time` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_groups`
--

CREATE TABLE `phone_groups` (
  `id` int(11) NOT NULL,
  `owner` varchar(255) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `photo` varchar(512) NOT NULL DEFAULT '',
  `members` mediumtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_mail`
--

CREATE TABLE `phone_mail` (
  `id` int(11) NOT NULL,
  `owner` varchar(128) DEFAULT NULL,
  `subject` varchar(50) DEFAULT NULL,
  `starred` tinyint(1) NOT NULL DEFAULT 0,
  `mail` longtext DEFAULT NULL,
  `trash` tinyint(1) NOT NULL DEFAULT 0,
  `muted` tinyint(1) NOT NULL DEFAULT 0,
  `lastOpened` bigint(20) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_mailaccounts`
--

CREATE TABLE `phone_mailaccounts` (
  `address` varchar(50) DEFAULT NULL,
  `name` varchar(50) DEFAULT NULL,
  `password` varchar(60) DEFAULT NULL,
  `photo` varchar(255) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_messages`
--

CREATE TABLE `phone_messages` (
  `from` varchar(255) DEFAULT NULL,
  `to` varchar(255) DEFAULT NULL,
  `message` varchar(512) DEFAULT NULL,
  `attachments` mediumtext NOT NULL DEFAULT '[]',
  `time` bigint(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_settings`
--

CREATE TABLE `phone_settings` (
  `id` varchar(50) DEFAULT NULL,
  `iban` varchar(50) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `twitteraccount` varchar(50) DEFAULT NULL,
  `settings` longtext DEFAULT NULL,
  `calls` longtext DEFAULT NULL,
  `notes` longtext DEFAULT NULL,
  `photos` longtext DEFAULT NULL,
  `darkchatuser` mediumtext DEFAULT NULL,
  `mailaccount` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_transactions`
--

CREATE TABLE `phone_transactions` (
  `id` int(11) NOT NULL,
  `from` varchar(255) DEFAULT NULL,
  `to` varchar(255) DEFAULT NULL,
  `amount` int(11) NOT NULL DEFAULT 0,
  `time` bigint(20) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_tweets`
--

CREATE TABLE `phone_tweets` (
  `id` int(11) NOT NULL,
  `reply` int(11) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `authorimg` varchar(255) DEFAULT NULL,
  `authorrank` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `content` varchar(255) DEFAULT NULL,
  `image` varchar(255) NOT NULL DEFAULT '',
  `views` int(11) NOT NULL DEFAULT 0,
  `likes` int(11) NOT NULL DEFAULT 0,
  `time` bigint(20) DEFAULT NULL,
  `likers` longtext NOT NULL DEFAULT '[]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `phone_twitteraccounts`
--

CREATE TABLE `phone_twitteraccounts` (
  `nickname` varchar(50) DEFAULT NULL,
  `email` varchar(50) DEFAULT NULL,
  `password` varchar(60) DEFAULT NULL,
  `picture` varchar(512) DEFAULT NULL,
  `rank` varchar(50) NOT NULL DEFAULT 'default'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `property`
--

CREATE TABLE `property` (
  `id` int(11) NOT NULL,
  `coords` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(24) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'motel',
  `rooms` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `races`
--

CREATE TABLE `races` (
  `identifier` varchar(255) NOT NULL,
  `nickname` varchar(80) DEFAULT NULL,
  `elo` int(11) DEFAULT 1200,
  `unitsDriven` float DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `register_weapons`
--

CREATE TABLE `register_weapons` (
  `serialnumber` varchar(16) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bought` int(11) NOT NULL,
  `type` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(10) COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `rob_houses`
--

CREATE TABLE `rob_houses` (
  `house` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `locked` tinyint(4) NOT NULL DEFAULT 0,
  `robbed` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `players` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastreset` int(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `shops`
--

CREATE TABLE `shops` (
  `id` int(11) NOT NULL,
  `coords` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `ped_coords` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  `rob_details` varchar(256) COLLATE utf8mb4_unicode_ci NOT NULL,
  `items` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'grocery'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `tattoos_list`
--

CREATE TABLE `tattoos_list` (
  `collection` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `label` varchar(50) NOT NULL,
  `sex` tinyint(4) NOT NULL,
  `zone` varchar(50) NOT NULL,
  `price` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `tebex_quepoints`
--

CREATE TABLE `tebex_quepoints` (
  `id` int(11) NOT NULL,
  `identifier` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `amount` int(11) NOT NULL,
  `until` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `tebex_things`
--

CREATE TABLE `tebex_things` (
  `identifier` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bank_account` int(11) NOT NULL DEFAULT 0,
  `plate` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `time_played`
--

CREATE TABLE `time_played` (
  `identifier` varchar(200) NOT NULL,
  `day` date NOT NULL,
  `minutes` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Struktura tabulky `twitter_accounts`
--

CREATE TABLE `twitter_accounts` (
  `accountId` int(20) NOT NULL,
  `twitterID` int(11) NOT NULL,
  `name` varchar(256) NOT NULL,
  `password` varchar(256) NOT NULL,
  `profilepicture` varchar(256) DEFAULT NULL,
  `lastloggedData` longtext NOT NULL,
  `lastlogged` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `blocked` tinyint(1) DEFAULT 0,
  `email` varchar(256) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `twitter_posts`
--

CREATE TABLE `twitter_posts` (
  `id` int(20) NOT NULL,
  `tweetID` int(11) DEFAULT NULL,
  `twitterID` int(11) NOT NULL,
  `name` varchar(50) NOT NULL,
  `message` varchar(256) NOT NULL,
  `data` longtext DEFAULT NULL,
  `picture` varchar(256) DEFAULT NULL,
  `image` varchar(50) DEFAULT NULL,
  `likes` longtext NOT NULL,
  `time` text NOT NULL,
  `hashtag` longtext DEFAULT NULL,
  `hashtag_handle` longtext DEFAULT NULL,
  `mentioned` longtext DEFAULT NULL,
  `deleted` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `users`
--

CREATE TABLE `users` (
  `identifier` varchar(56) NOT NULL,
  `name` varchar(128) NOT NULL DEFAULT 'not connected yet',
  `discord` varchar(50) NOT NULL,
  `lastconnected` timestamp NULL DEFAULT NULL,
  `chars_left` int(11) NOT NULL DEFAULT 1,
  `whitelisted` int(11) NOT NULL DEFAULT 0,
  `admin` int(11) NOT NULL DEFAULT 0,
  `settings` varchar(1000) NOT NULL DEFAULT '[]'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `vehicles`
--

CREATE TABLE `vehicles` (
  `spz` varchar(8) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'XXXXXXXX',
  `vin` varchar(17) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(128) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'job_admin',
  `in_garage` varchar(11) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '0',
  `type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'car',
  `data` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `blocked` int(1) NOT NULL,
  `bolo` int(11) DEFAULT 0,
  `jobdata` longtext COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `vip_money_history`
--

CREATE TABLE `vip_money_history` (
  `identifier` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `day` date NOT NULL,
  `amount` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `vip_until`
--

CREATE TABLE `vip_until` (
  `identifier` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `until` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `type` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `weather`
--

CREATE TABLE `weather` (
  `datetime` datetime NOT NULL,
  `temp` float NOT NULL,
  `weather` varchar(50) NOT NULL,
  `weather_id` int(11) NOT NULL,
  `description` varchar(50) NOT NULL,
  `icon` varchar(10) NOT NULL,
  `wind` float NOT NULL,
  `wind_direction` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Struktura tabulky `web_log`
--

CREATE TABLE `web_log` (
  `id` int(11) NOT NULL,
  `user` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `action` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `date_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `weed_plants`
--

CREATE TABLE `weed_plants` (
  `char_id` int(11) NOT NULL,
  `plant_id` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `plant_data` text COLLATE utf8mb4_unicode_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Struktura tabulky `whitelist_questions`
--

CREATE TABLE `whitelist_questions` (
  `id` int(11) NOT NULL,
  `question` varchar(500) NOT NULL,
  `answer` varchar(500) NOT NULL,
  `type` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 ROW_FORMAT=COMPACT;

--
-- Indexy pro exportované tabulky
--

--
-- Indexy pro tabulku `bank_access`
--
ALTER TABLE `bank_access`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `bank_accounts`
--
ALTER TABLE `bank_accounts`
  ADD PRIMARY KEY (`number`);

--
-- Indexy pro tabulku `bank_cards`
--
ALTER TABLE `bank_cards`
  ADD PRIMARY KEY (`number`);

--
-- Indexy pro tabulku `bank_logs`
--
ALTER TABLE `bank_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `banlist`
--
ALTER TABLE `banlist`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `binds`
--
ALTER TABLE `binds`
  ADD PRIMARY KEY (`char_id`);

--
-- Indexy pro tabulku `cardealer_vehicle`
--
ALTER TABLE `cardealer_vehicle`
  ADD PRIMARY KEY (`model`);

--
-- Indexy pro tabulku `characters`
--
ALTER TABLE `characters`
  ADD PRIMARY KEY (`id`) USING BTREE,
  ADD KEY `identifier_index` (`identifier`);

--
-- Indexy pro tabulku `clothes`
--
ALTER TABLE `clothes`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `consumables`
--
ALTER TABLE `consumables`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `daily_limits`
--
ALTER TABLE `daily_limits`
  ADD PRIMARY KEY (`char`,`day`,`item`) USING BTREE;

--
-- Indexy pro tabulku `doors`
--
ALTER TABLE `doors`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `drops`
--
ALTER TABLE `drops`
  ADD PRIMARY KEY (`coords`,`instance`) USING BTREE;

--
-- Indexy pro tabulku `drugs`
--
ALTER TABLE `drugs`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `email_accounts`
--
ALTER TABLE `email_accounts`
  ADD PRIMARY KEY (`emailID`),
  ADD UNIQUE KEY `mail_accounts_emailID_uindex` (`emailID`),
  ADD UNIQUE KEY `mail_accounts_name_uindex` (`name`);

--
-- Indexy pro tabulku `email_mails`
--
ALTER TABLE `email_mails`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `player_mails_emailID_uindex` (`mailID`);

--
-- Indexy pro tabulku `emsdb_calls`
--
ALTER TABLE `emsdb_calls`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `emsdb_calls_id_uindex` (`id`);

--
-- Indexy pro tabulku `emsdb_coroner`
--
ALTER TABLE `emsdb_coroner`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `emsdb_coroner_id_uindex` (`id`);

--
-- Indexy pro tabulku `emsdb_insurance`
--
ALTER TABLE `emsdb_insurance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `emsdb_insurance_id_uindex` (`id`);

--
-- Indexy pro tabulku `emsdb_log`
--
ALTER TABLE `emsdb_log`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `emsdb_log_id_uindex` (`id`);

--
-- Indexy pro tabulku `emsdb_medical_records`
--
ALTER TABLE `emsdb_medical_records`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `emsdb_medical_records_id_uindex` (`id`);

--
-- Indexy pro tabulku `emsdb_person`
--
ALTER TABLE `emsdb_person`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `emsdb_person_id_uindex` (`id`);

--
-- Indexy pro tabulku `emsdb_psycho`
--
ALTER TABLE `emsdb_psycho`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `emsdb_psycho_id_uindex` (`id`);

--
-- Indexy pro tabulku `emsdb_settings`
--
ALTER TABLE `emsdb_settings`
  ADD PRIMARY KEY (`setting_id`),
  ADD UNIQUE KEY `emsdb_settings_id_uindex` (`setting_id`),
  ADD UNIQUE KEY `emsdb_settings_setting_id_uindex` (`setting_id`);

--
-- Indexy pro tabulku `ems_examinations`
--
ALTER TABLE `ems_examinations`
  ADD PRIMARY KEY (`e_id`);

--
-- Indexy pro tabulku `ems_insurances`
--
ALTER TABLE `ems_insurances`
  ADD PRIMARY KEY (`i_id`);

--
-- Indexy pro tabulku `fddb_calls`
--
ALTER TABLE `fddb_calls`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fddb_calls_id_uindex` (`id`);

--
-- Indexy pro tabulku `fddb_corporate`
--
ALTER TABLE `fddb_corporate`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fddb_corporate_id_uindex` (`id`);

--
-- Indexy pro tabulku `fddb_inspection`
--
ALTER TABLE `fddb_inspection`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fddb_inspection_id_uindex` (`id`);

--
-- Indexy pro tabulku `fddb_insurance`
--
ALTER TABLE `fddb_insurance`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fddb_insurance_id_uindex` (`id`);

--
-- Indexy pro tabulku `fddb_log`
--
ALTER TABLE `fddb_log`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `fddb_log_id_uindex` (`id`);

--
-- Indexy pro tabulku `fddb_settings`
--
ALTER TABLE `fddb_settings`
  ADD PRIMARY KEY (`setting_id`),
  ADD UNIQUE KEY `fddb_settings_setting_id_uindex` (`setting_id`);

--
-- Indexy pro tabulku `fines`
--
ALTER TABLE `fines`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `fine_label`
--
ALTER TABLE `fine_label`
  ADD PRIMARY KEY (`name`);

--
-- Indexy pro tabulku `garages`
--
ALTER TABLE `garages`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `houses`
--
ALTER TABLE `houses`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`type`,`owner`);

--
-- Indexy pro tabulku `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `items`
--
ALTER TABLE `items`
  ADD PRIMARY KEY (`name`);

--
-- Indexy pro tabulku `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`name`);

--
-- Indexy pro tabulku `licenses`
--
ALTER TABLE `licenses`
  ADD PRIMARY KEY (`charid`);

--
-- Indexy pro tabulku `license_label`
--
ALTER TABLE `license_label`
  ADD PRIMARY KEY (`name`);

--
-- Indexy pro tabulku `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order`);

--
-- Indexy pro tabulku `pddb_address_history`
--
ALTER TABLE `pddb_address_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pddb_address_history_characters_id_fk` (`charid`);

--
-- Indexy pro tabulku `pddb_characters`
--
ALTER TABLE `pddb_characters`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pddb_charactrs_id_uindex` (`id`),
  ADD UNIQUE KEY `pddb_characters_charid_uindex` (`charid`);

--
-- Indexy pro tabulku `pddb_criminalrecords`
--
ALTER TABLE `pddb_criminalrecords`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `pddb_documents`
--
ALTER TABLE `pddb_documents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pddb_documents_id_uindex` (`id`);

--
-- Indexy pro tabulku `pddb_document_attachments`
--
ALTER TABLE `pddb_document_attachments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pddb_document_attachments_id_uindex` (`id`);

--
-- Indexy pro tabulku `pddb_log`
--
ALTER TABLE `pddb_log`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pddb_log_id_uindex` (`id`);

--
-- Indexy pro tabulku `pddb_notes`
--
ALTER TABLE `pddb_notes`
  ADD PRIMARY KEY (`uid`),
  ADD KEY `pddb_notes_characters_id_fk` (`id`);

--
-- Indexy pro tabulku `pddb_phone_history`
--
ALTER TABLE `pddb_phone_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pddb_phone_history_phone_index` (`phone`),
  ADD KEY `pddb_phone_history_characters_id_fk` (`charid`);

--
-- Indexy pro tabulku `pddb_psc`
--
ALTER TABLE `pddb_psc`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pddb_psc_id_uindex` (`id`);

--
-- Indexy pro tabulku `pddb_wanted`
--
ALTER TABLE `pddb_wanted`
  ADD PRIMARY KEY (`uid`);

--
-- Indexy pro tabulku `phone_ads`
--
ALTER TABLE `phone_ads`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexy pro tabulku `phone_chats`
--
ALTER TABLE `phone_chats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexy pro tabulku `phone_contacts`
--
ALTER TABLE `phone_contacts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexy pro tabulku `phone_darkgroups`
--
ALTER TABLE `phone_darkgroups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexy pro tabulku `phone_groups`
--
ALTER TABLE `phone_groups`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexy pro tabulku `phone_mail`
--
ALTER TABLE `phone_mail`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexy pro tabulku `phone_transactions`
--
ALTER TABLE `phone_transactions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexy pro tabulku `phone_tweets`
--
ALTER TABLE `phone_tweets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `id` (`id`);

--
-- Indexy pro tabulku `property`
--
ALTER TABLE `property`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `races`
--
ALTER TABLE `races`
  ADD PRIMARY KEY (`identifier`);

--
-- Indexy pro tabulku `register_weapons`
--
ALTER TABLE `register_weapons`
  ADD PRIMARY KEY (`serialnumber`);

--
-- Indexy pro tabulku `rob_houses`
--
ALTER TABLE `rob_houses`
  ADD PRIMARY KEY (`house`);

--
-- Indexy pro tabulku `shops`
--
ALTER TABLE `shops`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `tattoos_list`
--
ALTER TABLE `tattoos_list`
  ADD PRIMARY KEY (`collection`,`name`);

--
-- Indexy pro tabulku `tebex_quepoints`
--
ALTER TABLE `tebex_quepoints`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `tebex_things`
--
ALTER TABLE `tebex_things`
  ADD PRIMARY KEY (`identifier`);

--
-- Indexy pro tabulku `time_played`
--
ALTER TABLE `time_played`
  ADD PRIMARY KEY (`day`,`identifier`);

--
-- Indexy pro tabulku `twitter_accounts`
--
ALTER TABLE `twitter_accounts`
  ADD PRIMARY KEY (`accountId`),
  ADD UNIQUE KEY `twitter_accounts_twitterID_uindex` (`twitterID`),
  ADD UNIQUE KEY `twitter_accounts_name_uindex` (`name`);

--
-- Indexy pro tabulku `twitter_posts`
--
ALTER TABLE `twitter_posts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `twitter_posts_twitterID_uindex` (`tweetID`);

--
-- Indexy pro tabulku `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`identifier`);

--
-- Indexy pro tabulku `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`spz`);

--
-- Indexy pro tabulku `vip_money_history`
--
ALTER TABLE `vip_money_history`
  ADD PRIMARY KEY (`identifier`,`day`);

--
-- Indexy pro tabulku `vip_until`
--
ALTER TABLE `vip_until`
  ADD PRIMARY KEY (`identifier`,`type`) USING BTREE;

--
-- Indexy pro tabulku `weather`
--
ALTER TABLE `weather`
  ADD PRIMARY KEY (`datetime`);

--
-- Indexy pro tabulku `web_log`
--
ALTER TABLE `web_log`
  ADD PRIMARY KEY (`id`);

--
-- Indexy pro tabulku `weed_plants`
--
ALTER TABLE `weed_plants`
  ADD PRIMARY KEY (`plant_id`);

--
-- Indexy pro tabulku `whitelist_questions`
--
ALTER TABLE `whitelist_questions`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pro tabulky
--

--
-- AUTO_INCREMENT pro tabulku `bank_access`
--
ALTER TABLE `bank_access`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `bank_logs`
--
ALTER TABLE `bank_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `banlist`
--
ALTER TABLE `banlist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `characters`
--
ALTER TABLE `characters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `clothes`
--
ALTER TABLE `clothes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `consumables`
--
ALTER TABLE `consumables`
  MODIFY `id` int(100) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `doors`
--
ALTER TABLE `doors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `email_mails`
--
ALTER TABLE `email_mails`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `emsdb_calls`
--
ALTER TABLE `emsdb_calls`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `emsdb_coroner`
--
ALTER TABLE `emsdb_coroner`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `emsdb_insurance`
--
ALTER TABLE `emsdb_insurance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `emsdb_log`
--
ALTER TABLE `emsdb_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `emsdb_medical_records`
--
ALTER TABLE `emsdb_medical_records`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `emsdb_person`
--
ALTER TABLE `emsdb_person`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `emsdb_psycho`
--
ALTER TABLE `emsdb_psycho`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `emsdb_settings`
--
ALTER TABLE `emsdb_settings`
  MODIFY `setting_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `ems_examinations`
--
ALTER TABLE `ems_examinations`
  MODIFY `e_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `fddb_calls`
--
ALTER TABLE `fddb_calls`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `fddb_corporate`
--
ALTER TABLE `fddb_corporate`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `fddb_inspection`
--
ALTER TABLE `fddb_inspection`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `fddb_insurance`
--
ALTER TABLE `fddb_insurance`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `fddb_log`
--
ALTER TABLE `fddb_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `fddb_settings`
--
ALTER TABLE `fddb_settings`
  MODIFY `setting_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `fines`
--
ALTER TABLE `fines`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `houses`
--
ALTER TABLE `houses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_address_history`
--
ALTER TABLE `pddb_address_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_characters`
--
ALTER TABLE `pddb_characters`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_criminalrecords`
--
ALTER TABLE `pddb_criminalrecords`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_documents`
--
ALTER TABLE `pddb_documents`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_document_attachments`
--
ALTER TABLE `pddb_document_attachments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_log`
--
ALTER TABLE `pddb_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_notes`
--
ALTER TABLE `pddb_notes`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_phone_history`
--
ALTER TABLE `pddb_phone_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_psc`
--
ALTER TABLE `pddb_psc`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `pddb_wanted`
--
ALTER TABLE `pddb_wanted`
  MODIFY `uid` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `phone_ads`
--
ALTER TABLE `phone_ads`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `phone_chats`
--
ALTER TABLE `phone_chats`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `phone_contacts`
--
ALTER TABLE `phone_contacts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `phone_darkgroups`
--
ALTER TABLE `phone_darkgroups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `phone_groups`
--
ALTER TABLE `phone_groups`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `phone_mail`
--
ALTER TABLE `phone_mail`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `phone_transactions`
--
ALTER TABLE `phone_transactions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `phone_tweets`
--
ALTER TABLE `phone_tweets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `shops`
--
ALTER TABLE `shops`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `tebex_quepoints`
--
ALTER TABLE `tebex_quepoints`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `twitter_accounts`
--
ALTER TABLE `twitter_accounts`
  MODIFY `accountId` int(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `twitter_posts`
--
ALTER TABLE `twitter_posts`
  MODIFY `id` int(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `web_log`
--
ALTER TABLE `web_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT pro tabulku `whitelist_questions`
--
ALTER TABLE `whitelist_questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Omezení pro exportované tabulky
--

--
-- Omezení pro tabulku `pddb_address_history`
--
ALTER TABLE `pddb_address_history`
  ADD CONSTRAINT `pddb_address_history_characters_id_fk` FOREIGN KEY (`charid`) REFERENCES `characters` (`id`);

--
-- Omezení pro tabulku `pddb_characters`
--
ALTER TABLE `pddb_characters`
  ADD CONSTRAINT `pddb_characters_characters_id_fk` FOREIGN KEY (`charid`) REFERENCES `characters` (`id`);

--
-- Omezení pro tabulku `pddb_notes`
--
ALTER TABLE `pddb_notes`
  ADD CONSTRAINT `pddb_notes_characters_id_fk` FOREIGN KEY (`id`) REFERENCES `characters` (`id`);

--
-- Omezení pro tabulku `pddb_phone_history`
--
ALTER TABLE `pddb_phone_history`
  ADD CONSTRAINT `pddb_phone_history_characters_id_fk` FOREIGN KEY (`charid`) REFERENCES `characters` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
