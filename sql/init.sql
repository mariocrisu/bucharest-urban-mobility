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

    PRIMARY KEY (batch_id, agency_id),

    FOREIGN KEY (batch_id)
        REFERENCES raw.ingestion_batches(batch_id)
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS raw.stops (
    batch_id BIGINT NOT NULL,
    stop_id TEXT NOT NULL,
    stop_name TEXT,
    stop_desc TEXT,
    stop_lat TEXT,
    stop_lon TEXT,
    location_type TEXT,
    platform_code TEXT,
    parent_station TEXT,
    level_id TEXT,

    PRIMARY KEY (batch_id, stop_id),

    FOREIGN KEY (batch_id)
        REFERENCES raw.ingestion_batches(batch_id)
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS raw.routes (
    batch_id BIGINT NOT NULL,
    route_id TEXT NOT NULL,
    agency_id TEXT,
    route_short_name TEXT,
    route_long_name TEXT,
    route_type TEXT,
    route_color TEXT,
    route_text_color TEXT,

    PRIMARY KEY (batch_id, route_id),

    FOREIGN KEY (batch_id)
        REFERENCES raw.ingestion_batches(batch_id)
        ON DELETE CASCADE,

    FOREIGN KEY (batch_id, agency_id)
        REFERENCES raw.agency(batch_id, agency_id)
);


CREATE TABLE IF NOT EXISTS raw.calendar (
    batch_id BIGINT NOT NULL,
    service_id TEXT NOT NULL,
    monday TEXT,
    tuesday TEXT,
    wednesday TEXT,
    thursday TEXT,
    friday TEXT,
    saturday TEXT,
    sunday TEXT,
    start_date TEXT,
    end_date TEXT,

    PRIMARY KEY (batch_id, service_id),

    FOREIGN KEY (batch_id)
        REFERENCES raw.ingestion_batches(batch_id)
        ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS raw.trips (
    batch_id BIGINT NOT NULL,
    route_id TEXT NOT NULL,
    service_id TEXT NOT NULL,
    trip_id TEXT NOT NULL,
    trip_headsign TEXT,
    trip_short_name TEXT,
    direction_id TEXT,
    block_id TEXT,
    shape_id TEXT,
    wheelchair_accessible TEXT,
    bikes_allowed TEXT,

    PRIMARY KEY (batch_id, trip_id),

    FOREIGN KEY (batch_id)
        REFERENCES raw.ingestion_batches(batch_id)
        ON DELETE CASCADE,

    FOREIGN KEY (batch_id, route_id)
        REFERENCES raw.routes(batch_id, route_id),

    FOREIGN KEY (batch_id, service_id)
        REFERENCES raw.calendar(batch_id, service_id)
);


CREATE TABLE IF NOT EXISTS raw.stop_times (
    batch_id BIGINT NOT NULL,
    trip_id TEXT NOT NULL,
    arrival_time TEXT,
    departure_time TEXT,
    stop_id TEXT NOT NULL,
    stop_sequence TEXT NOT NULL,
    stop_headsign TEXT,
    pickup_type TEXT,
    drop_off_type TEXT,
    shape_dist_traveled TEXT,
    timepoint TEXT,

    PRIMARY KEY (batch_id, trip_id, stop_sequence),

    FOREIGN KEY (batch_id)
        REFERENCES raw.ingestion_batches(batch_id)
        ON DELETE CASCADE,

    FOREIGN KEY (batch_id, trip_id)
        REFERENCES raw.trips(batch_id, trip_id),

    FOREIGN KEY (batch_id, stop_id)
        REFERENCES raw.stops(batch_id, stop_id)
);


CREATE TABLE IF NOT EXISTS raw.shapes (
    batch_id BIGINT NOT NULL,
    shape_id TEXT NOT NULL,
    shape_pt_lat TEXT,
    shape_pt_lon TEXT,
    shape_pt_sequence TEXT NOT NULL,

    PRIMARY KEY (
        batch_id,
        shape_id,
        shape_pt_sequence
    ),

    FOREIGN KEY (batch_id)
        REFERENCES raw.ingestion_batches(batch_id)
        ON DELETE CASCADE
);