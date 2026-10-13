-- Pruebas negativas. Cada bloque debe terminar con una excepcion esperada.
-- Se usa una transaccion local para que ninguna operacion invalida persista.

BEGIN;

-- 1. Duplicado: mismo correo de persona.
SAVEPOINT invalid_duplicate;
DO $$
BEGIN
    BEGIN
        INSERT INTO person (full_name, email, country)
        VALUES ('Correo Duplicado', 'ana.torres@example.org', 'Colombia');
        RAISE EXCEPTION 'FALLO: se acepto un correo duplicado';
    EXCEPTION WHEN unique_violation THEN
        NULL;
    END;
END $$;
ROLLBACK TO SAVEPOINT invalid_duplicate;

-- 2. FK inexistente: acreditacion no registrada.
SAVEPOINT invalid_fk;
DO $$
BEGIN
    BEGIN
        INSERT INTO attendee (edition_id, person_id, accreditation_type_id)
        VALUES (1, 1, 99999);
        RAISE EXCEPTION 'FALLO: se acepto una FK inexistente';
    EXCEPTION WHEN foreign_key_violation THEN
        NULL;
    END;
END $$;
ROLLBACK TO SAVEPOINT invalid_fk;

-- 3. Dominio invalido: capacidad negativa.
SAVEPOINT invalid_domain;
DO $$
BEGIN
    BEGIN
        INSERT INTO room (venue_id, name, capacity)
        VALUES (1, 'Sala Imposible', -10);
        RAISE EXCEPTION 'FALLO: se acepto una capacidad negativa';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;
END $$;
ROLLBACK TO SAVEPOINT invalid_domain;

-- 4. Obligatorio ausente: persona sin nombre.
SAVEPOINT invalid_required;
DO $$
BEGIN
    BEGIN
        INSERT INTO person (full_name, email, country)
        VALUES (NULL, 'sin.nombre@example.org', 'Colombia');
        RAISE EXCEPTION 'FALLO: se acepto un nombre nulo';
    EXCEPTION WHEN not_null_violation THEN
        NULL;
    END;
END $$;
ROLLBACK TO SAVEPOINT invalid_required;

-- 5. Autorrelacion invalida: una sesion no puede ser prerrequisito de si misma.
SAVEPOINT invalid_self_relation;
DO $$
DECLARE
    any_session bigint;
BEGIN
    SELECT session_id INTO any_session FROM session ORDER BY session_id LIMIT 1;
    BEGIN
        INSERT INTO session_prerequisite (session_id, prerequisite_session_id)
        VALUES (any_session, any_session);
        RAISE EXCEPTION 'FALLO: se acepto un autorprerrequisito';
    EXCEPTION WHEN check_violation THEN
        NULL;
    END;
END $$;
ROLLBACK TO SAVEPOINT invalid_self_relation;

-- 6. Adicional: una empresa no puede repetir acuerdo en una edicion.
SAVEPOINT invalid_agreement_duplicate;
DO $$
DECLARE
    selected_company bigint;
    selected_edition bigint;
BEGIN
    SELECT company_id INTO selected_company
    FROM sponsor_company ORDER BY company_id LIMIT 1;
    SELECT edition_id INTO selected_edition
    FROM edition ORDER BY edition_id LIMIT 1;
    BEGIN
        INSERT INTO sponsorship_agreement (
            company_id, edition_id, category, amount
        ) VALUES (
            selected_company, selected_edition, 'PLATA', 1000.00
        );
        RAISE EXCEPTION 'FALLO: se acepto un acuerdo duplicado';
    EXCEPTION WHEN unique_violation THEN
        NULL;
    END;
END $$;
ROLLBACK TO SAVEPOINT invalid_agreement_duplicate;

ROLLBACK;
