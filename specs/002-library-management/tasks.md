# Tasks: Sistema de Gestión de Biblioteca

**Branch**: `002-add-library-management` | **Date**: 2026-06-07  
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md) | **Data Model**: [data-model.md](data-model.md)  
**Contrato**: [contracts/openapi.yaml](contracts/openapi.yaml) | **Quickstart**: [quickstart.md](quickstart.md)

---

## Format: `- [ ] [ID] [P?] [StoryN] Descripción — archivo/ruta`

- **[P]**: Paralelizable (archivos distintos, sin dependencia de tarea incompleta)
- **[US1–US4]**: Historia de usuario a la que pertenece
- Las fases 1–6 son backend; las fases 7–10 son frontend/validación

---

## Fase 1: Setup del Backend

**Propósito**: Estructura inicial del proyecto, configuración base y conexión a base de datos. Nada de US puede comenzar hasta completar esta fase.

**⚠️ Bloqueante para todas las fases de backend**

- [ ] T001 Crear proyecto Maven con Java 21 en `backend/pom.xml` con dependencias: Spring Boot 3.x, Spring Web, Spring Data JPA, Bean Validation, Flyway, springdoc-openapi 2.x, JUnit 5, Mockito, Testcontainers
- [ ] T002 [P] Crear `backend/src/main/resources/application.properties` con configuración de datasource PostgreSQL, Flyway y parámetros de la aplicación
- [ ] T003 [P] Crear estructura de paquetes vacía en `backend/src/main/java/com/biblioteca/`: `domain/model/`, `domain/repository/`, `application/service/`, `infrastructure/persistence/`, `api/controller/`, `api/dto/`
- [ ] T004 [P] Crear `backend/src/test/resources/application-test.properties` con configuración Testcontainers para PostgreSQL de pruebas

**Checkpoint**: Proyecto compila y arranca sin errores. Flyway conecta a la BD.

---

## Fase 2: Modelo de Dominio y Enums

**Propósito**: Entidades de dominio con sus reglas de negocio internas y enums de valores cerrados. Prerequisito para todo lo demás.

**⚠️ Bloqueante para Fases 3, 4, 5 y 6**

- [ ] T005 Crear enum `backend/src/main/java/com/biblioteca/domain/model/CategoriaLibro.java` con valores INFANTILES, JUVENILES, ADULTOS, CONOCIMIENTO — FR-005
- [ ] T006 [P] Crear enum `backend/src/main/java/com/biblioteca/domain/model/EstadoEjemplar.java` con valores ACTIVO, INACTIVO
- [ ] T007 [P] Crear enum `backend/src/main/java/com/biblioteca/domain/model/EstadoPrestamo.java` con valores ACTIVO, CERRADO
- [ ] T008 Crear entidad `backend/src/main/java/com/biblioteca/domain/model/Ejemplar.java` con todos los atributos de FR-004, anotaciones JPA (`@Entity`, `@Id`, `@GeneratedValue`) y método `esPrestablePorEstado(): boolean` que retorna `estadoEjemplar == ACTIVO && copyrightVigente` — sin acceso a préstamos
- [ ] T009 [P] Crear entidad `backend/src/main/java/com/biblioteca/domain/model/Cliente.java` con todos los atributos de FR-011, anotaciones JPA y método `estaHabilitado(): boolean` que retorna `estadoActivo`
- [ ] T010 [P] Crear entidad `backend/src/main/java/com/biblioteca/domain/model/Prestamo.java` con atributos de FR-015, anotaciones JPA, método `registrarDevolucion(LocalDate fecha)` que lanza excepción si `estadoPrestamo == CERRADO` y método `esDevolucionAnticipada(LocalDate fecha): boolean` — FR-020, FR-021, FR-031
- [ ] T011 [P] Crear entidad `backend/src/main/java/com/biblioteca/domain/model/FotoPerfilAnimal.java` con atributos id, inicial (char), nombreAnimal, rutaFoto — FR-034

**Checkpoint**: Las cuatro entidades compilan. Los enums son los únicos valores aceptados.

