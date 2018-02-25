CREATE DATABASE vmail
  CHARACTER SET 'utf8';

GRANT SELECT ON vmail.* TO 'vmail'@'localhost'
IDENTIFIED BY 'placeholder';

USE vmail;

CREATE TABLE `domains` (
  `id`     INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `domain` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY (`domain`)
);

CREATE TABLE `accounts` (
  `id`       INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(64)  NOT NULL,
  `domain`   VARCHAR(255) NOT NULL,
  `password` VARCHAR(255) NOT NULL,
  `quota`    INT UNSIGNED          DEFAULT '0',
  `enabled`  BOOLEAN               DEFAULT '0',
  `sendonly` BOOLEAN               DEFAULT '0',
  PRIMARY KEY (id),
  UNIQUE KEY (`username`, `domain`),
  FOREIGN KEY (`domain`) REFERENCES `domains` (`domain`)
);

CREATE TABLE `aliases` (
  `id`                   INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `source_username`      VARCHAR(64)  NOT NULL,
  `source_domain`        VARCHAR(255) NOT NULL,
  `destination_username` VARCHAR(64)  NOT NULL,
  `destination_domain`   VARCHAR(255) NOT NULL,
  `enabled`              BOOLEAN               DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY (`source_username`, `source_domain`, `destination_username`, `destination_domain`),
  FOREIGN KEY (`source_domain`) REFERENCES `domains` (`domain`)
);

CREATE TABLE `tlspolicies` (
  `id`     INT UNSIGNED                                                                            NOT NULL AUTO_INCREMENT,
  `domain` VARCHAR(255)                                                                            NOT NULL,
  `policy` ENUM ('none', 'may', 'encrypt', 'dane', 'dane-only', 'fingerprint', 'verify', 'secure') NOT NULL,
  `params` VARCHAR(255),
  PRIMARY KEY (`id`),
  UNIQUE KEY (`domain`)
);
