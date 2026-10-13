# Narrativa y reglas de negocio

## Alcance

ConectaTech organiza ediciones de congresos profesionales en modalidad presencial, virtual o hibrida. Cada edicion tiene un programa de sesiones, personas participantes, inscripciones, ponentes y acuerdos de patrocinio.

## Entidades y relaciones

- Una edicion puede usar una sede; una sede contiene muchas salas.
- Una edicion registra muchas personas mediante `edition_participant`.
- Una persona puede ser asistente, ponente o ambas dentro de una edicion. Es una jerarquia solapada y parcial.
- Una edicion contiene muchas sesiones.
- Cada sesion es exactamente una charla o un taller. Es una jerarquia disjunta y total.
- Una sesion puede tener muchos asistentes y un asistente puede inscribirse en muchas sesiones; `registration` resuelve la relacion N:M.
- Una sesion puede tener muchos ponentes y un ponente puede intervenir en muchas sesiones; `session_speaker` resuelve la relacion N:M.
- Una sesion puede requerir otras sesiones como prerrequisitos; es una relacion recursiva N:M.
- Una empresa puede patrocinar varias ediciones y una edicion puede tener varias empresas; `sponsorship_agreement` registra la relacion N:M.
- Cada acuerdo pertenece a una unica empresa y una unica edicion.
- Cada participante puede tener a lo sumo un registro de asistente y uno de ponente por edicion.

## Reglas de negocio

1. El nombre y el ano identifican de forma unica una edicion.
2. La fecha final de una edicion no puede ser anterior a su fecha inicial.
3. Una edicion virtual no tiene sede; una presencial o hibrida si tiene sede.
4. Una sede no puede repetir el nombre de una sala.
5. La capacidad de una sala debe ser positiva.
6. El correo de una persona es unico y debe tener una forma minima valida.
7. Toda persona inscrita en una edicion debe ser participante de esa edicion.
8. Un participante puede ejercer ambos roles: asistente y ponente.
9. Una biografia de ponente es obligatoria y debe tener contenido suficiente.
10. Toda sesion tiene inicio anterior a su fin.
11. Toda sesion es charla o taller, nunca ambas ni ninguna.
12. Una charla registra minutos de preguntas y no registra cupo ni materiales de taller.
13. Un taller registra cupo practico y requisitos de materiales, y no registra minutos de preguntas.
14. Una sesion presencial requiere sala; una sesion virtual requiere datos de transmision y no usa sala.
15. Una sala no puede alojar dos sesiones con horarios superpuestos.
16. Una sesion no puede ser prerrequisito de si misma.
17. No se puede repetir la inscripcion de una persona en una sesion.
18. Solo un asistente de la misma edicion puede inscribirse en una sesion.
19. Solo un ponente de la misma edicion puede ser asignado a una sesion.
20. El orden de aparicion de un ponente es unico dentro de una sesion.
21. Una empresa no puede tener mas de un acuerdo por edicion.
22. El monto de patrocinio debe ser positivo.

## Supuestos y decisiones

- La identidad de una persona es global; su rol se determina por edicion.
- Se usa una entidad participante para soportar la jerarquia solapada sin duplicar datos personales.
- La jerarquia de sesiones se implementa con una columna discriminadora y `CHECK` condicionales.
- La prevencion de ciclos de prerrequisitos queda abierta salvo la autorrelacion directa; la regla explicita exige impedir que una sesion sea su propio prerrequisito.
- Los dominios se implementan como `varchar` con restricciones `CHECK`, para que el archivo de esquema contenga unicamente `CREATE TABLE`.
- La regla de no solapamiento de salas queda documentada para validarse mediante consultas; no se implementa en el esquema declarativo porque se eliminaron extensiones y triggers por el alcance academico.
