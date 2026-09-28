CREATE SCHEMA IF NOT EXISTS raw;



CREATE TABLE IF NOT EXISTS raw.ingestion_batches (
    batch_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    source TEXT NOT NULL,
    file_hash VARCHAR(64) UNIQUE NOT NULL,
    ingested_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE IF NOT EXISTS raw.agency (
    batch_id BIGINT NOT NULL,
    agency_id TEXT NOT NULL,
    agency_name TEXT,
    agency_url TEXT,
    agency_timezone TEXT,
    agency_lang TEXT,
    agency_phone TEXT,
    agency_fare_url TEXT,
    agency_email TEXT,

    CONSTRAINT fk_agency_batch
    FOREIGN KEY (batch_id)
    REFERENCES raw.ingestion_batches(batch_id)
    ON DELETE CASCADE,

    CONSTRAINT uq_agency_batch
        UNIQUE (batch_id, agency_id)
);


CREATE TABLE IF NOT EXISTS raw.stops (
    batch_id BIGINT NOT NULL,
    stop_id TEXT NOT NULL,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat DOUBLE PRECISION,
    stop_lon DOUBLE PRECISION,
    location_type TEXT,
    platform_code TEXT,
    parent_station TEXT,
    level_id TEXT,

    CONSTRAINT fk_stops_batch
        FOREIGN KEY (batch_id)
        REFERENCES raw.ingestion_batches(batch_id)
        ON DELETE CASCADE,

    CONSTRAINT uq_stops_batch
        UNIQUE (batch_id, stop_id)
);