CREATE TABLE IF NOT EXISTS AddressFamily (
  id INT(1) NOT NULL COMMENT '',
  acronym VARCHAR(4) COLLATE utf8_unicode_ci NOT NULL COMMENT '',
  name VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL COMMENT '',
  remarks VARCHAR(255) COLLATE utf8_unicode_ci NULL COMMENT '',
  PRIMARY KEY(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO AddressFamily (id, acronym, name, remarks) 
VALUES (4, 'IPv4', 'Internet Protocol version 4', NULL);
INSERT INTO AddressFamily (id, acronym, name, remarks) 
VALUES (6, 'IPv6', 'Internet Protocol version 6', NULL);

CREATE TABLE IF NOT EXISTS Protocol (
  acronym VARCHAR(4) COLLATE utf8_unicode_ci NOT NULL COMMENT '',
  name VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL COMMENT '',
  tcp_ip_layer VARCHAR(255) COLLATE utf8_unicode_ci NULL COMMENT '',
  is_connectionless TINYINT(1) NULL COMMENT '',
  remarks VARCHAR(255) COLLATE utf8_unicode_ci NULL COMMENT '',
  PRIMARY KEY(acronym)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO Protocol (acronym, name, tcp_ip_layer, is_connectionless, remarks) 
VALUES ('UDP', 'User Datagram Protocol', 'Transport', 1, NULL);
INSERT INTO Protocol (acronym, name, tcp_ip_layer, is_connectionless, remarks) 
VALUES ('ICMP', 'Internet Control Message Protocol', 'Internet', 1, NULL);
INSERT INTO Protocol (acronym, name, tcp_ip_layer, is_connectionless, remarks) 
VALUES ('TCP', 'Transmission Control Protocol', 'Transport', 0, NULL);

CREATE TABLE IF NOT EXISTS RegionalInternetRegistry (
  fullname VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL COMMENT '',
  acronym VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL COMMENT '',
  region VARCHAR(255) COLLATE utf8_unicode_ci NULL COMMENT '',
  remarks MEDIUMTEXT COLLATE utf8_unicode_ci NULL COMMENT '',
  PRIMARY KEY(acronym)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO RegionalInternetRegistry (fullname, acronym, region, remarks) 
VALUES ('African Network Information Center', 'AFRINIC', 'Africa', NULL);
INSERT INTO RegionalInternetRegistry (fullname, acronym, region, remarks) 
VALUES ('American Registry for Internet Numbers', 'ARIN', 'United States, Canada, several parts of the Caribbean region, and Antarctica', NULL);
INSERT INTO RegionalInternetRegistry (fullname, acronym, region, remarks) 
VALUES ('Asia-Pacific Network Information Centre', 'APNIC', 'Asia, Australia, New Zealand, and neighboring countries', NULL);
INSERT INTO RegionalInternetRegistry (fullname, acronym, region, remarks) 
VALUES ('Latin America and Caribbean Network Information Centre', 'LACNIC', 'Latin America and parts of the Caribbean region', NULL);
INSERT INTO RegionalInternetRegistry (fullname, acronym, region, remarks) 
VALUES ('Réseaux IP Européens Network Coordination Centre', 'RIPE NCC', 'Europe, Russia, the Middle East, and Central Asia', NULL);

CREATE TABLE IF NOT EXISTS ProbeSelectionType (
  probe_selection_type VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'probe selection type',
  description VARCHAR(255) COLLATE utf8_unicode_ci NULL COMMENT '',
  remarks VARCHAR(255) COLLATE utf8_unicode_ci NULL COMMENT '',
  PRIMARY KEY(probe_selection_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO ProbeSelectionType (probe_selection_type, description, remarks) VALUES ('probes', NULL, NULL);
INSERT INTO ProbeSelectionType (probe_selection_type, description, remarks) VALUES ('area', NULL, NULL);
INSERT INTO ProbeSelectionType (probe_selection_type, description, remarks) VALUES ('country', NULL, NULL);
INSERT INTO ProbeSelectionType (probe_selection_type, description, remarks) VALUES ('prefix', NULL, NULL);
INSERT INTO ProbeSelectionType (probe_selection_type, description, remarks) VALUES ('asn', NULL, NULL);
INSERT INTO ProbeSelectionType (probe_selection_type, description, remarks) VALUES ('complex', NULL, NULL);

CREATE TABLE IF NOT EXISTS Country (
  name_german VARCHAR(255) NULL COMMENT 'name in German',
  name_english VARCHAR(255) NULL COMMENT 'name in English',
  name_french VARCHAR(255) NULL COMMENT 'name in French',
  name_italian VARCHAR(255) NULL COMMENT 'name in Italian',
  code_iso_alpha_2 VARCHAR(2) NOT NULL COMMENT 'country code according to ISO 3166-1 alpha-2',
  code_iso_alpha_3 VARCHAR(3) NULL COMMENT 'country code according to ISO 3166-1 alpha-3',
  code_iso_numeric INT(3) NULL COMMENT 'country code according to ISO 3166-1 numeric',
  code_ioc VARCHAR(255) NULL COMMENT 'country code according International Olympic Commitee (IOC)',
  tld VARCHAR(3) NULL COMMENT 'country code top level domain (RFC 1591)',
  year_assigned INT(4) NULL COMMENT 'year when  ISO 3166-1 alpha-2 code was first officially assigned',
  obsolete TINYINT(1) NULL COMMENT 'whether the code is obsolete',
  remarks MEDIUMTEXT NULL,
  PRIMARY KEY(code_iso_alpha_2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS CountryGroup (
  id INTEGER NOT NULL,
  name VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL,
  description VARCHAR(255) COLLATE utf8_unicode_ci NULL,
  remarks VARCHAR(255) COLLATE utf8_unicode_ci NULL,
  PRIMARY KEY(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

INSERT INTO CountryGroup (id, name, description, remarks) 
VALUES (10, 'Schengener Abkommen', NULL, NULL);
INSERT INTO CountryGroup (id, name, description, remarks) 
VALUES (11, 'Europäische Union', NULL, NULL);

CREATE TABLE IF NOT EXISTS IPRange_belongs_to_Country (
  ip_from BIGINT UNSIGNED NOT NULL COMMENT '..',
  ip_to BIGINT UNSIGNED NOT NULL COMMENT '..',
  country_code VARCHAR(2) COLLATE utf8_unicode_ci NULL COMMENT 'country code according to ISO 3166-1 alpha-2',
  assigning_rir VARCHAR(255) COLLATE utf8_unicode_ci NULL COMMENT '..',
  assigning_date DATE NULL COMMENT '..',
  source VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'source of data',
  is_reserved TINYINT(1) DEFAULT 0 COMMENT 'is a reserved ip address space',
  remarks MEDIUMTEXT COLLATE utf8_unicode_ci NULL,
  PRIMARY KEY(ip_from, ip_to, source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

ALTER TABLE `IPRange_belongs_to_Country` ADD INDEX(`country_code`);
ALTER TABLE `IPRange_belongs_to_Country` ADD INDEX(`assigning_rir`);

ALTER TABLE `IPRange_belongs_to_Country`
  ADD CONSTRAINT `ip2c_1` FOREIGN KEY (`country_code`) REFERENCES `Country`(`code_iso_alpha_2`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `IPRange_belongs_to_Country`
  ADD CONSTRAINT `ip2c_2` FOREIGN KEY (`assigning_rir`) REFERENCES `RegionalInternetRegistry`(`acronym`) ON DELETE NO ACTION ON UPDATE NO ACTION;

INSERT INTO IPRange_belongs_to_Country (ip_from, ip_to, country_code, assigning_rir, assigning_date, source, is_reserved, remarks) 
VALUES (0, 16777215, NULL, NULL, NULL, 'IANA', 1, '0.0.0.0/8; 0.0.0.0 – 0.255.255.255; broadcast messages to the current network (RFC 1700, page 4)');
INSERT INTO IPRange_belongs_to_Country (ip_from, ip_to, country_code, assigning_rir, assigning_date, source, is_reserved, remarks) 
VALUES (167772160, 184549375, NULL, NULL, NULL, 'IANA', 1, '10.0.0.0/8; 10.0.0.0 – 10.255.255.255; private network; local communications within a private network (RFC 1918)');
INSERT INTO IPRange_belongs_to_Country (ip_from, ip_to, country_code, assigning_rir, assigning_date, source, is_reserved, remarks) 
VALUES (2130706432, 2147483647, NULL, NULL, NULL, 'IANA', 1, '127.0.0.0/8; 127.0.0.0 – 127.255.255.255; loopback addresses to the local host (RFC 990)');
INSERT INTO IPRange_belongs_to_Country (ip_from, ip_to, country_code, assigning_rir, assigning_date, source, is_reserved, remarks) 
VALUES (2886729728, 2887778303, NULL, NULL, NULL, 'IANA', 1, '172.16.0.0/12; 172.16.0.0 – 172.31.255.255; private network; local communications within a private network (RFC 1918)');
INSERT INTO IPRange_belongs_to_Country (ip_from, ip_to, country_code, assigning_rir, assigning_date, source, is_reserved, remarks) 
VALUES (3221225472, 3221225727, NULL, NULL, NULL, 'IANA', 1, '192.0.0.0/24; 192.0.0.0 – 192.0.0.255; private network; IANA IPv4 Special Purpose Address Registry (RFC 5736)');
INSERT INTO IPRange_belongs_to_Country (ip_from, ip_to, country_code, assigning_rir, assigning_date, source, is_reserved, remarks) 
VALUES (3232235520, 3232301055, NULL, NULL, NULL, 'IANA', 1, '192.168.0.0/16; 192.168.0.0 – 192.168.255.255; private network; local communications within a private network (RFC 1918)');
INSERT INTO IPRange_belongs_to_Country (ip_from, ip_to, country_code, assigning_rir, assigning_date, source, is_reserved, remarks) 
VALUES (4294967295, 4294967295, NULL, NULL, NULL, 'IANA', 1, '255.255.255.255/32; 255.255.255.255; limited broadcast destination address (RFC 6890)');

CREATE TABLE IF NOT EXISTS AutonomousSystem (
  asn int(6) NOT NULL COMMENT 'IANA autonomous system number',
  name VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'Name of autonomous system',
  owner VARCHAR(255) COLLATE utf8_unicode_ci NULL,
  country_code VARCHAR(2) COLLATE utf8_unicode_ci NULL,
  registration_date DATE NULL,
  source VARCHAR(255) COLLATE utf8_unicode_ci NOT NULL COMMENT 'source of data',
  PRIMARY KEY(asn, source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

ALTER TABLE AutonomousSystem
  ADD CONSTRAINT 'as_1' FOREIGN KEY (assigned_by) REFERENCES RegionalInternetRegistry (acronym) ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE IF NOT EXISTS MeasurementCampaign (
  id INTEGER UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description VARCHAR(255) NULL,
  PRIMARY KEY(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS RipeAtlasMeasurement (
  id INTEGER UNSIGNED NOT NULL COMMENT 'RIPE ATLAS Measurement ID',
  measurement_type VARCHAR(255) NOT NULL COMMENT 'currently one of: Ping, Traceroute, DNS, SSL, HTTP, NTP'
  probe_selection_type VARCHAR(255) COMMENT 'currently one of: probes, area, country, prefix, asn, complex',
  PRIMARY KEY(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS TracerouteMeasurement (
  id INTEGER UNSIGNED NOT NULL COMMENT 'RIPE ATLAS Measurement ID',
  address_family INT(1) NOT NULL COMMENT '4 for IPv4, 6 for IPv6',
  protocol VARCHAR(4) NOT NULL COMMENT 'one of UDP, TCP, ICMP',
  creation_time TIMESTAMP NULL COMMENT '',
  start_time TIMESTAMP NULL COMMENT '',
  end_time TIMESTAMP NULL COMMENT '',
  probe_selection_type VARCHAR(255) COMMENT 'currently one of: probes, area, country, prefix, asn, complex',
  probe_number INTEGER NULL COMMENT '',
  probe_area VARCHAR(255) NULL COMMENT 'currently one of: Worldwide, West, North-Central, South-Central, North-East, South-East',
  probe_country MEDIUMTEXT NULL COMMENT '',
  probe_prefix MEDIUMTEXT NULL COMMENT '',
  probe_asn int(6) NULL COMMENT 'target autonomous system number',
  probe_complex_description MEDIUMTEXT NULL COMMENT '',
  number_of_probes_requested INTEGER UNSIGNED NULL COMMENT '',
  response_timeout INTEGER UNSIGNED NULL COMMENT 'timeout in milliseconds',
  number_of_packets INTEGER UNSIGNED NULL COMMENT '',
  packet_size INTEGER UNSIGNED NULL COMMENT 'size of data packets used for probing in bytes',
  hops_max INTEGER UNSIGNED NULL COMMENT '',
  paris_variations INTEGER UNSIGNED NULL COMMENT 'number of different variations for paris traceroute; value 0 means standard traceroute',
  designated_target MEDIUMTEXT NULL,
  designated_target_name MEDIUMTEXT NULL,
  designated_target_asn MEDIUMTEXT NULL,
  PRIMARY KEY(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

ALTER TABLE TracerouteMeasurement
  ADD CONSTRAINT 'trm_1' FOREIGN KEY (address_family) REFERENCES AddressFamily (id) ON DELETE NO ACTION ON UPDATE NO ACTION;

CREATE TABLE IF NOT EXISTS Campaign_has_Measurement (
  id_campaign INTEGER UNSIGNED NOT NULL,
  id_measurement INTEGER UNSIGNED NOT NULL,
  PRIMARY KEY(id_campaign, id_measurement)
  FOREIGN KEY(id_campaign)
    REFERENCES MeasurementCampaign(id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION,
  FOREIGN KEY(id_measurement)
    REFERENCES TracerouteMeasurement(id)
      ON DELETE NO ACTION
      ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS TracerouteHop (
  id_measurement INTEGER UNSIGNED NOT NULL COMMENT '..',
  result_number INTEGER UNSIGNED NOT NULL COMMENT '..',
  hop_number INTEGER UNSIGNED NOT NULL COMMENT '..',
  from_ip BIGINT UNSIGNED NULL COMMENT '..',
  roundtrip_time1 FLOAT NULL COMMENT 'first measured round trip time in milliseconds',
  roundtrip_time2 FLOAT NULL COMMENT 'second measured round trip time in milliseconds',
  roundtrip_time3 FLOAT NULL COMMENT 'third measured round trip time in milliseconds',
  size_of_reply INTEGER UNSIGNED,
  ttl INTEGER UNSIGNED,
  is_varying TINYINT(1) NULL COMMENT 'true if not all three msm came from the same ip address, have not same size or have not same ttl',
  is_timeout TINYINT(1) NULL COMMENT 'true if * msm',
  remarks VARCHAR(255) NULL,
  PRIMARY KEY(id_measurement, result_number, hop_number)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

CREATE TABLE IF NOT EXISTS AtlasProbe (
  probe_id INTEGER NOT NULL COMMENT 'RIPE Atlas probe ID',
  asn_v4 int(6) NULL COMMENT 'Autonomous System Number',
  asn_v6 int(6) NULL COMMENT 'Autonomous System Number',
  ipv4_prefix MEDIUMTEXT NULL COMMENT '',
  ipv6_prefix MEDIUMTEXT NULL COMMENT '',
  country_code VARCHAR(2) NULL COMMENT 'country code according to ISO 3166-1 alpha-2',
  description MEDIUMTEXT NULL COMMENT '',
  architecture MEDIUMTEXT NULL COMMENT '',
  firmware_version MEDIUMTEXT NULL COMMENT '',
  router_type MEDIUMTEXT NULL COMMENT '',
  mac_address MEDIUMTEXT NULL COMMENT '',
  latitude FLOAT NULL COMMENT '',
  longitude FLOAT NULL COMMENT '',
  is_public TINYINT(1) NOT NULL COMMENT '',
  never_connected TINYINT(1) NOT NULL COMMENT '',
  disconnected_or_abandoned TINYINT(1) NULL COMMENT '',
  last_update DATE NOT NULL COMMENT '',
  PRIMARY KEY(probe_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

ALTER TABLE `AtlasProbe`
  ADD CONSTRAINT `ap_1` FOREIGN KEY (`country_code`) REFERENCES `Country`(`code_iso_alpha_2`) ON DELETE NO ACTION ON UPDATE NO ACTION;

INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Afghanistan', 'Afghanistan', NULL, NULL, 'AF', 'AFG', 4, 'AFG', '.af', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Ägypten', 'Egypt', NULL, NULL, 'EG', 'EGY', 818, 'EGY', '.eg', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Åland', 'Åland Islands', NULL, NULL, 'AX', 'ALA', 248, '', '.ax', 2004, 'An autonomous province of Finland', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Albanien', 'Albania', NULL, NULL, 'AL', 'ALB', 8, 'ALB', '.al', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Algerien', 'Algeria', NULL, NULL, 'DZ', 'DZA', 12, 'ALG', '.dz', 1974, 'Code taken from name in Kabyle: Dzayer', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Amerikanisch-Samoa', 'American Samoa', NULL, NULL, 'AS', 'ASM', 16, 'ASA', '.as', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Amerikanische Jungferninseln', 'Virgin Islands, U.S.', NULL, NULL, 'VI', 'VIR', 850, 'ISV', '.vi', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Andorra', 'Andorra', NULL, NULL, 'AD', 'AND', 20, 'AND', '.ad', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Angola', 'Angola', NULL, NULL, 'AO', 'AGO', 24, 'ANG', '.ao', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Anguilla', 'Anguilla', NULL, NULL, 'AI', 'AIA', 660, '', '.ai', 1983, 'AI previously represented French Afar and Issas', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Antarktika', 'Antarctica', NULL, NULL, 'AQ', 'ATA', 10, '', '.aq', 1974, 'Covers the territories south of 60° south latitude; code taken from name in French: Antarctique; Sonderstatus durch Antarktis-Vertrag', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Antigua und Barbuda', 'Antigua and Barbuda', NULL, NULL, 'AG', 'ATG', 28, 'ANT', '.ag', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Äquatorialguinea', 'Equatorial Guinea', NULL, NULL, 'GQ', 'GNQ', 226, 'GEQ', '.gq', 1974, 'Code taken from name in French: Guinée équatoriale', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Argentinien', 'Argentina', NULL, NULL, 'AR', 'ARG', 32, 'ARG', '.ar', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Armenien', 'Armenia', NULL, NULL, 'AM', 'ARM', 51, 'ARM', '.am', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Aruba', 'Aruba', NULL, NULL, 'AW', 'ABW', 533, 'ARU', '.aw', 1986, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Ascension', '', NULL, NULL, 'AC', 'ASC', NULL, '', '.ac', NULL, 'verwaltet von St. Helena; reserviert für UPU und ITU; Ausnahmsweise reservierter Code in ISO 3166-1. Dieser Code existiert nur aufgrund der Verwendung in anderen Standards (beispielsweise beim SWIFT-Code) und sollte nicht für eine Kodierung nach ISO 3166-1 verwendet werden.', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Aserbaidschan', 'Azerbaijan', NULL, NULL, 'AZ', 'AZE', 31, 'AZE', '.az', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Äthiopien', 'Ethiopia', NULL, NULL, 'ET', 'ETH', 231, 'ETH', '.et', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Australien', 'Australia', NULL, NULL, 'AU', 'AUS', 36, 'AUS', '.au', 1974, 'Includes the Ashmore and Cartier Islands and the Coral Sea Islands', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bahamas', 'Bahamas', NULL, NULL, 'BS', 'BHS', 44, 'BAH', '.bs', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bahrain', 'Bahrain', NULL, NULL, 'BH', 'BHR', 48, 'BRN', '.bh', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bangladesch', 'Bangladesh', NULL, NULL, 'BD', 'BGD', 50, 'BAN', '.bd', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Barbados', 'Barbados', NULL, NULL, 'BB', 'BRB', 52, 'BAR', '.bb', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Weißrussland', 'Belarus', NULL, NULL, 'BY', 'BLR', 112, 'BLR', '.by', 1974, 'Code taken from previous ISO country name: Byelorussian SSR (now assigned ISO 3166-3 code BYAA); Code assigned as the country was already a UN member since 1945[16]', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Belgien', 'Belgium', NULL, NULL, 'BE', 'BEL', 56, 'BEL', '.be', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Belize', 'Belize', NULL, NULL, 'BZ', 'BLZ', 84, 'BIZ', '.bz', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Benin', 'Benin', NULL, NULL, 'BJ', 'BEN', 204, 'BEN', '.bj', 1977, 'Name changed from Dahomey (DY)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bermuda', 'Bermuda', NULL, NULL, 'BM', 'BMU', 60, 'BER', '.bm', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bhutan', 'Bhutan', NULL, NULL, 'BT', 'BTN', 64, 'BHU', '.bt', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bolivien', 'Bolivia, Plurinational State of', NULL, NULL, 'BO', 'BOL', 68, 'BOL', '.bo', 1974, 'ISO country name follows UN designation (common name and previous ISO country name: Bolivia)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bonaire, Sint Eustatius und Saba (Niederlande)', 'Bonaire, Sint Eustatius and Saba', NULL, NULL, 'BQ', 'BES', 535, '', '.bq', 2010, 'Consists of three Caribbean "special municipalities", which are part of the Netherlands proper: Bonaire, Sint Eustatius, and Saba (the BES Islands); Previous ISO country name: Bonaire, Saint Eustatius and Saba; BQ previously represented British Antarctic Territory', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bosnien und Herzegowina', 'Bosnia and Herzegovina', NULL, NULL, 'BA', 'BIH', 70, 'BIH', '.ba', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Botswana', 'Botswana', NULL, NULL, 'BW', 'BWA', 72, 'BOT', '.bw', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bouvetinsel', 'Bouvet Island', NULL, NULL, 'BV', 'BVT', 74, '', '.bv', 1974, 'Belongs to Norway', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Brasilien', 'Brazil', NULL, NULL, 'BR', 'BRA', 76, 'BRA', '.br', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Britische Jungferninseln', 'Virgin Islands, British', NULL, NULL, 'VG', 'VGB', 92, 'IVB', '.vg', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Britisches Territorium im Indischen Ozean', 'British Indian Ocean Territory', NULL, NULL, 'IO', 'IOT', 86, '', '.io', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Brunei Darussalam', 'Brunei Darussalam', NULL, NULL, 'BN', 'BRN', 96, 'BRU', '.bn', 1974, 'ISO country name follows UN designation (common name: Brunei)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Bulgarien', 'Bulgaria', NULL, NULL, 'BG', 'BGR', 100, 'BUL', '.bg', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Burkina Faso', 'Burkina Faso', NULL, NULL, 'BF', 'BFA', 854, 'BUR', '.bf', 1984, 'Name changed from Upper Volta (HV)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Burma', '', NULL, NULL, 'BU', 'BUR', 104, '', '', NULL, 'jetzt Myanmar; ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Burundi', 'Burundi', NULL, NULL, 'BI', 'BDI', 108, 'BDI', '.bi', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Ceuta, Melilla', '', NULL, NULL, 'EA', '', NULL, '', '', NULL, 'Ausnahmsweise reservierter Code in ISO 3166-1. Dieser Code existiert nur aufgrund der Verwendung in anderen Standards (beispielsweise beim SWIFT-Code) und sollte nicht für eine Kodierung nach ISO 3166-1 verwendet werden.', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Chile', 'Chile', NULL, NULL, 'CL', 'CHL', 152, 'CHI', '.cl', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('China, Volksrepublik', 'China', NULL, NULL, 'CN', 'CHN', 156, 'CHN', '.cn', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Clipperton', '', NULL, NULL, 'CP', 'CPT', NULL, '', '', NULL, 'reserviert für ITU; ausnahmsweise reservierter Code in ISO 3166-1. Dieser Code existiert nur aufgrund der Verwendung in anderen Standards (beispielsweise beim SWIFT-Code) und sollte nicht für eine Kodierung nach ISO 3166-1 verwendet werden.', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Cookinseln', 'Cook Islands', NULL, NULL, 'CK', 'COK', 184, 'COK', '.ck', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Costa Rica', 'Costa Rica', NULL, NULL, 'CR', 'CRI', 188, 'CRC', '.cr', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Côte d’Ivoire (Elfenbeinküste)', 'Côte d’Ivoire', NULL, NULL, 'CI', 'CIV', 384, 'CIV', '.ci', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Curaçao', 'Curaçao', NULL, NULL, 'CW', 'CUW', 531, '', '.cw', 2010, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Dänemark', 'Denmark', NULL, NULL, 'DK', 'DNK', 208, 'DEN', '.dk', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Deutsche Demokratische Republik (historisch)', '', NULL, NULL, 'DD', '', 0, 'GDR', '.dd', NULL, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Deutschland', 'Germany', NULL, NULL, 'DE', 'DEU', 276, 'GER', '.de', 1974, 'Code taken from name in German: Deutschland; Code used for West Germany before 1990 (previous ISO country name: Germany, Federal Republic of)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Diego Garcia', '', NULL, NULL, 'DG', 'DGA', NULL, '', '', NULL, 'reserviert für ITU; ausnahmsweise reservierter Code in ISO 3166-1. Dieser Code existiert nur aufgrund der Verwendung in anderen Standards (beispielsweise beim SWIFT-Code) und sollte nicht für eine Kodierung nach ISO 3166-1 verwendet werden.', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Dominica', 'Dominica', NULL, NULL, 'DM', 'DMA', 212, 'DMA', '.dm', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Dominikanische Republik', 'Dominican Republic', NULL, NULL, 'DO', 'DOM', 214, 'DOM', '.do', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Dschibuti', 'Djibouti', NULL, NULL, 'DJ', 'DJI', 262, 'DJI', '.dj', 1977, 'Name changed from French Afar and Issas (AI)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Ecuador', 'Ecuador', NULL, NULL, 'EC', 'ECU', 218, 'ECU', '.ec', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('El Salvador', 'El Salvador', NULL, NULL, 'SV', 'SLV', 222, 'ESA', '.sv', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Eritrea', 'Eritrea', NULL, NULL, 'ER', 'ERI', 232, 'ERI', '.er', 1993, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Estland', 'Estonia', NULL, NULL, 'EE', 'EST', 233, 'EST', '.ee', 1992, 'Code taken from name in Estonian: Eesti', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Europäische Gemeinschaft', '', NULL, NULL, 'CE', 'CEE', NULL, '', '', NULL, 'Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Europäische Union', '', NULL, NULL, 'EU', '', NULL, '', '.eu', NULL, 'Ausnahmsweise reservierter Code in ISO 3166-1. Dieser Code existiert nur aufgrund der Verwendung in anderen Standards (beispielsweise beim SWIFT-Code) und sollte nicht für eine Kodierung nach ISO 3166-1 verwendet werden.', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Falklandinseln', 'Falkland Islands (Malvinas)', NULL, NULL, 'FK', 'FLK', 238, '', '.fk', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Färöer', 'Faroe Islands', NULL, NULL, 'FO', 'FRO', 234, 'FRO', '.fo', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Fidschi', 'Fiji', NULL, NULL, 'FJ', 'FJI', 242, 'FIJ', '.fj', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Finnland', 'Finland', NULL, NULL, 'FI', 'FIN', 246, 'FIN', '.fi', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Finnland', 'Finland', NULL, NULL, 'SF', '', NULL, '', '', NULL, 'Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Frankreich', 'France', NULL, NULL, 'FR', 'FRA', 250, 'FRA', '.fr', 1974, 'Includes Clipperton Island', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Frankreich, France métropolitaine (europ. Frankreich ohne Übersee-Départements)', '', NULL, NULL, 'FX', 'FXX', 249, '', '', NULL, 'Ausnahmsweise reservierter Code in ISO 3166-1. Dieser Code existiert nur aufgrund der Verwendung in anderen Standards (beispielsweise beim SWIFT-Code) und sollte nicht für eine Kodierung nach ISO 3166-1 verwendet werden. // numerisch: Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Französisch-Guayana', 'French Guiana', NULL, NULL, 'GF', 'GUF', 254, '', '.gf', 1974, 'Code taken from name in French: Guyane française', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Französisch-Polynesien', 'French Polynesia', NULL, NULL, 'PF', 'PYF', 258, '', '.pf', 1974, 'Code taken from name in French: Polynésie française', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Französische Süd- und Antarktisgebiete', 'French Southern Territories', NULL, NULL, 'TF', 'ATF', 260, '', '.tf', 1979, 'Covers the French Southern and Antarctic Lands except Adélie Land; Code taken from name in French: Terres australes françaises', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Gabun', 'Gabon', NULL, NULL, 'GA', 'GAB', 266, 'GAB', '.ga', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Gambia', 'Gambia', NULL, NULL, 'GM', 'GMB', 270, 'GAM', '.gm', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Georgien', 'Georgia', NULL, NULL, 'GE', 'GEO', 268, 'GEO', '.ge', 1992, 'GE previously represented Gilbert and Ellice Islands', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Ghana', 'Ghana', NULL, NULL, 'GH', 'GHA', 288, 'GHA', '.gh', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Gibraltar', 'Gibraltar', NULL, NULL, 'GI', 'GIB', 292, '', '.gi', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Grenada', 'Grenada', NULL, NULL, 'GD', 'GRD', 308, 'GRN', '.gd', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Griechenland', 'Greece', NULL, NULL, 'GR', 'GRC', 300, 'GRE', '.gr', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Grönland', 'Greenland', NULL, NULL, 'GL', 'GRL', 304, '', '.gl', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Guadeloupe', 'Guadeloupe', NULL, NULL, 'GP', 'GLP', 312, '', '.gp', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Guam', 'Guam', NULL, NULL, 'GU', 'GUM', 316, 'GUM', '.gu', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Guatemala', 'Guatemala', NULL, NULL, 'GT', 'GTM', 320, 'GUA', '.gt', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Guernsey (Kanalinsel)', 'Guernsey', NULL, NULL, 'GG', 'GGY', 831, '', '.gg', 2006, 'a British Crown dependency', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Guinea', 'Guinea', NULL, NULL, 'GN', 'GIN', 324, 'GUI', '.gn', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Guinea-Bissau', 'Guinea-Bissau', NULL, NULL, 'GW', 'GNB', 624, 'GBS', '.gw', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Guyana', 'Guyana', NULL, NULL, 'GY', 'GUY', 328, 'GUY', '.gy', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Haiti', 'Haiti', NULL, NULL, 'HT', 'HTI', 332, 'HAI', '.ht', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Heard und McDonaldinseln', 'Heard Island and McDonald Islands', NULL, NULL, 'HM', 'HMD', 334, '', '.hm', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Honduras', 'Honduras', NULL, NULL, 'HN', 'HND', 340, 'HON', '.hn', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Hongkong', 'Hong Kong', NULL, NULL, 'HK', 'HKG', 344, 'HKG', '.hk', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Indien', 'India', NULL, NULL, 'IN', 'IND', 356, 'IND', '.in', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Indonesien', 'Indonesia', NULL, NULL, 'ID', 'IDN', 360, 'INA', '.id', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Insel Man', 'Isle of Man', NULL, NULL, 'IM', 'IMN', 833, '', '.im', 2006, 'a British Crown dependency', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Irak', 'Iraq', NULL, NULL, 'IQ', 'IRQ', 368, 'IRQ', '.iq', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Iran, Islamische Republik', 'Iran, Islamic Republic of', NULL, NULL, 'IR', 'IRN', 364, 'IRI', '.ir', 1974, 'ISO country name follows UN designation (common name: Iran)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Irland', 'Ireland', NULL, NULL, 'IE', 'IRL', 372, 'IRL', '.ie', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Island', 'Iceland', NULL, NULL, 'IS', 'ISL', 352, 'ISL', '.is', 1974, 'Code taken from name in Icelandic: Ísland', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Israel', 'Israel', NULL, NULL, 'IL', 'ISR', 376, 'ISR', '.il', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Italien', 'Italy', NULL, NULL, 'IT', 'ITA', 380, 'ITA', '.it', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Jamaika', 'Jamaica', NULL, NULL, 'JM', 'JAM', 388, 'JAM', '.jm', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Japan', 'Japan', NULL, NULL, 'JP', 'JPN', 392, 'JPN', '.jp', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Jemen', 'Yemen', NULL, NULL, 'YE', 'YEM', 887, 'YEM', '.ye', 1974, 'Previous ISO country name: Yemen, Republic of; Code used for North Yemen before 1990', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Jersey (Kanalinsel)', 'Jersey', NULL, NULL, 'JE', 'JEY', 832, '', '.je', 2006, 'a British Crown dependency', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Jordanien', 'Jordan', NULL, NULL, 'JO', 'JOR', 400, 'JOR', '.jo', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Jugoslawien (ehemalig)', '', NULL, NULL, 'YU', 'YUG', 891, 'YUG', '.yu', NULL, 'Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kaimaninseln', 'Cayman Islands', NULL, NULL, 'KY', 'CYM', 136, 'CAY', '.ky', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kambodscha', 'Cambodia', NULL, NULL, 'KH', 'KHM', 116, 'CAM', '.kh', 1974, 'Code taken from former name: Khmer Republic; Previous ISO country name: Kampuchea', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kamerun', 'Cameroon', NULL, NULL, 'CM', 'CMR', 120, 'CMR', '.cm', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kanada', 'Canada', NULL, NULL, 'CA', 'CAN', 124, 'CAN', '.ca', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kanarische Inseln', '', NULL, NULL, 'IC', '', NULL, '', '', NULL, 'Ausnahmsweise reservierter Code in ISO 3166-1. Dieser Code existiert nur aufgrund der Verwendung in anderen Standards (beispielsweise beim SWIFT-Code) und sollte nicht für eine Kodierung nach ISO 3166-1 verwendet werden.', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kap Verde', 'Cabo Verde', NULL, NULL, 'CV', 'CPV', 132, 'CPV', '.cv', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kasachstan', 'Kazakhstan', NULL, NULL, 'KZ', 'KAZ', 398, 'KAZ', '.kz', 1992, 'Previous ISO country name: Kazakstan', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Katar', 'Qatar', NULL, NULL, 'QA', 'QAT', 634, 'QAT', '.qa', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kenia', 'Kenya', NULL, NULL, 'KE', 'KEN', 404, 'KEN', '.ke', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kirgisistan', 'Kyrgyzstan', NULL, NULL, 'KG', 'KGZ', 417, 'KGZ', '.kg', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kiribati', 'Kiribati', NULL, NULL, 'KI', 'KIR', 296, 'KIR', '.ki', 1979, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kokosinseln', 'Cocos (Keeling) Islands', NULL, NULL, 'CC', 'CCK', 166, '', '.cc', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kolumbien', 'Colombia', NULL, NULL, 'CO', 'COL', 170, 'COL', '.co', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Komoren', 'Comoros', NULL, NULL, 'KM', 'COM', 174, 'COM', '.km', 1974, 'Code taken from name in Comorian: Komori', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kongo, Demokratische Republik (ehem. Zaire)', 'Congo, the Democratic Republic of the', NULL, NULL, 'CD', 'COD', 180, 'COD', '.cd', 1997, 'Name changed from Zaire (ZR)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Republik Kongo', 'Congo', NULL, NULL, 'CG', 'COG', 178, 'CGO', '.cg', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Korea, Demokratische Volksrepublik (Nordkorea)', 'Korea, Democratic People’s Republic of', NULL, NULL, 'KP', 'PRK', 408, 'PRK', '.kp', 1974, 'ISO country name follows UN designation (common name: North Korea)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Korea, Republik (Südkorea)', 'Korea, Republic of', NULL, NULL, 'KR', 'KOR', 410, 'KOR', '.kr', 1974, 'ISO country name follows UN designation (common name: South Korea)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kosovo', '', NULL, NULL, '__', '', NULL, '', '', NULL, 'partially recognized', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kroatien', 'Croatia', NULL, NULL, 'HR', 'HRV', 191, 'CRO', '.hr', 1992, 'Code taken from name in Croatian: Hrvatska', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kuba', 'Cuba', NULL, NULL, 'CU', 'CUB', 192, 'CUB', '.cu', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Kuwait', 'Kuwait', NULL, NULL, 'KW', 'KWT', 414, 'KUW', '.kw', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Laos, Demokratische Volksrepublik', 'Lao People’s Democratic Republic', NULL, NULL, 'LA', 'LAO', 418, 'LAO', '.la', 1974, 'ISO country name follows UN designation (common name: Laos)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Lesotho', 'Lesotho', NULL, NULL, 'LS', 'LSO', 426, 'LES', '.ls', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Lettland', 'Latvia', NULL, NULL, 'LV', 'LVA', 428, 'LAT', '.lv', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Libanon', 'Lebanon', NULL, NULL, 'LB', 'LBN', 422, 'LIB', '.lb', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Liberia', 'Liberia', NULL, NULL, 'LR', 'LBR', 430, 'LBR', '.lr', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Libyen', 'Libya', NULL, NULL, 'LY', 'LBY', 434, 'LBA', '.ly', 1974, 'Previous ISO country name: Libyan Arab Jamahiriya', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Liechtenstein', 'Liechtenstein', NULL, NULL, 'LI', 'LIE', 438, 'LIE', '.li', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Litauen', 'Lithuania', NULL, NULL, 'LT', 'LTU', 440, 'LTU', '.lt', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Luxemburg', 'Luxembourg', NULL, NULL, 'LU', 'LUX', 442, 'LUX', '.lu', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Macau', 'Macao', NULL, NULL, 'MO', 'MAC', 446, '', '.mo', 1974, 'Previous ISO country name: Macau', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Madagaskar', 'Madagascar', NULL, NULL, 'MG', 'MDG', 450, 'MAD', '.mg', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Malawi', 'Malawi', NULL, NULL, 'MW', 'MWI', 454, 'MAW', '.mw', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Malaysia', 'Malaysia', NULL, NULL, 'MY', 'MYS', 458, 'MAS', '.my', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Malediven', 'Maldives', NULL, NULL, 'MV', 'MDV', 462, 'MDV', '.mv', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Mali', 'Mali', NULL, NULL, 'ML', 'MLI', 466, 'MLI', '.ml', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Malta', 'Malta', NULL, NULL, 'MT', 'MLT', 470, 'MLT', '.mt', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Marokko', 'Morocco', NULL, NULL, 'MA', 'MAR', 504, 'MAR', '.ma', 1974, 'Code taken from name in French: Maroc', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Marshallinseln', 'Marshall Islands', NULL, NULL, 'MH', 'MHL', 584, 'MHL', '.mh', 1986, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Martinique', 'Martinique', NULL, NULL, 'MQ', 'MTQ', 474, '', '.mq', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Mauretanien', 'Mauritania', NULL, NULL, 'MR', 'MRT', 478, 'MTN', '.mr', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Mauritius', 'Mauritius', NULL, NULL, 'MU', 'MUS', 480, 'MRI', '.mu', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Mayotte', 'Mayotte', NULL, NULL, 'YT', 'MYT', 175, '', '.yt', 1993, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Mazedonien', 'Macedonia, the former Yugoslav Republic of', NULL, NULL, 'MK', 'MKD', 807, 'MKD', '.mk', 1993, 'ISO country name follows UN designation (due to Macedonia naming dispute; official name used by country itself: Republic of Macedonia); Code taken from name in Macedonian: Makedonija', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Mexiko', 'Mexico', NULL, NULL, 'MX', 'MEX', 484, 'MEX', '.mx', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Mikronesien', 'Micronesia, Federated States of', NULL, NULL, 'FM', 'FSM', 583, 'FSM', '.fm', 1986, 'Previous ISO country name: Micronesia', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Moldawien (Republik Moldau)', 'Moldova, Republic of', NULL, NULL, 'MD', 'MDA', 498, 'MDA', '.md', 1992, 'ISO country name follows UN designation (common name and previous ISO country name: Moldova)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Monaco', 'Monaco', NULL, NULL, 'MC', 'MCO', 492, 'MON', '.mc', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Mongolei', 'Mongolia', NULL, NULL, 'MN', 'MNG', 496, 'MGL', '.mn', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Montenegro', 'Montenegro', NULL, NULL, 'ME', 'MNE', 499, 'MNE', '.me', 2006, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Montserrat', 'Montserrat', NULL, NULL, 'MS', 'MSR', 500, '', '.ms', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Mosambik', 'Mozambique', NULL, NULL, 'MZ', 'MOZ', 508, 'MOZ', '.mz', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Myanmar (Burma)', 'Myanmar', NULL, NULL, 'MM', 'MMR', 104, 'MYA', '.mm', 1989, 'Name changed from Burma (BU)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Namibia', 'Namibia', NULL, NULL, 'NA', 'NAM', 516, 'NAM', '.na', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Nauru', 'Nauru', NULL, NULL, 'NR', 'NRU', 520, 'NRU', '.nr', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Nepal', 'Nepal', NULL, NULL, 'NP', 'NPL', 524, 'NEP', '.np', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Neukaledonien', 'New Caledonia', NULL, NULL, 'NC', 'NCL', 540, '', '.nc', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Neuseeland', 'New Zealand', NULL, NULL, 'NZ', 'NZL', 554, 'NZL', '.nz', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Neutrale Zone (Saudi-Arabien und Irak bis 1993)', '', NULL, NULL, 'NT', 'NTZ', 536, '', '', NULL, 'Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Nicaragua', 'Nicaragua', NULL, NULL, 'NI', 'NIC', 558, 'NCA', '.ni', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Niederlande', 'Netherlands', NULL, NULL, 'NL', 'NLD', 528, 'NED', '.nl', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Niederländische Antillen (ehemalig)', '', NULL, NULL, 'AN', 'ANT', 530, 'AHO', '.an', NULL, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Niger', 'Niger', NULL, NULL, 'NE', 'NER', 562, 'NIG', '.ne', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Nigeria', 'Nigeria', NULL, NULL, 'NG', 'NGA', 566, 'NGR', '.ng', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Niue', 'Niue', NULL, NULL, 'NU', 'NIU', 570, '', '.nu', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Nördliche Marianen', 'Northern Mariana Islands', NULL, NULL, 'MP', 'MNP', 580, '', '.mp', 1986, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Nordzypern', '', NULL, NULL, '--', '', NULL, '', '', NULL, 'partially recognized', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Norfolkinsel', 'Norfolk Island', NULL, NULL, 'NF', 'NFK', 574, '', '.nf', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Norwegen', 'Norway', NULL, NULL, 'NO', 'NOR', 578, 'NOR', '.no', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Oman', 'Oman', NULL, NULL, 'OM', 'OMN', 512, 'OMA', '.om', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Österreich', 'Austria', NULL, NULL, 'AT', 'AUT', 40, 'AUT', '.at', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Osttimor (Timor-Leste)', 'Timor-Leste', NULL, NULL, 'TL', 'TLS', 626, 'TLS', '.tl', 2002, 'Name changed from East Timor (TP)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Osttimor (Timor-Leste)', 'Timor-Leste', NULL, NULL, 'TP', 'TMP', NULL, '', '.tp', NULL, 'Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Pakistan', 'Pakistan', NULL, NULL, 'PK', 'PAK', 586, 'PAK', '.pk', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Staat Palästina', 'Palestine, State of', NULL, NULL, 'PS', 'PSE', 275, 'PLE', '.ps', 2013, 'Previous ISO country name: Palestinian Territory, Occupied; Consists of the West Bank and the Gaza Strip; ursprünglich unter dem Namen "Palestinian Territory, Occupied" (Palästinensische Autonomiegebiete) aufgenommen. 2013 erfolgte die Umbenennung in "Palestine, State of".', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Palau', 'Palau', NULL, NULL, 'PW', 'PLW', 585, 'PLW', '.pw', 1986, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Panama', 'Panama', NULL, NULL, 'PA', 'PAN', 591, 'PAN', '.pa', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Papua-Neuguinea', 'Papua New Guinea', NULL, NULL, 'PG', 'PNG', 598, 'PNG', '.pg', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Paraguay', 'Paraguay', NULL, NULL, 'PY', 'PRY', 600, 'PAR', '.py', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Peru', 'Peru', NULL, NULL, 'PE', 'PER', 604, 'PER', '.pe', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Philippinen', 'Philippines', NULL, NULL, 'PH', 'PHL', 608, 'PHI', '.ph', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Pitcairninseln', 'Pitcairn', NULL, NULL, 'PN', 'PCN', 612, '', '.pn', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Polen', 'Poland', NULL, NULL, 'PL', 'POL', 616, 'POL', '.pl', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Portugal', 'Portugal', NULL, NULL, 'PT', 'PRT', 620, 'POR', '.pt', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Puerto Rico', 'Puerto Rico', NULL, NULL, 'PR', 'PRI', 630, 'PUR', '.pr', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Réunion', 'Réunion', NULL, NULL, 'RE', 'REU', 638, '', '.re', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Ruanda', 'Rwanda', NULL, NULL, 'RW', 'RWA', 646, 'RWA', '.rw', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Rumänien', 'Romania', NULL, NULL, 'RO', 'ROU', 642, 'ROU', '.ro', 1974, 'alter Code nach ISO 3166-1 alpha-3: ROM', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Russische Föderation', 'Russian Federation', NULL, NULL, 'RU', 'RUS', 643, 'RUS', '.ru', 1992, 'ISO country name follows UN designation (common name: Russia)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Salomonen', 'Solomon Islands', NULL, NULL, 'SB', 'SLB', 90, 'SOL', '.sb', 1974, 'Code taken from former name: British Solomon Islands', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Saint-Barthélemy', 'Saint Barthélemy', NULL, NULL, 'BL', 'BLM', 652, '', '.bl', 2007, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Saint-Martin (franz. Teil)', 'Saint Martin (French part)', NULL, NULL, 'MF', 'MAF', 663, '', '.mf', 2007, 'The Dutch part of Saint Martin island is assigned code SX', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Sambia', 'Zambia', NULL, NULL, 'ZM', 'ZMB', 894, 'ZAM', '.zm', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Samoa', 'Samoa', NULL, NULL, 'WS', 'WSM', 882, 'SAM', '.ws', 1974, 'Code taken from former name: Western Samoa', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('San Marino', 'San Marino', NULL, NULL, 'SM', 'SMR', 674, 'SMR', '.sm', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('São Tomé und Príncipe', 'Sao Tome and Principe', NULL, NULL, 'ST', 'STP', 678, 'STP', '.st', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Saudi-Arabien', 'Saudi Arabia', NULL, NULL, 'SA', 'SAU', 682, 'KSA', '.sa', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Schweden', 'Sweden', NULL, NULL, 'SE', 'SWE', 752, 'SWE', '.se', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Schweiz', 'Switzerland', NULL, NULL, 'CH', 'CHE', 756, 'SUI', '.ch', 1974, 'Code taken from name in Latin: Confoederatio Helvetica', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Senegal', 'Senegal', NULL, NULL, 'SN', 'SEN', 686, 'SEN', '.sn', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Serbien', 'Serbia', NULL, NULL, 'RS', 'SRB', 688, 'SRB', '.rs', 2006, 'Code taken from official name: Republic of Serbia (see Serbian country codes)', 0);
-- INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
-- VALUES ('Serbien und Montenegro', '', NULL, NULL, 'CS', 'SCG', 891, 'SCG', '.yu', NULL, 'Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Seychellen', 'Seychelles', NULL, NULL, 'SC', 'SYC', 690, 'SEY', '.sc', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Sierra Leone', 'Sierra Leone', NULL, NULL, 'SL', 'SLE', 694, 'SLE', '.sl', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Simbabwe', 'Zimbabwe', NULL, NULL, 'ZW', 'ZWE', 716, 'ZIM', '.zw', 1980, 'Name changed from Southern Rhodesia (RH)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Singapur', 'Singapore', NULL, NULL, 'SG', 'SGP', 702, 'SIN', '.sg', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Sint Maarten (niederl. Teil)', 'Sint Maarten (Dutch part)', NULL, NULL, 'SX', 'SXM', 534, '', '.sx', 2010, 'The French part of Saint Martin island is assigned code MF', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Slowakei', 'Slovakia', NULL, NULL, 'SK', 'SVK', 703, 'SVK', '.sk', 1993, 'SK previously represented Sikkim', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Slowenien', 'Slovenia', NULL, NULL, 'SI', 'SVN', 705, 'SLO', '.si', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Somalia', 'Somalia', NULL, NULL, 'SO', 'SOM', 706, 'SOM', '.so', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Spanien', 'Spain', NULL, NULL, 'ES', 'ESP', 724, 'ESP', '.es', 1974, 'Code taken from name in Spanish: España', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Sri Lanka', 'Sri Lanka', NULL, NULL, 'LK', 'LKA', 144, 'SRI', '.lk', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('St. Helena', 'Saint Helena, Ascension and Tristan da Cunha', NULL, NULL, 'SH', 'SHN', 654, '', '.sh', 1974, 'Previous ISO country name: Saint Helena', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('St. Kitts und Nevis', 'Saint Kitts and Nevis', NULL, NULL, 'KN', 'KNA', 659, 'SKN', '.kn', 1974, 'Previous ISO country name: Saint Kitts-Nevis-Anguilla', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('St. Lucia', 'Saint Lucia', NULL, NULL, 'LC', 'LCA', 662, 'LCA', '.lc', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Saint-Pierre und Miquelon', 'Saint Pierre and Miquelon', NULL, NULL, 'PM', 'SPM', 666, '', '.pm', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('St. Vincent und die Grenadinen', 'Saint Vincent and the Grenadines', NULL, NULL, 'VC', 'VCT', 670, 'VIN', '.vc', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Südafrika', 'South Africa', NULL, NULL, 'ZA', 'ZAF', 710, 'RSA', '.za', 1974, 'Code taken from name in Dutch: Zuid-Afrika', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Sudan', 'Sudan', NULL, NULL, 'SD', 'SDN', 729, 'SUD', '.sd', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Südgeorgien und die Südlichen Sandwichinseln', 'South Georgia and the South Sandwich Islands', NULL, NULL, 'GS', 'SGS', 239, '', '.gs', 1993, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Südsudan', 'South Sudan', NULL, NULL, 'SS', 'SSD', 728, '', '.ss', 2011, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Suriname', 'Suriname', NULL, NULL, 'SR', 'SUR', 740, 'SUR', '.sr', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Svalbard und Jan Mayen', 'Svalbard and Jan Mayen', NULL, NULL, 'SJ', 'SJM', 744, '', '.sj', 1974, 'Consists of two arctic territories of Norway: Svalbard and Jan Mayen', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Swasiland', 'Swaziland', NULL, NULL, 'SZ', 'SWZ', 748, 'SWZ', '.sz', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Syrien, Arabische Republik', 'Syrian Arab Republic', NULL, NULL, 'SY', 'SYR', 760, 'SYR', '.sy', 1974, 'ISO country name follows UN designation (common name: Syria)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tadschikistan', 'Tajikistan', NULL, NULL, 'TJ', 'TJK', 762, 'TJK', '.tj', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Republik China (Taiwan)', 'Taiwan, Province of China', NULL, NULL, 'TW', 'TWN', 158, 'TPE', '.tw', 1974, 'Covers the current jurisdiction of the Republic of China except Kinmen and Lienchiang; ISO country name follows UN designation (due to political status of Taiwan within the UN)[17]', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tansania, Vereinigte Republik', 'Tanzania, United Republic of', NULL, NULL, 'TZ', 'TZA', 834, 'TAN', '.tz', 1974, 'ISO country name follows UN designation (common name: Tanzania)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Thailand', 'Thailand', NULL, NULL, 'TH', 'THA', 764, 'THA', '.th', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Togo', 'Togo', NULL, NULL, 'TG', 'TGO', 768, 'TOG', '.tg', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tokelau', 'Tokelau', NULL, NULL, 'TK', 'TKL', 772, '', '.tk', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tonga', 'Tonga', NULL, NULL, 'TO', 'TON', 776, 'TGA', '.to', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Trinidad und Tobago', 'Trinidad and Tobago', NULL, NULL, 'TT', 'TTO', 780, 'TRI', '.tt', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tristan da Cunha', '', NULL, NULL, 'TA', 'TAA', NULL, '', '', NULL, 'verwaltet von St. Helena; reserviert für UPU; Ausnahmsweise reservierter Code in ISO 3166-1. Dieser Code existiert nur aufgrund der Verwendung in anderen Standards (beispielsweise beim SWIFT-Code) und sollte nicht für eine Kodierung nach ISO 3166-1 verwendet werden.', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tschad', 'Chad', NULL, NULL, 'TD', 'TCD', 148, 'CHA', '.td', 1974, 'Code taken from name in French: Tchad', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tschechische Republik', 'Czech Republic', NULL, NULL, 'CZ', 'CZE', 203, 'CZE', '.cz', 1993, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tschechoslowakei (ehemalig)', '', NULL, NULL, 'CS', 'CSK', 200, 'TCH', '.cs', NULL, 'Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tunesien', 'Tunisia', NULL, NULL, 'TN', 'TUN', 788, 'TUN', '.tn', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Türkei', 'Turkey', NULL, NULL, 'TR', 'TUR', 792, 'TUR', '.tr', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Turkmenistan', 'Turkmenistan', NULL, NULL, 'TM', 'TKM', 795, 'TKM', '.tm', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Turks- und Caicosinseln', 'Turks and Caicos Islands', NULL, NULL, 'TC', 'TCA', 796, '', '.tc', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Tuvalu', 'Tuvalu', NULL, NULL, 'TV', 'TUV', 798, 'TUV', '.tv', 1979, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('UdSSR (ehemalig)', '', NULL, NULL, 'SU', 'SUN', 810, 'URS', '.su', NULL, 'Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Uganda', 'Uganda', NULL, NULL, 'UG', 'UGA', 800, 'UGA', '.ug', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Ukraine', 'Ukraine', NULL, NULL, 'UA', 'UKR', 804, 'UKR', '.ua', 1974, 'Previous ISO country name: Ukrainian SSR; Code assigned as the country was already a UN member since 1945[16]', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Ungarn', 'Hungary', NULL, NULL, 'HU', 'HUN', 348, 'HUN', '.hu', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('United States Minor Outlying Islands', 'United States Minor Outlying Islands', NULL, NULL, 'UM', 'UMI', 581, '', '.um', 1986, 'Consists of nine minor insular areas of the United States: Baker Island, Howland Island, Jarvis Island, Johnston Atoll, Kingman Reef, Midway Islands, Navassa Island,Palmyra Atoll, and Wake Island', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Uruguay', 'Uruguay', NULL, NULL, 'UY', 'URY', 858, 'URU', '.uy', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Usbekistan', 'Uzbekistan', NULL, NULL, 'UZ', 'UZB', 860, 'UZB', '.uz', 1992, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Vanuatu', 'Vanuatu', NULL, NULL, 'VU', 'VUT', 548, 'VAN', '.vu', 1980, 'Name changed from New Hebrides (NH)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Vatikanstadt', 'Holy See', NULL, NULL, 'VA', 'VAT', 336, '', '.va', 1974, 'Covers Vatican City, territory of the Holy See; Previous ISO country name: Vatican City State (Holy See)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Venezuela', 'Venezuela, Bolivarian Republic of', NULL, NULL, 'VE', 'VEN', 862, 'VEN', '.ve', 1974, 'ISO country name follows UN designation (common name and previous ISO country name: Venezuela)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Vereinigte Arabische Emirate', 'United Arab Emirates', NULL, NULL, 'AE', 'ARE', 784, 'UAE', '.ae', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Vereinigte Staaten von Amerika', 'United States of America', NULL, NULL, 'US', 'USA', 840, 'USA', '.us', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Vereinigtes Königreich Großbritannien und Nordirland', 'United Kingdom of Great Britain and Northern Ireland', NULL, NULL, 'GB', 'GBR', 826, 'GBR', '.uk', 1974, 'Code taken from Great Britain (from official name: United Kingdom of Great Britain and Northern Ireland)[17]; .uk is the primary ccTLD of the United Kingdom instead of .gb (see code UK, which is exceptionally reserved)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Vereinigtes Königreich Großbritannien und Nordirland', 'United Kingdom of Great Britain and Northern Ireland', NULL, NULL, 'UK', '', NULL, '', '.gb', NULL, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Vietnam', 'Viet Nam', NULL, NULL, 'VN', 'VNM', 704, 'VIE', '.vn', 1974, 'ISO country name follows UN designation (common name: Vietnam)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Wallis und Futuna', 'Wallis and Futuna', NULL, NULL, 'WF', 'WLF', 876, '', '.wf', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Weihnachtsinsel', 'Christmas Island', NULL, NULL, 'CX', 'CXR', 162, '', '.cx', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Westsahara', 'Western Sahara', NULL, NULL, 'EH', 'ESH', 732, '', '.eh', 1974, 'Previous ISO country name: Spanish Sahara (code taken from name in Spanish: Sahara español)', 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Zaire (jetzt Demokratische Republik Kongo)', '', NULL, NULL, 'ZR', 'ZAR', 180, '', '', NULL, 'Ehemals gültiger Code, der nicht mehr benutzt werden soll. Übergangsweise reserviert zur Dekodierung.', 1);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Zentralafrikanische Republik', 'Central African Republic', NULL, NULL, 'CF', 'CAF', 140, 'CAF', '.cf', 1974, NULL, 0);
INSERT INTO Country (name_german, name_english, name_french, name_italian, code_iso_alpha_2, code_iso_alpha_3, code_iso_numeric, code_ioc, tld, year_assigned, obsolete, remarks) 
VALUES ('Zypern', 'Cyprus', NULL, NULL, 'CY', 'CYP', 196, 'CYP', '.cy', 1974, NULL, 0);

CREATE TABLE IF NOT EXISTS Country_Belongs_To_Country_Group (
  country_code VARCHAR(2) NOT NULL COMMENT 'country code according to ISO 3166-1 alpha-2',
  country_group_id INTEGER NOT NULL COMMENT 'id of country group',
  date_begin DATE NULL COMMENT '',
  date_end DATE NULL COMMENT '',
  remarks MEDIUMTEXT NULL,
  PRIMARY KEY(country_code, country_group_id)
);

ALTER TABLE `Country_Belongs_To_Country_Group`
  ADD CONSTRAINT `cbtcg_1` FOREIGN KEY (`country_code`) REFERENCES `Country`(`code_iso_alpha_2`) ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE `Country_Belongs_To_Country_Group`
  ADD CONSTRAINT `cbtcg_2` FOREIGN KEY (`country_group_id`) REFERENCES `CountryGroup`(`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('BE', 10, '1990-06-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('BG', 10, '2007-01-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('DK', 10, '1996-12-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('DE', 10, '1990-06-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('EE', 10, '2004-05-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('FI', 10, '1996-12-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('FR', 10, '1990-06-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('GR', 10, '1992-11-06', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('IS', 10, '1996-12-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('IT', 10, '1990-11-17', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('LV', 10, '2004-05-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('LI', 10, '2008-03-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('LT', 10, '2004-05-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('LU', 10, '1990-06-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('MT', 10, '2004-05-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('NL', 10, '1990-06-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('NO', 10, '1996-12-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('AT', 10, '1995-04-28', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('PL', 10, '2004-05-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('PT', 10, '1991-06-25', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('RO', 10, '2007-01-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('SE', 10, '1996-12-19', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('CH', 10, '2004-10-26', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('SK', 10, '2004-05-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('SI', 10, '2004-05-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('ES', 10, '1991-06-25', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('CZ', 10, '2004-05-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('HU', 10, '2004-05-01', NULL, NULL);
INSERT INTO Country_Belongs_To_Country_Group (country_code, country_group_id, date_begin, date_end, remarks) 
VALUES ('CY', 10, '2004-05-01', NULL, NULL);
