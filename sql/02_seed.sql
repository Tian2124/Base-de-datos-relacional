-- Datos semilla mínimos: 2 ediciones, 6 personas, 6 sesiones,
-- 8 inscripciones, 4 asignaciones de ponentes y 3 acuerdos.

INSERT INTO venue (name, city, address) VALUES
    ('Centro de Convenciones Norte', 'Bogota', 'Av. Central 100'),
    ('Auditorio Digital', 'Medellin', 'Calle 50 20-10');

INSERT INTO edition (name, edition_year, modality, starts_on, ends_on, status, venue_id)
SELECT 'Cumbre de Datos', 2026, 'HIBRIDA', DATE '2026-10-14', DATE '2026-10-16', 'ABIERTA', venue_id
FROM venue WHERE name = 'Centro de Convenciones Norte' AND city = 'Bogota'
UNION ALL
SELECT 'Foro Cloud', 2027, 'VIRTUAL', DATE '2027-05-20', DATE '2027-05-21', 'PLANIFICADA', NULL;

INSERT INTO room (venue_id, name, capacity)
SELECT venue_id, room_name, capacity
FROM venue v
CROSS JOIN (VALUES ('Sala Andina', 250), ('Sala Caribe', 120)) AS r(room_name, capacity)
WHERE v.name = 'Centro de Convenciones Norte';

INSERT INTO accreditation_type (name, price) VALUES
    ('General', 80.00), ('Estudiante', 35.00), ('VIP', 180.00);

INSERT INTO person (full_name, email, country) VALUES
    ('Ana Torres', 'ana.torres@example.org', 'Colombia'),
    ('Bruno Silva', 'bruno.silva@example.org', 'Brasil'),
    ('Carla Mendes', 'carla.mendes@example.org', 'Mexico'),
    ('Diego Ruiz', 'diego.ruiz@example.org', 'Chile'),
    ('Elena Costa', 'elena.costa@example.org', 'Argentina'),
    ('Fabian Gomez', 'fabian.gomez@example.org', 'Peru');

INSERT INTO edition_participant (edition_id, person_id)
SELECT e.edition_id, p.person_id
FROM edition e CROSS JOIN person p;

INSERT INTO attendee (edition_id, person_id, accreditation_type_id)
SELECT e.edition_id, p.person_id, a.accreditation_type_id
FROM edition e
JOIN person p ON p.email IN ('ana.torres@example.org', 'carla.mendes@example.org', 'elena.costa@example.org', 'fabian.gomez@example.org')
JOIN accreditation_type a ON a.name = CASE WHEN p.email LIKE 'ana.%' OR p.email LIKE 'elena.%' THEN 'VIP' ELSE 'General' END
WHERE e.name = 'Cumbre de Datos' AND e.edition_year = 2026;

INSERT INTO attendee (edition_id, person_id, accreditation_type_id)
SELECT e.edition_id, p.person_id, a.accreditation_type_id
FROM edition e
JOIN person p ON p.email IN ('ana.torres@example.org', 'bruno.silva@example.org', 'carla.mendes@example.org', 'diego.ruiz@example.org')
JOIN accreditation_type a ON a.name = 'General'
WHERE e.name = 'Foro Cloud' AND e.edition_year = 2027;

INSERT INTO speaker (edition_id, person_id, biography)
SELECT e.edition_id, p.person_id, b.biography
FROM edition e
JOIN (VALUES
    ('bruno.silva@example.org', 'Arquitecto de datos y formador profesional en plataformas analiticas.'),
    ('diego.ruiz@example.org', 'Especialista en seguridad cloud y gobierno de infraestructura empresarial.'),
    ('elena.costa@example.org', 'Investigadora de aprendizaje automatico aplicado a negocios digitales.'),
    ('fabian.gomez@example.org', 'Consultor de bases de datos distribuidas y sistemas de alta disponibilidad.')
) AS b(email, biography) ON true
JOIN person p ON p.email = b.email
WHERE e.edition_year = 2026;

INSERT INTO speaker (edition_id, person_id, biography)
SELECT e.edition_id, p.person_id, b.biography
FROM edition e
JOIN (VALUES
    ('bruno.silva@example.org', 'Arquitecto de datos y formador profesional en plataformas analiticas.'),
    ('diego.ruiz@example.org', 'Especialista en seguridad cloud y gobierno de infraestructura empresarial.')
) AS b(email, biography) ON true
JOIN person p ON p.email = b.email
WHERE e.edition_year = 2027;

INSERT INTO session (edition_id, title, summary, kind, starts_at, ends_at, venue_id, room_id, question_minutes)
SELECT e.edition_id, s.title, s.summary, 'CHARLA', s.starts_at, s.ends_at, v.venue_id, r.room_id, s.question_minutes
FROM edition e
JOIN venue v ON v.name = 'Centro de Convenciones Norte'
JOIN (VALUES
    ('Panorama de datos', 'Tendencias actuales de plataformas de datos.', TIMESTAMPTZ '2026-10-14 09:00-05', TIMESTAMPTZ '2026-10-14 10:00-05', 15),
    ('Seguridad en la nube', 'Controles practicos para servicios cloud.', TIMESTAMPTZ '2026-10-14 10:30-05', TIMESTAMPTZ '2026-10-14 11:30-05', 10),
    ('ML responsable', 'Criterios para modelos auditables.', TIMESTAMPTZ '2026-10-15 09:00-05', TIMESTAMPTZ '2026-10-15 10:00-05', 15)
) AS s(title, summary, starts_at, ends_at, question_minutes) ON true
JOIN room r ON r.venue_id = v.venue_id AND r.name = CASE WHEN s.title = 'Panorama de datos' THEN 'Sala Andina' ELSE 'Sala Caribe' END
WHERE e.edition_year = 2026;

