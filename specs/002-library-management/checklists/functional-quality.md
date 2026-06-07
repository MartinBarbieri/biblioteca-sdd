# Requirements Quality Checklist: Sistema de Gestión de Biblioteca

**Purpose**: Validate specification completeness, clarity, and consistency before planning phase  
**Created**: 2026-06-07  
**Depth**: Standard (25-35 items)  
**Focus**: Balanced completeness + clarity + consistency  
**Audience**: Development team (architects + developers)  
**Feature**: [spec.md](../spec.md)

---

## Requirement Completeness

- [ ] CHK001 - ¿Todas las historias de usuario (US1-US4) cubren actores identificados (bibliotecario, cliente)? [Spec §User Scenarios]
- [ ] CHK002 - ¿User Story 1 (Préstamos) define al menos 4 flujos claros (crear, validar, rechazar, devolver)? [Spec §US1]
- [ ] CHK003 - ¿User Story 2 (Catálogo) define CRUD completo (alta, modificación, baja)? [Spec §US2]
- [ ] CHK004 - ¿User Story 3 (Clientes) incluye la asignación automática de foto + gestión de datos? [Spec §US3]
- [ ] CHK005 - ¿User Story 4 (Disponibilidad) cubre búsqueda con múltiples criterios E informe de préstamos? [Spec §US4]
- [ ] CHK006 - ¿Los requisitos funcionales (FR-001 a FR-024) cubren todos los flujos principales identificados en US? [Spec §Functional Requirements]
- [ ] CHK007 - ¿FR-001 a FR-007 cubren gestión completa de libros/ejemplares? [Spec §FR-001-FR-007]
- [ ] CHK008 - ¿FR-008 a FR-014 cubren gestión completa de clientes incluyendo foto automática? [Spec §FR-008-FR-014]
- [ ] CHK009 - ¿FR-015 a FR-021 cubren ciclo completo de préstamos/devoluciones? [Spec §FR-015-FR-021]
- [ ] CHK010 - ¿FR-022 a FR-024 cubren búsqueda y disponibilidad? [Spec §FR-022-FR-024]
- [ ] CHK011 - ¿Los requisitos no funcionales (NFR-001 a NFR-007) cubren todas las dimensiones críticas (usabilidad, performance, escalabilidad, legalidad, arquitectura)? [Spec §Non-Functional Requirements]
- [ ] CHK012 - ¿Hay requisitos explícitos para cada entidad del dominio (Libro/Ejemplar, Cliente, Préstamo, Asignación de Foto)? [Spec §Key Entities]

## Requirement Clarity

- [ ] CHK013 - ¿El modelo "Libro = Ejemplar Físico Único" (no cantidades) está completamente especificado? ¿Es evidente que cada copy física es un registro independiente? [Spec §Key Entities, FR-004, FR-006]
- [ ] CHK014 - ¿"Foto de perfil automática" especifica exactamente el algoritmo: inicial del nombre → animal? ¿Qué ocurre sin match? [Spec §FR-014, Clarifications Q2]
- [ ] CHK015 - ¿"Límite de préstamos configurables" está claramente definido como variable por cliente O por política global? [Spec §FR-016, Clarifications Q5]
- [ ] CHK016 - ¿"Búsqueda disponible" especifica los 4 criterios (título parcial, autor, categoría, disponibilidad) y lógica AND? [Spec §FR-022, Clarifications Q4]
- [ ] CHK017 - ¿La consulta de disponibilidad "2 segundos" es un SLA o un objetivo indicativo? ¿En qué condiciones (carga normal, máxima)? [Spec §NFR-003, SC-001]
- [ ] CHK018 - ¿El "punto de 10 puntos por devolución anticipada" es exacto o un rango? ¿Se aplica siempre o hay condiciones? [Spec §FR-021, US1-Scenario 3]
- [ ] CHK019 - ¿"Devolución anticipada" está cuantificada exactamente como "antes de la fecha fin prevista"? ¿Incluye devolver el mismo día? [Spec §US1-Scenario 3-4]
- [ ] CHK020 - ¿"Copyright vigente" está definido como un valor booleano o requiere más precisión (ej. fecha vencimiento)? [Spec §FR-004, FR-023]

## Requirement Consistency

- [ ] CHK021 - ¿No hay contradicción entre FR-016 (múltiples préstamos) y FR-017 (rechazar si alcanzó límite)? ¿Ambas están alineadas? [Spec §FR-016, FR-017]
- [ ] CHK022 - ¿FR-007 (no dar de baja libro con préstamos activos) es consistente con la lógica de disponibilidad en FR-018-FR-019? [Spec §FR-007, FR-018-FR-019]
- [ ] CHK023 - ¿FR-013 y FR-014 (asignación automática de foto animal) son consistentes con Clarification Q2 (foto neutral si no hay match)? [Spec §FR-013-FR-014, Clarifications Q2]
- [ ] CHK024 - ¿NFR-001 (UX simple) y NFR-004 (escalabilidad 100k/10k) no crean trade-offs sin resolución? [Spec §NFR-001, NFR-004]
- [ ] CHK025 - ¿Los criterios de éxito (SC-001 a SC-006) son alcanzables con los requisitos funcionales definidos? [Spec §Success Criteria]
- [ ] CHK026 - ¿La autenticación (Clarification Q1: solo bibliotecario) no crea inconsistencias con permisos de cliente (consultar disponibilidad sin auth)? [Spec §Clarifications Q1, US4]

## Acceptance Criteria Quality

- [ ] CHK027 - ¿Cada usuario story (US1-US4) tiene al menos 3 escenarios de aceptación DADO-CUANDO-ENTONCES? ¿Son testeable independientemente? [Spec §US1-US4 Acceptance Scenarios]
- [ ] CHK028 - ¿Los criterios de aceptación validan el comportamiento positivo (happy path) y negativo (rechazo/error)? ¿Hay al menos un escenario de rechazo por story? [Spec §US1-US4 Acceptance Scenarios]
- [ ] CHK029 - ¿Los success criteria (SC-001-SC-006) son medibles con métricas objetivas y no dependen de opinión subjetiva? [Spec §Success Criteria]
- [ ] CHK030 - ¿Hay cobertura explícita de casos borde identificados en Edge Cases? ¿Todos tienen escenarios de aceptación o están explícitamente diferidos? [Spec §Edge Cases]

---

## Architecture & Domain Model Alignment

- [ ] CHK031 - ¿El modelo de entidades (Libro, Cliente, Préstamo, AsignacionFotoPerfil) refleja las reglas de negocio del dominio sin ser anémico? [Spec §Key Entities, Principio II]
- [ ] CHK032 - ¿Hay definición clara de responsabilidades entre entidades (ej: quién valida disponibilidad, quién calcula puntos)? [Spec §Key Entities, Principio III]

---

## Notes

- **Validación**: Post-clarification, pre-planning
- **Próxima fase**: `/speckit.plan` → generar plan.md, research.md, data-model.md
- **If blockers**: Items sin marcar requieren actualización de spec.md antes de pasar a planning
