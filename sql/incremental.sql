-- incremental changes to make original bouncer DB work in Django

-- primary keys
ALTER TABLE `mirror_ip_to_country` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE `mirror_location_mirror_map` DROP PRIMARY KEY ,ADD UNIQUE ( `location_id` , `mirror_id` ) ;
ALTER TABLE `mirror_location_mirror_map` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

ALTER TABLE `mirror_mirror_region_map` DROP PRIMARY KEY , ADD UNIQUE ( `mirror_id` , `region_id` );
ALTER TABLE `mirror_mirror_region_map` ADD `id` INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY FIRST;

-- boolean fields
ALTER TABLE `mirror_location_mirror_map` CHANGE `location_active` `location_active` TINYINT NOT NULL DEFAULT '0' ;
UPDATE `mirror_location_mirror_map` SET location_active = 0 WHERE location_active = 1;
UPDATE `mirror_location_mirror_map` SET location_active = 1 WHERE location_active = 2;
ALTER TABLE `mirror_mirrors` CHANGE `mirror_active` `mirror_active` TINYINT NOT NULL DEFAULT '0' ;
UPDATE `mirror_mirrors` SET mirror_active = 0 WHERE mirror_active = 1;
UPDATE `mirror_mirrors` SET mirror_active = 1 WHERE mirror_active = 2;
ALTER TABLE `mirror_products` CHANGE `product_active` `product_active` TINYINT NOT NULL DEFAULT '1' ;
UPDATE `mirror_products` SET product_active = 0 WHERE product_active = 1;
UPDATE `mirror_products` SET product_active = 1 WHERE product_active = 2;

-- foreign keys
ALTER TABLE `mirror_country_to_region` CHANGE `region_id` `region_id` INT( 10 ) UNSIGNED NULL DEFAULT NULL;
UPDATE `mirror_country_to_region` SET region_id = NULL WHERE region_id = 0;
ALTER TABLE `mirror_regions`  ENGINE =  InnoDB;
ALTER TABLE `mirror_country_to_region` ADD FOREIGN KEY ( `region_id` ) REFERENCES `mirror_regions` (`region_id`) ON DELETE SET NULL ;

-- converted users
ALTER TABLE `mirror_users` ADD `converted` TINYINT NOT NULL DEFAULT '0';

-- flatten language table (bug 538975)
ALTER TABLE `mirror_locations`  ENGINE = InnoDB DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
ALTER TABLE `mirror_locations` ADD `lang` VARCHAR( 10 ) NULL , ADD INDEX ( `lang` ) ;
UPDATE `mirror_locations` AS loc LEFT JOIN mirror_langs AS lang ON (loc.lang_id = lang.lang_id) SET loc.lang = lang.lang;
ALTER TABLE `mirror_locations` DROP `lang_id`;
DROP TABLE `mirror_langs`;

-- remove column prefixes (bug 538988)
ALTER TABLE `mirror_locations` CHANGE `location_id` `id` INT( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT , CHANGE `location_path` `path` VARCHAR( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '';
ALTER TABLE `mirror_location_mirror_map` CHANGE `location_active` `active` TINYINT( 4 ) NOT NULL DEFAULT '0';
ALTER TABLE `mirror_mirrors` CHANGE `mirror_id` `id` INT( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT ,
CHANGE `mirror_name` `name` VARCHAR( 64 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
CHANGE `mirror_baseurl` `baseurl` VARCHAR( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
CHANGE `mirror_rating` `rating` INT( 11 ) NOT NULL DEFAULT '0',
CHANGE `mirror_active` `active` TINYINT( 4 ) NOT NULL DEFAULT '0',
CHANGE `mirror_count` `count` BIGINT( 20 ) UNSIGNED NOT NULL DEFAULT '0';
ALTER TABLE `mirror_os` CHANGE `os_id` `id` INT( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT ,
CHANGE `os_name` `name` VARCHAR( 32 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
CHANGE `os_priority` `priority` INT( 11 ) NOT NULL DEFAULT '0';
ALTER TABLE `mirror_products` CHANGE `product_id` `id` INT( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT ,
CHANGE `product_name` `name` VARCHAR( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
CHANGE `product_priority` `priority` INT( 11 ) NOT NULL DEFAULT '0',
CHANGE `product_count` `count` BIGINT( 20 ) UNSIGNED NOT NULL DEFAULT '0',
CHANGE `product_active` `active` TINYINT( 4 ) NOT NULL DEFAULT '1',
CHANGE `product_checknow` `checknow` TINYINT( 1 ) UNSIGNED NOT NULL DEFAULT '1';
ALTER TABLE `mirror_country_to_region` DROP FOREIGN KEY `mirror_country_to_region_ibfk_1`  ;
ALTER TABLE `mirror_regions` CHANGE `region_id` `id` INT( 10 ) UNSIGNED NOT NULL AUTO_INCREMENT ,
CHANGE `region_name` `name` VARCHAR( 255 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
CHANGE `region_priority` `priority` INT( 11 ) NOT NULL DEFAULT '0',
CHANGE `region_throttle` `throttle` INT( 11 ) NOT NULL ;
ALTER TABLE `mirror_country_to_region` ADD FOREIGN KEY ( `region_id` ) REFERENCES `mirror_regions` (`id`) ON DELETE SET NULL ;
RENAME TABLE `mirror_mirror_region_map`   TO `geoip_mirror_region_map`  ;
RENAME TABLE `mirror_country_to_region`   TO `geoip_country_to_region`  ;
RENAME TABLE `mirror_ip_to_country`   TO `geoip_ip_to_country` ;
RENAME TABLE `mirror_regions`  TO `geoip_regions` ;