INSERT INTO session (edition_id, title, summary, kind, starts_at, ends_at, question_minutes, streaming_platform, streaming_url)
SELECT e.edition_id, s.title, s.summary, 'CHARLA', s.starts_at, s.ends_at, 10, 'VideoMeet', s.url
FROM edition e
JOIN (VALUES
    ('Arquitectura serverless', 'Patrones para soluciones sin servidores.', TIMESTAMPTZ '2027-05-20 10:00+00', TIMESTAMPTZ '2027-05-20 11:00+00', 'https://stream.example.org/serverless'),
    ('Observabilidad moderna', 'Metricas y trazas para equipos distribuidos.', TIMESTAMPTZ '2027-05-20 11:30+00', TIMESTAMPTZ '2027-05-20 12:30+00', 'https://stream.example.org/observability'),
    ('Datos para decisiones', 'Como convertir analitica en decisiones medibles.', TIMESTAMPTZ '2027-05-21 10:00+00', TIMESTAMPTZ '2027-05-21 11:00+00', 'https://stream.example.org/decisions')
) AS s(title, summary, starts_at, ends_at, url) ON true
WHERE e.edition_year = 2027;

INSERT INTO session_prerequisite (session_id, prerequisite_session_id)
SELECT advanced.session_id, base.session_id
FROM session advanced CROSS JOIN session base
WHERE advanced.title = 'ML responsable' AND base.title = 'Panorama de datos';

INSERT INTO registration (edition_id, person_id, session_id, status, attended)
SELECT e.edition_id, p.person_id, s.session_id, 'CONFIRMADA', true
FROM edition e
JOIN person p ON p.email IN ('ana.torres@example.org', 'carla.mendes@example.org', 'elena.costa@example.org', 'fabian.gomez@example.org')
JOIN session s ON s.edition_id = e.edition_id AND s.title IN ('Panorama de datos', 'Seguridad en la nube')
WHERE e.edition_year = 2026
  AND ((p.email IN ('ana.torres@example.org', 'carla.mendes@example.org') AND s.title = 'Panorama de datos')
    OR (p.email IN ('elena.costa@example.org', 'fabian.gomez@example.org') AND s.title = 'Seguridad en la nube'));

INSERT INTO registration (edition_id, person_id, session_id, status, attended)
SELECT e.edition_id, p.person_id, s.session_id, 'RESERVADA', NULL
FROM edition e
JOIN person p ON p.email IN ('ana.torres@example.org', 'bruno.silva@example.org', 'carla.mendes@example.org', 'diego.ruiz@example.org')
JOIN session s ON s.edition_id = e.edition_id
                            AND s.title IN ('Arquitectura serverless', 'Observabilidad moderna')
WHERE e.edition_year = 2027
    AND ((p.email IN ('ana.torres@example.org', 'bruno.silva@example.org') AND s.title = 'Arquitectura serverless')
        OR (p.email IN ('carla.mendes@example.org', 'diego.ruiz@example.org') AND s.title = 'Observabilidad moderna'));

INSERT INTO session_speaker (edition_id, session_id, person_id, speaker_role, program_order)
SELECT s.edition_id, s.session_id, p.person_id, x.speaker_role, x.program_order
FROM session s
JOIN (VALUES
    ('Panorama de datos', 'bruno.silva@example.org', 'Ponente principal', 1),
    ('Seguridad en la nube', 'diego.ruiz@example.org', 'Ponente principal', 1),
    ('ML responsable', 'elena.costa@example.org', 'Ponente principal', 1),
    ('Arquitectura serverless', 'bruno.silva@example.org', 'Ponente principal', 1)
) AS x(title, email, speaker_role, program_order) ON x.title = s.title
JOIN person p ON p.email = x.email;

INSERT INTO sponsor_company (legal_name, tax_identifier) VALUES
    ('Nube Andina S.A.S.', '900100001-1'),
    ('Datos Abiertos Ltda.', '900100002-2'),
    ('SeguraTech S.A.', '900100003-3');

INSERT INTO sponsorship_agreement (company_id, edition_id, category, amount)
SELECT c.company_id, e.edition_id, x.category, x.amount
FROM (VALUES
    ('Nube Andina S.A.S.', 'Cumbre de Datos', 'PLATINO', 25000.00),
    ('Datos Abiertos Ltda.', 'Cumbre de Datos', 'ORO', 12000.00),
    ('SeguraTech S.A.', 'Foro Cloud', 'PLATA', 7000.00)
) AS x(company, edition_name, category, amount)
JOIN sponsor_company c ON c.legal_name = x.company
JOIN edition e ON e.name = x.edition_name;