---

## Fase 3: Migraciones Flyway y Persistencia

**Propósito**: Esquema de base de datos, índices de performance y repositorios JPA.

**Depende de**: Fase 2 (entidades deben existir para que JPA valide el mapeo)

- [ ] T012 Crear `backend/src/main/resources/db/migration/V1__create_clientes.sql` con tabla `clientes`, constraint UNIQUE en `dni`, CHECK `puntos_acumulados >= 0` — data-model.md sección 4
- [ ] T013 [P] Crear `backend/src/main/resources/db/migration/V2__create_ejemplares.sql` con tabla `ejemplares`, CHECK `cantidad_paginas > 0`, CHECK enum `estado_ejemplar` — data-model.md sección 4
- [ ] T014 [P] Crear `backend/src/main/resources/db/migration/V3__create_prestamos.sql` con tabla `prestamos`, FK a `clientes` y `ejemplares`, CHECK enum `estado_prestamo` — data-model.md sección 4
- [ ] T015 [P] Crear `backend/src/main/resources/db/migration/V4__create_fotos_perfil_animal.sql` con tabla `fotos_perfil_animal`, UNIQUE en `inicial` — data-model.md sección 4
- [ ] T016 [P] Crear `backend/src/main/resources/db/migration/V5__seed_fotos_perfil_animal.sql` con INSERT de 26 letras + fila fallback `inicial='*'` — research.md sección 6, FR-034
- [ ] T017 Crear `backend/src/main/resources/db/migration/V6__create_indexes.sql` con índices: GIN en `titulo`, índice en `autor`, `categoria_libro`, índice parcial de disponibilidad en `ejemplares`, índice parcial de préstamos activos por ejemplar e índice de préstamos activos por cliente — data-model.md sección 4, SC-006
- [ ] T018 Crear interfaz `backend/src/main/java/com/biblioteca/domain/repository/EjemplarRepository.java` (interface) con métodos: `findById`, `save`, `findAll(Pageable)`, `existsByIdEjemplar`, query personalizada para búsqueda por filtros opcionales paginada — FR-025, FR-026
- [ ] T019 [P] Crear interfaz `backend/src/main/java/com/biblioteca/domain/repository/ClienteRepository.java` con métodos: `findById`, `save`, `existsByDni`, `findAll(Pageable)` — FR-012
- [ ] T020 [P] Crear interfaz `backend/src/main/java/com/biblioteca/domain/repository/PrestamoRepository.java` con métodos: `findById`, `save`, `existsByIdEjemplarAndEstadoPrestamo(ACTIVO)`, `countByIdClienteAndEstadoPrestamo(ACTIVO)`, `findAllByEstadoPrestamo(ACTIVO, Pageable)` — FR-018, FR-028
- [ ] T021 [P] Crear interfaz `backend/src/main/java/com/biblioteca/domain/repository/FotoPerfilAnimalRepository.java` con métodos: `findByInicial(char)`, `findByInicial('*')` — FR-034
- [ ] T022 Crear implementación `backend/src/main/java/com/biblioteca/infrastructure/persistence/JpaEjemplarRepository.java` extendiendo `JpaRepository` y `EjemplarRepository` con query JPQL para búsqueda con filtros opcionales — data-model.md sección 4 (query de disponibilidad)
- [ ] T023 [P] Crear `backend/src/main/java/com/biblioteca/infrastructure/persistence/JpaClienteRepository.java`
- [ ] T024 [P] Crear `backend/src/main/java/com/biblioteca/infrastructure/persistence/JpaPrestamoRepository.java`
- [ ] T025 [P] Crear `backend/src/main/java/com/biblioteca/infrastructure/persistence/JpaFotoPerfilAnimalRepository.java`

**Checkpoint**: Flyway ejecuta V1–V6 sin errores. Las tablas existen con índices.

---

## Fase 4: Servicios de Aplicación

**Propósito**: Casos de uso que orquestan dominio y persistencia. Contienen toda la coordinación de reglas cruzadas.

