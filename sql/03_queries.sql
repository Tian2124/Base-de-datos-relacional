-- Consultas de validacion y reconstruccion del programa.

-- 1. Ediciones y sede disponible.
SELECT e.name, e.edition_year, e.modality, e.starts_on, e.ends_on,
       v.name AS venue_name, v.city
FROM edition e
LEFT JOIN venue v ON v.venue_id = e.venue_id
ORDER BY e.edition_year;

-- 2. Programa completo, incluyendo sesiones virtuales.
SELECT e.name AS edition_name, s.title, s.kind, s.starts_at, s.ends_at,
       COALESCE(r.name, 'Virtual') AS room_name,
       COALESCE(s.streaming_platform, 'Presencial') AS delivery
FROM session s
JOIN edition e ON e.edition_id = s.edition_id
LEFT JOIN room r ON r.room_id = s.room_id
ORDER BY e.edition_year, s.starts_at;

-- 3. Cupos practicos y sesiones con conteo de inscritos.
SELECT s.title, s.practical_capacity,
       count(r.person_id) AS registered_count,
       s.practical_capacity - count(r.person_id) AS remaining_capacity
FROM session s
LEFT JOIN registration r
  ON r.edition_id = s.edition_id AND r.session_id = s.session_id
WHERE s.kind = 'TALLER'
GROUP BY s.session_id, s.title, s.practical_capacity;

-- 4. Participacion por edicion y rol.
SELECT e.name, p.full_name,
       (a.person_id IS NOT NULL) AS is_attendee,
       (sp.person_id IS NOT NULL) AS is_speaker
FROM edition_participant ep
JOIN edition e ON e.edition_id = ep.edition_id
JOIN person p ON p.person_id = ep.person_id
LEFT JOIN attendee a ON a.edition_id = ep.edition_id AND a.person_id = ep.person_id
LEFT JOIN speaker sp ON sp.edition_id = ep.edition_id AND sp.person_id = ep.person_id
ORDER BY e.edition_year, p.full_name;

-- 5. Ponentes en orden de programa.
SELECT e.name, s.title, ss.program_order, p.full_name, ss.speaker_role
FROM session_speaker ss
JOIN session s ON s.edition_id = ss.edition_id AND s.session_id = ss.session_id
JOIN edition e ON e.edition_id = s.edition_id
JOIN person p ON p.person_id = ss.person_id
ORDER BY e.edition_year, s.starts_at, ss.program_order;

-- 6. Prerrequisitos de cada sesion.
SELECT dependent.title AS session_title, prerequisite.title AS prerequisite_title
FROM session_prerequisite sp
JOIN session dependent ON dependent.session_id = sp.session_id
JOIN session prerequisite ON prerequisite.session_id = sp.prerequisite_session_id;

-- 7. Patrocinio vigente por edicion.
SELECT e.name, c.legal_name, sa.category, sa.amount, sa.confirmed_on
FROM sponsorship_agreement sa
JOIN edition e ON e.edition_id = sa.edition_id
JOIN sponsor_company c ON c.company_id = sa.company_id
ORDER BY e.edition_year, sa.amount DESC;

-- 8. Asistencia efectiva por sesion.
SELECT s.title,
       count(*) FILTER (WHERE r.attended IS TRUE) AS attended_count,
       count(*) AS registration_count
FROM registration r
JOIN session s ON s.edition_id = r.edition_id AND s.session_id = r.session_id
GROUP BY s.session_id, s.title
ORDER BY s.title;
