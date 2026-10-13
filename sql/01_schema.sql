-- ConectaTech: esquema relacional PostgreSQL 18
-- Solo contiene sentencias CREATE TABLE.

CREATE TABLE venue (
    venue_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name varchar(140) NOT NULL,
    city varchar(100) NOT NULL,
    address varchar(240),
    UNIQUE (name, city)
);

CREATE TABLE edition (
    edition_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name varchar(160) NOT NULL,
    edition_year integer NOT NULL,
    modality varchar(12) NOT NULL,
    starts_on date NOT NULL,
    ends_on date NOT NULL,
    status varchar(12) NOT NULL DEFAULT 'PLANIFICADA',
    venue_id bigint,
    UNIQUE (name, edition_year),
    FOREIGN KEY (venue_id) REFERENCES venue (venue_id),
    CHECK (edition_year BETWEEN 2000 AND 2100),
    CHECK (modality IN ('PRESENCIAL', 'VIRTUAL', 'HIBRIDA')),
    CHECK (status IN ('PLANIFICADA', 'ABIERTA', 'EN_CURSO', 'FINALIZADA', 'CANCELADA')),
    CHECK (ends_on >= starts_on),
    CHECK ((modality = 'VIRTUAL' AND venue_id IS NULL)
        OR (modality IN ('PRESENCIAL', 'HIBRIDA') AND venue_id IS NOT NULL))
);

CREATE TABLE room (
    room_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    venue_id bigint NOT NULL REFERENCES venue (venue_id),
    name varchar(100) NOT NULL,
    capacity integer NOT NULL,
    UNIQUE (venue_id, name),
    UNIQUE (venue_id, room_id),
    CHECK (capacity > 0)
);

CREATE TABLE person (
    person_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name varchar(160) NOT NULL,
    email varchar(254) NOT NULL UNIQUE,
    country varchar(80) NOT NULL,
    CHECK (position('@' IN email) > 1),
    CHECK (length(trim(full_name)) >= 2)
);

CREATE TABLE accreditation_type (
    accreditation_type_id smallint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name varchar(60) NOT NULL UNIQUE,
    price numeric(10,2) NOT NULL DEFAULT 0,
    CHECK (price >= 0)
);

CREATE TABLE edition_participant (
    edition_id bigint NOT NULL REFERENCES edition (edition_id),
    person_id bigint NOT NULL REFERENCES person (person_id),
    registered_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (edition_id, person_id)
);

CREATE TABLE attendee (
    edition_id bigint NOT NULL,
    person_id bigint NOT NULL,
    accreditation_type_id smallint NOT NULL REFERENCES accreditation_type (accreditation_type_id),
    PRIMARY KEY (edition_id, person_id),
    FOREIGN KEY (edition_id, person_id)
        REFERENCES edition_participant (edition_id, person_id)
);

CREATE TABLE speaker (
    edition_id bigint NOT NULL,
    person_id bigint NOT NULL,
    biography text NOT NULL,
    PRIMARY KEY (edition_id, person_id),
    FOREIGN KEY (edition_id, person_id)
        REFERENCES edition_participant (edition_id, person_id),
    CHECK (length(trim(biography)) >= 20)
);

CREATE TABLE session (
    session_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    edition_id bigint NOT NULL REFERENCES edition (edition_id),
    title varchar(180) NOT NULL,
    summary text NOT NULL,
    kind varchar(7) NOT NULL,
    starts_at timestamptz NOT NULL,
    ends_at timestamptz NOT NULL,
    room_id bigint,
    venue_id bigint,
    streaming_platform varchar(100),
    streaming_url varchar(500),
    question_minutes integer,
    practical_capacity integer,
    material_requirements text,
    UNIQUE (edition_id, session_id),
    FOREIGN KEY (venue_id, room_id)
        REFERENCES room (venue_id, room_id),
    CHECK (kind IN ('CHARLA', 'TALLER')),
    CHECK (ends_at > starts_at),
    CHECK ((kind = 'CHARLA'
            AND question_minutes IS NOT NULL AND question_minutes BETWEEN 0 AND 60
            AND practical_capacity IS NULL AND material_requirements IS NULL)
        OR (kind = 'TALLER'
            AND practical_capacity IS NOT NULL AND practical_capacity > 0
            AND material_requirements IS NOT NULL AND length(trim(material_requirements)) > 0
            AND question_minutes IS NULL)),
    CHECK ((room_id IS NULL AND venue_id IS NULL)
        OR (room_id IS NOT NULL AND venue_id IS NOT NULL)),
    CHECK ((streaming_platform IS NOT NULL AND streaming_url IS NOT NULL)
        OR (streaming_platform IS NULL AND streaming_url IS NULL))
);

CREATE TABLE session_prerequisite (
    session_id bigint NOT NULL REFERENCES session (session_id) ON DELETE CASCADE,
    prerequisite_session_id bigint NOT NULL REFERENCES session (session_id) ON DELETE RESTRICT,
    PRIMARY KEY (session_id, prerequisite_session_id),
    CHECK (session_id <> prerequisite_session_id)
);

CREATE TABLE registration (
    edition_id bigint NOT NULL,
    person_id bigint NOT NULL,
    session_id bigint NOT NULL,
    registered_at timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status varchar(12) NOT NULL DEFAULT 'RESERVADA',
    attended boolean,
    PRIMARY KEY (edition_id, person_id, session_id),
    FOREIGN KEY (edition_id, person_id)
        REFERENCES attendee (edition_id, person_id),
    FOREIGN KEY (edition_id, session_id)
        REFERENCES session (edition_id, session_id),
    CHECK (status IN ('RESERVADA', 'CONFIRMADA', 'CANCELADA')),
    CHECK (status <> 'CANCELADA' OR attended IS NULL)
);

CREATE TABLE session_speaker (
    edition_id bigint NOT NULL,
    session_id bigint NOT NULL,
    person_id bigint NOT NULL,
    speaker_role varchar(80) NOT NULL,
    program_order smallint NOT NULL,
    PRIMARY KEY (edition_id, session_id, person_id),
    FOREIGN KEY (edition_id, session_id)
        REFERENCES session (edition_id, session_id) ON DELETE CASCADE,
    FOREIGN KEY (edition_id, person_id)
        REFERENCES speaker (edition_id, person_id),
    UNIQUE (edition_id, session_id, program_order),
    CHECK (program_order > 0),
    CHECK (length(trim(speaker_role)) > 0)
);

CREATE TABLE sponsor_company (
    company_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    legal_name varchar(180) NOT NULL UNIQUE,
    tax_identifier varchar(40) NOT NULL UNIQUE
);

CREATE TABLE sponsorship_agreement (
    agreement_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    company_id bigint NOT NULL REFERENCES sponsor_company (company_id),
    edition_id bigint NOT NULL REFERENCES edition (edition_id),
    category varchar(8) NOT NULL,
    amount numeric(12,2) NOT NULL,
    confirmed_on date NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (company_id, edition_id),
    CHECK (category IN ('PLATINO', 'ORO', 'PLATA', 'BRONCE')),
    CHECK (amount > 0),
    CHECK (confirmed_on >= DATE '2000-01-01')
);