**Depende de**: Fase 3

- [ ] T026 Crear `backend/src/main/java/com/biblioteca/application/service/SelectorFotoPerfilAnimal.java` con método `seleccionar(String nombre): String` que normaliza inicial, consulta `FotoPerfilAnimalRepository` y retorna `rutaFoto`; usa fallback `'*'` si no hay coincidencia — FR-013, FR-014, FR-034
- [ ] T027 Crear `backend/src/main/java/com/biblioteca/application/service/EjemplarService.java` con métodos: `registrar(EjemplarRequest)`, `actualizar(Long id, EjemplarRequest)`, `darDeBaja(Long id)` (verifica no tener préstamos activos), `buscar(BusquedaRequest, Pageable)` — FR-001–FR-007, FR-025–FR-027
- [ ] T028 [P] Crear `backend/src/main/java/com/biblioteca/application/service/ClienteService.java` con métodos: `registrar(ClienteRequest)` (valida DNI único + asigna foto via `SelectorFotoPerfilAnimal`), `actualizar(Long id, ClienteRequest)`, `darDeBaja(Long id)` — FR-008–FR-014
- [ ] T029 Crear `backend/src/main/java/com/biblioteca/application/service/DisponibilidadService.java` con método `esDisponible(Long idEjemplar): boolean` que combina `ejemplar.esPrestablePorEstado()` con ausencia de préstamo activo en el repositorio — FR-022, FR-023, FR-024
- [ ] T030 Crear `backend/src/main/java/com/biblioteca/application/service/PrestamoService.java` con métodos: `registrar(PrestamoRequest)` (valida cliente habilitado, verifica disponibilidad via `DisponibilidadService`, crea préstamo), `registrarDevolucion(Long idPrestamo, LocalDate fecha)` (delega en `Prestamo.registrarDevolucion()`, suma puntos si anticipada) — FR-015–FR-021, FR-029–FR-032

**Checkpoint**: Todos los servicios compilan. Los métodos coordinan sin duplicar lógica de dominio.

---

## Fase 5: API REST

**Propósito**: Controladores REST, DTOs, mapeo HTTP y documentación OpenAPI.

**Depende de**: Fase 4

- [ ] T031 Crear DTOs en `backend/src/main/java/com/biblioteca/api/dto/`: `EjemplarRequest.java`, `EjemplarResponse.java`, `ClienteRequest.java`, `ClienteResponse.java`, `PrestamoRequest.java`, `PrestamoResponse.java`, `DevolucionRequest.java`, `DevolucionResponse.java`, `BusquedaEjemplarRequest.java`, `PaginaResponse.java`, `ErrorResponse.java` — contracts/openapi.yaml schemas
- [ ] T032 Crear `backend/src/main/java/com/biblioteca/api/controller/EjemplarController.java` con endpoints: `GET /ejemplares`, `POST /ejemplares`, `GET /ejemplares/{id}`, `PUT /ejemplares/{id}`, `DELETE /ejemplares/{id}`; normalizar `page <= 0` a `0`; máximo `size=100` — FR-001–FR-007, FR-025–FR-027, openapi.yaml
- [ ] T033 [P] Crear `backend/src/main/java/com/biblioteca/api/controller/ClienteController.java` con endpoints: `GET /clientes`, `POST /clientes`, `GET /clientes/{id}`, `PUT /clientes/{id}`, `DELETE /clientes/{id}` — FR-008–FR-014, openapi.yaml
- [ ] T034 [P] Crear `backend/src/main/java/com/biblioteca/api/controller/PrestamoController.java` con endpoints: `GET /prestamos` (informe activos paginado), `POST /prestamos`, `POST /prestamos/{id}/devolucion` — FR-015–FR-021, FR-028, FR-031, openapi.yaml
- [ ] T035 [P] Crear `backend/src/main/java/com/biblioteca/api/controller/DisponibilidadController.java` con endpoint: `GET /ejemplares/{id}/disponibilidad` que delega en `DisponibilidadService` — FR-022, FR-023, openapi.yaml
- [ ] T036 Crear `backend/src/main/java/com/biblioteca/api/GlobalExceptionHandler.java` con `@ControllerAdvice` que mapea excepciones de negocio (ejemplar no disponible, cliente inactivo, préstamo cerrado, DNI duplicado, idEjemplar duplicado) a respuestas HTTP con `ErrorResponse` y códigos 409/400/404 — openapi.yaml ErrorResponse, edge cases
- [ ] T037 [P] Configurar springdoc-openapi en `backend/src/main/resources/application.properties` con path `/v3/api-docs` y SwaggerUI en `/swagger-ui.html` — plan.md Technical Context

