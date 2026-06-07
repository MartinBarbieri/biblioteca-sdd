# Research: Sistema de Gestión de Biblioteca

**Branch**: `002-add-library-management` | **Date**: 2026-06-07  
**Spec**: [spec.md](spec.md) | **Plan**: [plan.md](plan.md)

---

## 1. Arquitectura backend: capas domain / application / infrastructure / api

**Decision**: Arquitectura en 4 capas con paquetes explícitos por responsabilidad.

**Rationale**:  
La constitución (Principio III) requiere separación de responsabilidades. Las reglas de negocio viven en `domain`, los casos de uso en `application`, la persistencia en `infrastructure`, y la exposición HTTP en `api`. Los controladores solo delegan; nunca validan reglas de negocio.

**Alternatives considered**:  
- MVC clásico sin separación explícita → rechazado por violar Principio II y III (mezcla lógica de negocio con persistencia).  
- Arquitectura hexagonal completa con puertos/adaptadores → descartada por complejidad innecesaria para el alcance actual (Principio VI).

---

## 2. Modelo de dominio: entidades con comportamiento vs. anémicas

**Decision**: Entidades con comportamiento explícito.

| Entidad | Método de dominio clave |
|---------|------------------------|
| `Ejemplar` | `esPrestablePorEstado(): boolean` — retorna `true` si `estadoEjemplar=ACTIVO AND copyrightVigente=true`. No accede a préstamos. |
| `DisponibilidadService` | `esDisponible(idEjemplar): boolean` — combina `ejemplar.esPrestablePorEstado()` + ausencia de `Prestamo` activo para ese `idEjemplar` (FR-023) |
| `Prestamo` | `registrarDevolucion(fechaDevolucion): void` — cierra el préstamo y lanza excepción si ya estaba cerrado |
| `Prestamo` | `esDevolucionAnticipada(fecha): boolean` — compara con `fechaFinPrevista` |
| `Cliente` | `estaHabilitado(): boolean` — retorna `estadoActivo=true` |

**Rationale**: Constitución Principio II (Real OO). Las entidades conocen sus propias reglas; los servicios de aplicación coordinan sin duplicar validaciones.

**Alternatives considered**:  
- Lógica en servicios de aplicación (modelo anémico) → rechazado por Principio II.  
- Validaciones solo en la BD (constraints) → insuficiente; las restricciones de negocio deben ser expresivas en el código.

---

## 3. Enums para valores cerrados

**Decision**: Tres enums en el dominio.

| Enum | Valores |
|------|---------|
| `CategoriaLibro` | `INFANTILES`, `JUVENILES`, `ADULTOS`, `CONOCIMIENTO` |
| `EstadoEjemplar` | `ACTIVO`, `INACTIVO` |
| `EstadoPrestamo` | `ACTIVO`, `CERRADO` |

**Rationale**: Constitución Principio V. Evita strings mágicos, mejora type-safety y hace el dominio auto-documentado.

---

## 4. Estrategia de índices para consultas de disponibilidad

**Decision**: Índices compuestos en la tabla `ejemplares` y un índice parcial para préstamos activos.

### Índices definidos

```sql
-- Búsqueda por campos de catálogo
CREATE INDEX idx_ejemplares_titulo ON ejemplares USING gin(to_tsvector('spanish', titulo));
CREATE INDEX idx_ejemplares_autor ON ejemplares (autor);
CREATE INDEX idx_ejemplares_categoria ON ejemplares (categoria_libro);

-- Disponibilidad compuesta: activo + copyright
CREATE INDEX idx_ejemplares_disponibilidad ON ejemplares (estado_ejemplar, copyright_vigente)
    WHERE estado_ejemplar = 'ACTIVO' AND copyright_vigente = true;

-- Préstamos activos: joins rápidos para determinar disponibilidad
CREATE INDEX idx_prestamos_activos_por_ejemplar ON prestamos (id_ejemplar)
    WHERE estado_prestamo = 'ACTIVO';
```

**Rationale**: Con 100.000 ejemplares, una búsqueda completa sin índice en `titulo` tardaría O(n). Los índices parciales en préstamos activos reducen drásticamente el conjunto escaneado en la consulta de disponibilidad. El índice GIN permite búsqueda parcial de texto (`LIKE '%...%'`) eficientemente.

**Alternatives considered**:  
- Elasticsearch para búsqueda full-text → rechazado por añadir dependencia de infraestructura compleja sin justificación para el volumen actual.  
- Caché en memoria (Redis) → considerado para fases futuras; no necesario en v1 con índices bien diseñados.

**Query de disponibilidad esperada** (ejecutada por JPA):
```sql
SELECT e.* FROM ejemplares e
WHERE e.estado_ejemplar = 'ACTIVO'
  AND e.copyright_vigente = true
  AND NOT EXISTS (
      SELECT 1 FROM prestamos p
      WHERE p.id_ejemplar = e.id_ejemplar
        AND p.estado_prestamo = 'ACTIVO'
  )
  AND (LOWER(e.titulo) LIKE LOWER(:tituloPattern) OR :tituloPattern IS NULL)
  AND (e.autor = :autor OR :autor IS NULL)
  AND (e.categoria_libro = :categoria OR :categoria IS NULL)
ORDER BY e.titulo
LIMIT :pageSize OFFSET :offset;
```

---

## 5. Paginación

**Decision**: Spring Data `Pageable` con límite de 100 items por página. Páginas ≤ 0 se normalizan a 1 en el controlador antes de construir el `PageRequest`.

