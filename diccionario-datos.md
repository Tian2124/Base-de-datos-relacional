# Diccionario de datos

## Dominios controlados mediante CHECK

| Columna | Valores |
|---|---|
| `edition.modality` | `PRESENCIAL`, `VIRTUAL`, `HIBRIDA` |
| `edition.status` | `PLANIFICADA`, `ABIERTA`, `EN_CURSO`, `FINALIZADA`, `CANCELADA` |
| `registration.status` | `RESERVADA`, `CONFIRMADA`, `CANCELADA` |
| `session.kind` | `CHARLA`, `TALLER` |
| `sponsorship_agreement.category` | `PLATINO`, `ORO`, `PLATA`, `BRONCE` |

## Tablas principales

| Tabla | Proposito | Clave primaria |
|---|---|---|
| `edition` | Ediciones del congreso | `edition_id` identidad |
| `venue` | Sedes fisicas | `venue_id` identidad |
| `room` | Salas de una sede | `room_id` identidad |
| `person` | Personas registradas | `person_id` identidad |
| `accreditation_type` | Tipos de acreditacion | `accreditation_type_id` identidad |
| `edition_participant` | Participacion de una persona en una edicion | `(edition_id, person_id)` |
| `attendee` | Rol de asistente | `(edition_id, person_id)` |
| `speaker` | Rol de ponente | `(edition_id, person_id)` |
| `session` | Sesiones del programa | `session_id` identidad |
| `session_prerequisite` | Prerrequisitos entre sesiones | `(session_id, prerequisite_session_id)` |
| `registration` | Inscripciones de asistentes | `(edition_id, person_id, session_id)` |
| `session_speaker` | Ponentes asignados a sesiones | `(edition_id, session_id, person_id)` |
| `sponsor_company` | Empresas patrocinadoras | `company_id` identidad |
| `sponsorship_agreement` | Acuerdos empresa-edicion | `agreement_id` identidad |

## Atributos relevantes

| Tabla | Atributos y reglas |
|---|---|
| `edition` | `name`, `edition_year`, `modality`, `starts_on`, `ends_on`, `status`, `venue_id`; nombre y ano son unicos. |
| `venue` | `name`, `city`, `address`; nombre y ciudad son unicos. |
| `room` | `venue_id`, `name`, `capacity`; capacidad positiva y nombre unico por sede. |
| `person` | `full_name`, `email`, `country`; nombre, correo y pais obligatorios; correo unico. |
| `edition_participant` | `registered_at` con valor por defecto temporal. |
| `attendee` | `accreditation_type_id` obligatorio y referenciado. |
| `speaker` | `biography` obligatoria con longitud minima. |
| `session` | `title`, `summary`, `kind`, `starts_at`, `ends_at`, ubicacion, transmision y atributos condicionales de charla/taller. |
| `registration` | Estado por defecto `RESERVADA`, fecha por defecto y asistencia nullable. |
| `session_speaker` | `speaker_role` obligatorio; `program_order` positivo y unico por sesion. |
| `sponsor_company` | `legal_name` y `tax_identifier` unicos. |
| `sponsorship_agreement` | Categoria, monto positivo, fecha de confirmacion por defecto y unicidad empresa-edicion. |