**Checkpoint**: `GET /ejemplares`, `POST /prestamos`, `POST /prestamos/{id}/devolucion` responden correctamente desde Swagger UI.

---

## Fase 6: Tests del Backend

**Propósito**: Tests unitarios de dominio, tests de servicios, tests de repositorio y tests de integración de endpoints.

**Depende de**: Fases 2–5 (cada suite depende de la capa que testea)

### Tests de dominio (depende de Fase 2)

- [ ] T038 Crear `backend/src/test/java/com/biblioteca/domain/EjemplarTest.java` con casos: `esPrestablePorEstado()` retorna `true` cuando activo + copyright vigente; retorna `false` cuando inactivo; retorna `false` cuando copyright no vigente — FR-023
- [ ] T039 [P] Crear `backend/src/test/java/com/biblioteca/domain/PrestamoTest.java` con casos: `registrarDevolucion()` lanza excepción si ya cerrado; cierra el préstamo correctamente; `esDevolucionAnticipada()` retorna `true` si fecha < fechaFinPrevista; retorna `false` si fecha >= fechaFinPrevista — FR-020, FR-021, FR-031
- [ ] T040 [P] Crear `backend/src/test/java/com/biblioteca/domain/ClienteTest.java` con caso: `estaHabilitado()` retorna `true` solo si `estadoActivo=true` — FR-030

### Tests de servicios (depende de Fases 2 y 4)

- [ ] T041 Crear `backend/src/test/java/com/biblioteca/application/PrestamoServiceTest.java` con Mockito, casos: registrar préstamo exitoso; rechazar si cliente inactivo; rechazar si ejemplar no disponible; registrar devolución anticipada suma 10 puntos; devolución no anticipada no suma puntos — US1, FR-018–FR-021, FR-030
- [ ] T042 [P] Crear `backend/src/test/java/com/biblioteca/application/EjemplarServiceTest.java` con Mockito, casos: dar de baja sin préstamos activos; rechazar baja con préstamos activos; buscar con filtros; buscar sin filtros retorna paginado — US2, FR-007, FR-025, FR-026
- [ ] T043 [P] Crear `backend/src/test/java/com/biblioteca/application/ClienteServiceTest.java` con Mockito, casos: registrar asigna foto correcta; registrar con inicial sin foto usa fallback; rechazar DNI duplicado; actualizar preserva puntos — US3, FR-012–FR-014
- [ ] T044 [P] Crear `backend/src/test/java/com/biblioteca/application/DisponibilidadServiceTest.java` con Mockito, casos: disponible cuando activo + copyright + sin préstamo; no disponible por préstamo activo; no disponible por copyright; no disponible por inactivo — FR-022, FR-023

### Tests de repositorio (depende de Fases 2, 3)

- [ ] T045 Crear `backend/src/test/java/com/biblioteca/infrastructure/EjemplarRepositoryTest.java` con Testcontainers PostgreSQL, casos: búsqueda por título parcial retorna correctos; búsqueda por categoría; búsqueda con múltiples filtros AND; búsqueda sin filtros paginada; búsqueda sobre 100k registros completa en ≤ 2s — SC-006, FR-025, FR-026

### Tests de integración de API (depende de Fases 2–5)