**Rationale**: FR-026 y FR-027 del spec. Evita traer todo el catálogo en memoria. Spring Data JPA soporta paginación nativa con `Pageable`.

**Alternatives considered**:  
- Cursor-based pagination → más eficiente para grandes datasets pero mayor complejidad de implementación; suficiente con offset para v1.

---

## 6. Banco de fotos de animales

**Decision**: Tabla `fotos_perfil_animal` precargada con datos semilla (Flyway V5). La lógica de selección vive en `SelectorFotoPerfilAnimal` (Strategy / Service).

### Datos semilla mínimos (una foto por letra del abecedario español)

| Inicial | Animal | Referencia foto |
|---------|--------|-----------------|
| A | Ardilla | `/assets/animales/ardilla.png` |
| B | Búho | `/assets/animales/buho.png` |
| C | Conejo | `/assets/animales/conejo.png` |
| D | Delfín | `/assets/animales/delfin.png` |
| E | Elefante | `/assets/animales/elefante.png` |
| F | Flamenco | `/assets/animales/flamenco.png` |
| G | Gato | `/assets/animales/gato.png` |
| H | Hipopótamo | `/assets/animales/hipopotamo.png` |
| I | Iguana | `/assets/animales/iguana.png` |
| J | Jaguar | `/assets/animales/jaguar.png` |
| K | Koala | `/assets/animales/koala.png` |
| L | León | `/assets/animales/leon.png` |
| M | Mono | `/assets/animales/mono.png` |
| N | Nutria | `/assets/animales/nutria.png` |
| O | Oso | `/assets/animales/oso.png` |
| P | Pingüino | `/assets/animales/pinguino.png` |
| Q | Quetzal | `/assets/animales/quetzal.png` |
| R | Rana | `/assets/animales/rana.png` |
| S | Serpiente | `/assets/animales/serpiente.png` |
| T | Tigre | `/assets/animales/tigre.png` |
| U | Urobo (Urogallo) | `/assets/animales/urogallo.png` |
| V | Vaca | `/assets/animales/vaca.png` |
| W | Wombat | `/assets/animales/wombat.png` |
| X | Xenops | `/assets/animales/xenops.png` |
| Y | Yak | `/assets/animales/yak.png` |
| Z | Zorro | `/assets/animales/zorro.png` |
| `*` | _(fallback neutral)_ | `/assets/animales/neutral.png` |

**Rationale**: FR-034. Mantener fotos en BD permite que sean administrables sin redeployar. El fallback neutro (`*`) cubre cualquier inicial sin coincidencia (FR-013, AMB-002).

**Alternatives considered**:  
- Hardcodear un `Map<Char, String>` en código → no administrable en producción.  
- Subir fotos a S3/object storage → complejidad innecesaria en v1.

---

## 7. Generación de documentación OpenAPI

**Decision**: `springdoc-openapi` 2.x con anotaciones `@Operation`, `@ApiResponse`, y esquemas definidos en DTOs con Bean Validation.

**Rationale**: Genera la especificación OpenAPI automáticamente al arrancar el backend. El contrato en `contracts/openapi.yaml` es la referencia de diseño; en producción se expone en `/v3/api-docs`.

---

## 8. Testing: cobertura por capa

| Capa | Framework | Qué se testea |
|------|-----------|---------------|
| Domain | JUnit 5 | Reglas de negocio: `esPrestablePorEstado()`, `registrarDevolucion()`, puntos anticipados |
| Application / DisponibilidadService | JUnit 5 + Mockito | `esDisponible()`: combina estado interno + ausencia de préstamo activo |
| Application | JUnit 5 + Mockito | Coordinación de casos de uso, flujos de error |
| Infrastructure | Spring Boot Test + Testcontainers (PostgreSQL) | Repositorios JPA, queries de disponibilidad, índices |
| API | `@WebMvcTest` + MockMvc | Controladores: request/response, validación HTTP codes |

**Rationale**: Constitución Principio VII. Cada capa se prueba con el nivel de aislamiento adecuado.

---

## 9. Frontend: estructura de páginas y comunicación con API

**Decision**: React 18 + Vite 5 + TypeScript. Llamadas HTTP con `fetch` nativo (o Axios). Sin state management global en v1 (solo `useState` / `useEffect`).

**Páginas**:

| Página | Descripción |
|--------|-------------|
| `BusquedaEjemplaresPage` | Punto de entrada principal; búsqueda con filtros opcionales + paginación |
| `EjemplaresPage` | CRUD de ejemplares; formulario de alta/modificación/baja |
| `ClientesPage` | CRUD de clientes; foto asignada automáticamente |
| `NuevoPrestamoPage` | Formulario para registrar préstamo (seleccionar cliente + ejemplar) |
| `DevolucionPage` | Formulario para registrar devolución; muestra si fue anticipada |
| `InformePrestamosPage` | Tabla de préstamos activos con cliente asociado |

**Rationale**: Constitución Principio IX (UX First). Pantallas por dominio, sin mezcla de responsabilidades visuales.

---

## 10. Decisiones diferidas (fuera de v1)

| Decisión | Razón para diferir |
|----------|-------------------|
| Autenticación del cliente | Definido como fuera de alcance en spec (Clarification Q1) |
| Límite global de préstamos por defecto | AMB-001 en spec: queda para iteraciones futuras |
| Caché Redis para disponibilidad | No necesario en v1 con índices bien diseñados |
| Frontend testing (Vitest / Playwright) | No especificado en v1; se añade en fase de validación futura |
| Cursor-based pagination | Suficiente con offset pagination en v1 |
