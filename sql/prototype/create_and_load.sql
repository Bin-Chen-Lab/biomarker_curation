DROP DATABASE IF EXISTS biomarker2;
CREATE SCHEMA IF NOT EXISTS biomarker2 DEFAULT CHARACTER SET utf8;
USE biomarker2;

DROP TABLE IF EXISTS biomarker;
DROP TABLE IF EXISTS biomarker_record;
DROP TABLE IF EXISTS disease;
DROP TABLE IF EXISTS drug;
DROP TABLE IF EXISTS patient;
DROP TABLE IF EXISTS json;

-- -----------------------------------------------------
-- Biomarker
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS biomarker (
    record_id VARCHAR(50),
    name VARCHAR(50),
    ensembl VARCHAR(50),
    biomarker_type VARCHAR(100),
    biomarker_direction VARCHAR(50),
    biomarker_name VARCHAR(500)
);

LOAD DATA LOCAL INFILE
  'data/released/db/biomarker.csv'
INTO TABLE biomarker
FIELDS
  TERMINATED BY ','
  ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES;

-- -----------------------------------------------------
-- Biomarker Record
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS biomarker_record (
    record_id VARCHAR(50),
    drug VARCHAR(500),
    biomarker VARCHAR(50),
    biomarker_relations  VARCHAR(50),
    biomarker_description VARCHAR(1000),
    disease VARCHAR(1000),
    curator VARCHAR(50),
    source VARCHAR(50),
    source_id VARCHAR(50)

);

LOAD DATA LOCAL INFILE
  'data/released/db/biomarker_record.csv'
INTO TABLE biomarker_record
FIELDS
  TERMINATED BY ','
  ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES;

-- -----------------------------------------------------
-- Disease
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS disease (
    record_id VARCHAR(50),
    name VARCHAR(500),
    disease_id VARCHAR(50),
    id_source VARCHAR(50)
);

LOAD DATA LOCAL INFILE
  'data/released/db/disease.csv'
INTO TABLE disease
FIELDS
  TERMINATED BY ','
  ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES;

-- -----------------------------------------------------
-- Drug
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS drug (
    record_id VARCHAR(50),
    name VARCHAR(500),
    drugbank_id VARCHAR(50),
    pubchem_id VARCHAR(50)
);

LOAD DATA LOCAL INFILE
  'data/released/db/drug.csv'
INTO TABLE drug
FIELDS
  TERMINATED BY ','
  ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES;

-- -----------------------------------------------------
-- Patient
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS patient (
    record_id VARCHAR(50),
    patient_id VARCHAR(50)
);

LOAD DATA LOCAL INFILE
  'data/released/db/patient.csv'
INTO TABLE patient
FIELDS
  TERMINATED BY ','
  ENCLOSED BY '"'
LINES
  TERMINATED BY '\n'
IGNORE 1 LINES;

-- -----------------------------------------------------
-- json
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS json (
    record_id VARCHAR(50),
    body TEXT
);