- [ ] T046 Crear `backend/src/test/java/com/biblioteca/api/EjemplarControllerTest.java` con `@WebMvcTest`, casos: POST crea ejemplar 201; POST con páginas=0 retorna 400; DELETE con préstamo activo retorna 409; GET con page=-1 normaliza a página 0 — quickstart.md escenarios 1–3, 17, 20
- [ ] T047 [P] Crear `backend/src/test/java/com/biblioteca/api/PrestamoControllerTest.java` con `@WebMvcTest`, casos: POST crea préstamo 201; POST ejemplar no disponible retorna 409 EJEMPLAR_NO_DISPONIBLE; POST devolucion anticipada retorna devolucionAnticipada=true y puntosOtorgados=10; POST devolucion duplicada retorna 409 PRESTAMO_YA_CERRADO — quickstart.md escenarios 6–10

**Checkpoint**: Todos los tests pasan en verde. Cobertura de reglas de negocio al 100%.

---

## Fase 7: Setup del Frontend

**Propósito**: Proyecto React + Vite + TypeScript con estructura base. Puede ejecutarse **en paralelo con la Fase 6** (no depende de tests).

**Depende de**: Fase 1 (estructura de repo definida). Puede iniciarse desde Fase 5 completa.

- [ ] T048 Inicializar proyecto Vite + React + TypeScript en `frontend/` con `npm create vite@latest frontend -- --template react-ts`; actualizar `frontend/package.json` con dependencias y scripts
- [ ] T049 [P] Crear `frontend/tsconfig.json` con configuración TypeScript estricta y path aliases para `src/`
- [ ] T050 [P] Crear `frontend/vite.config.ts` con proxy hacia `http://localhost:8080` para evitar CORS en desarrollo
- [ ] T051 [P] Crear tipos TypeScript en `frontend/src/types/`: `ejemplar.ts` (interfaces `Ejemplar`, `EjemplarRequest`, `PaginaResponse<T>`), `cliente.ts`, `prestamo.ts` — contracts/openapi.yaml schemas
- [ ] T052 [P] Crear `frontend/src/services/ejemplarService.ts` con funciones `listar(params)`, `obtener(id)`, `crear(data)`, `actualizar(id, data)`, `darDeBaja(id)`, `consultarDisponibilidad(id)` consumiendo la API REST — openapi.yaml /ejemplares
- [ ] T053 [P] Crear `frontend/src/services/clienteService.ts` con funciones `listar`, `obtener`, `crear`, `actualizar`, `darDeBaja` — openapi.yaml /clientes
- [ ] T054 [P] Crear `frontend/src/services/prestamoService.ts` con funciones `listarActivos`, `registrar`, `registrarDevolucion` — openapi.yaml /prestamos
- [ ] T055 [P] Crear `frontend/src/App.tsx` con router básico (`react-router-dom`) y navegación entre las 6 páginas principales
- [ ] T056 [P] Crear `frontend/src/components/PaginatedTable.tsx` componente reutilizable de tabla con paginación — FR-026, NFR-001

**Checkpoint**: `npm run dev` inicia el servidor. La app navega entre páginas vacías sin errores.

---

## Fase 8: Pantallas del Frontend

**Propósito**: Implementar las 6 pantallas principales con formularios y tablas.

**Depende de**: Fase 7

- [ ] T057 [US4] Crear `frontend/src/pages/BusquedaEjemplaresPage.tsx` como punto de entrada principal: formulario con filtros opcionales (título, autor, categoría, soloDisponibles), tabla paginada de resultados, estado "sin resultados" cuando lista vacía — US4-Scenario 1,2,5,6, NFR-001, FR-025, FR-026
- [ ] T058 [US2] Crear `frontend/src/pages/EjemplaresPage.tsx` con tabla de ejemplares, botón "Nuevo", acciones editar/dar de baja por fila, y `EjemplarForm.tsx` modal/inline con campos validados incluyendo checkbox `copyrightVigente` — US2, FR-001–FR-007
- [ ] T059 [P] [US2] Crear `frontend/src/components/EjemplarForm.tsx` con campos: título, autor, cantidadPaginas (min=1), editorial, ISBN, perteneceSaga, categoriaLibro (select con 4 opciones), copyrightVigente (checkbox obligatorio, etiqueta "Verificado por bibliotecario") — FR-004, FR-005, FR-033
- [ ] T060 [US3] Crear `frontend/src/pages/ClientesPage.tsx` con tabla de clientes, botón "Nuevo", acciones editar/dar de baja, muestra `fotoPerfil` asignada automáticamente — US3, FR-008–FR-014
- [ ] T061 [P] [US3] Crear `frontend/src/components/ClienteForm.tsx` con campos: nombre, apellido, DNI, fechaNacimiento; sin campo fotoPerfil (se asigna en backend); acepta caracteres especiales en nombre/apellido — FR-011, FR-012, edge cases
- [ ] T062 [US1] Crear `frontend/src/pages/NuevoPrestamoPage.tsx` con selección de cliente (por DNI o búsqueda), selección de ejemplar disponible, campos fechaInicio y fechaFinPrevista, validación pre-submit — US1-Scenario 1,2, FR-015–FR-019
- [ ] T063 [US1] Crear `frontend/src/pages/DevolucionPage.tsx` con búsqueda de préstamo activo por ID o cliente, campo fechaDevolucion, muestra resultado post-devolución (anticipada + puntos otorgados) — US1-Scenario 3,4, FR-020, FR-021
- [ ] T064 [US4] Crear `frontend/src/pages/InformePrestamosPage.tsx` con tabla paginada de préstamos activos mostrando ejemplar, cliente y fechas; sin préstamos muestra estado vacío — US4-Scenario 3,4, FR-028

**Checkpoint**: Las 6 páginas renderizan sin errores. Los formularios muestran campos correctos y validaciones básicas.

---

## Fase 9: Integración Frontend–Backend

**Propósito**: Conectar cada pantalla a su endpoint correspondiente y validar flujos completos end-to-end.

**Depende de**: Fases 5 y 8

- [ ] T065 [US2] Conectar `EjemplaresPage` y `EjemplarForm` a `ejemplarService`: crear, editar, dar de baja llamando API real; mostrar error 409 cuando ejemplar tiene préstamos activos — quickstart.md escenarios 1,2,20
- [ ] T066 [P] [US3] Conectar `ClientesPage` y `ClienteForm` a `clienteService`: crear con foto asignada visible, editar, dar de baja; mostrar error 409 en DNI duplicado — quickstart.md escenarios 3,4,5
- [ ] T067 [US1] Conectar `NuevoPrestamoPage` a `prestamoService.registrar`: mostrar error cuando ejemplar no disponible o cliente inactivo — quickstart.md escenarios 6,8,12
- [ ] T068 [P] [US1] Conectar `DevolucionPage` a `prestamoService.registrarDevolucion`: mostrar badge "Devolución anticipada" y puntos otorgados; mostrar error 409 en devolución duplicada — quickstart.md escenarios 9,10
- [ ] T069 [US4] Conectar `BusquedaEjemplaresPage` a `ejemplarService.listar` con todos los filtros, paginación funcional y estado "sin resultados" — quickstart.md escenarios 14,15,16,17
- [ ] T070 [P] [US4] Conectar `InformePrestamosPage` a `prestamoService.listarActivos`; verificar que la tabla se actualiza tras una devolución — quickstart.md escenarios 18,19

**Checkpoint**: Flujo completo US1 funciona end-to-end: crear cliente → crear ejemplar → registrar préstamo → registrar devolución → verificar disponibilidad.

---

## Fase 10: Validación End-to-End (según quickstart.md)

**Propósito**: Ejecutar los 20 escenarios de validación del quickstart para certificar que el sistema cumple los requisitos del spec.

**Depende de**: Fases 1–9 completadas

- [ ] T071 Ejecutar y validar escenarios 1–5 del quickstart: alta de ejemplar válido, rechazo de páginas=0, alta de cliente con foto correcta, rechazo DNI duplicado, aceptación de caracteres especiales — quickstart.md §Escenarios 1–5
- [ ] T072 [P] Ejecutar y validar escenarios 6–10: préstamo exitoso, disponibilidad = false tras préstamo, rechazo de préstamo duplicado, devolución anticipada +10 pts, devolución duplicada rechazada — quickstart.md §Escenarios 6–10
- [ ] T073 [P] Ejecutar y validar escenarios 11–15: disponibilidad = true tras devolución, préstamo a cliente inactivo rechazado, ejemplar sin copyright no disponible, búsqueda con filtros AND, búsqueda sin filtros paginada — quickstart.md §Escenarios 11–15
- [ ] T074 [P] Ejecutar y validar escenarios 16–20: búsqueda sin resultados retorna lista vacía, página negativa normaliza a 0, informe lista préstamos activos, informe no muestra préstamos devueltos, baja de ejemplar con préstamo activo rechazada — quickstart.md §Escenarios 16–20
- [ ] T075 Ejecutar validación de performance: poblar 100.000 ejemplares, ejecutar 100 consultas de disponibilidad, verificar que al menos 95 completaron en ≤ 2 s, confirmar presencia de índices V6 en BD — quickstart.md §Validación de performance, SC-006, NFR-003

**Checkpoint**: Los 20 escenarios pasan. La métrica de performance cumple SC-006.

---

## Dependencias entre fases

```
Fase 1 (Setup BE)
  └─► Fase 2 (Dominio)
        └─► Fase 3 (Flyway + Persistencia)
              └─► Fase 4 (Servicios)
                    └─► Fase 5 (API REST)
                          └─► Fase 6 (Tests BE)    ←── paralelo con Fase 7
                          └─► Fase 9 (Integración) ←── requiere Fase 8 también

Fase 7 (Setup FE) ←── puede iniciar desde Fase 5 completa
  └─► Fase 8 (Pantallas FE)
        └─► Fase 9 (Integración FE-BE)
              └─► Fase 10 (Validación E2E)
```

**Oportunidades de paralelización**:
- Fase 6 + Fase 7 pueden ejecutarse en paralelo una vez Fase 5 está completa.
- Dentro de cada fase, las tareas marcadas `[P]` son independientes entre sí.
- Fases 7 y 8 (setup y pantallas del frontend) pueden adelantarse con mocks si la API aún no está lista.

---

## Resumen por historia de usuario

| Historia | FR cubiertos | Fase(s) principal(es) | Tareas |
|----------|--------------|-----------------------|--------|
| US1 – Préstamos y devoluciones | FR-015–FR-021, FR-029–FR-032 | 4, 5, 6, 8, 9 | T029–T031, T034, T039, T041, T047, T062–T063, T067–T068, T072 |
| US2 – Catálogo de libros | FR-001–FR-007 | 2, 3, 4, 5, 6, 8, 9 | T008, T013, T018, T027, T032, T038, T042, T046, T058–T059, T065, T071 |
| US3 – Clientes y foto automática | FR-008–FR-014, FR-034 | 2, 3, 4, 5, 6, 8, 9 | T009, T011, T012, T019, T021, T025–T026, T028, T033, T040, T043, T060–T061, T066, T071 |
| US4 – Disponibilidad e informes | FR-022–FR-029 | 2, 4, 5, 6, 8, 9 | T010, T020, T024, T029, T035, T044–T045, T057, T064, T069–T070, T073–T074 |
| Setup + Infra + Tests transversales | NFR-003, SC-006 | 1, 3, 6, 7, 10 | T001–T004, T017, T045, T075 |

---

## Alcance MVP sugerido

**MVP = Fase 1 + Fase 2 + Fase 3 + Fase 4 (T029–T030) + Fase 5 (T031–T036) + Tests US1/US2**

Esto entrega el flujo central operable: crear ejemplar → crear cliente → registrar préstamo → registrar devolución → verificar disponibilidad.

US3 (foto automática) y US4 (búsqueda avanzada + informes) son incrementos independientes que se suman sobre la base MVP.
