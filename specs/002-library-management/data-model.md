# Data Model: Sistema de Gestión de Biblioteca

**Branch**: `002-add-library-management` | **Date**: 2026-06-07  
**Spec**: [spec.md](spec.md) | **Research**: [research.md](research.md)

---

## 1. Entidades de dominio

### 1.1 Ejemplar (libro físico)

Representa un ejemplar físico único prestable del catálogo. Un mismo ISBN puede tener múltiples ejemplares con `idEjemplar` distintos.

| Atributo | Tipo Java | Tipo BD | Restricciones |
|----------|-----------|---------|--------------|
| `idEjemplar` | `Long` | `BIGSERIAL` PK | NOT NULL, UNIQUE |
| `titulo` | `String` | `VARCHAR(500)` | NOT NULL |
| `autor` | `String` | `VARCHAR(300)` | NOT NULL |
| `cantidadPaginas` | `int` | `INTEGER` | NOT NULL, > 0 |
| `editorial` | `String` | `VARCHAR(300)` | NOT NULL |
| `isbn` | `String` | `VARCHAR(20)` | NOT NULL |
| `perteneceSaga` | `boolean` | `BOOLEAN` | NOT NULL, DEFAULT false |
| `categoriaLibro` | `CategoriaLibro` | `VARCHAR(20)` | NOT NULL, enum cerrado |
| `copyrightVigente` | `boolean` | `BOOLEAN` | NOT NULL |
| `estadoEjemplar` | `EstadoEjemplar` | `VARCHAR(20)` | NOT NULL, DEFAULT 'ACTIVO' |

**Regla de dominio clave**:
```
esPrestable() = estadoEjemplar == ACTIVO
             AND copyrightVigente == true
             AND no existe Prestamo activo para este idEjemplar
```

**Nota**: `copyrightVigente` es un booleano obligatorio verificado manualmente por el bibliotecario al dar de alta o modificar un ejemplar (FR-033). No hay verificación automática contra registro legal externo en v1.

---

### 1.2 Cliente

Representa una persona habilitada para solicitar préstamos.

| Atributo | Tipo Java | Tipo BD | Restricciones |
|----------|-----------|---------|--------------|
| `idCliente` | `Long` | `BIGSERIAL` PK | NOT NULL |
| `nombre` | `String` | `VARCHAR(200)` | NOT NULL |
| `apellido` | `String` | `VARCHAR(200)` | NOT NULL |
| `dni` | `String` | `VARCHAR(20)` | NOT NULL, UNIQUE |
| `fechaNacimiento` | `LocalDate` | `DATE` | NOT NULL |
| `fotoPerfil` | `String` | `VARCHAR(500)` | NOT NULL (ruta relativa de la foto) |
| `puntosAcumulados` | `int` | `INTEGER` | NOT NULL, DEFAULT 0, >= 0 |
| `estadoActivo` | `boolean` | `BOOLEAN` | NOT NULL, DEFAULT true |

**Regla de dominio**:
```
estaHabilitado() = estadoActivo == true
```

**Notas**:
- `fotoPerfil` se asigna automáticamente al registrar el cliente, usando `SelectorFotoPerfilAnimal` (FR-013, FR-014).
- Nombre y apellido aceptan caracteres especiales válidos: apóstrofe, guion, espacios internos.

---

### 1.3 Prestamo

Representa la asignación temporal de un ejemplar a un cliente.

| Atributo | Tipo Java | Tipo BD | Restricciones |
|----------|-----------|---------|--------------|
| `idPrestamo` | `Long` | `BIGSERIAL` PK | NOT NULL |
| `idEjemplar` | `Long` | `BIGINT` FK → ejemplares | NOT NULL |
| `idCliente` | `Long` | `BIGINT` FK → clientes | NOT NULL |
| `fechaInicio` | `LocalDate` | `DATE` | NOT NULL |
| `fechaFinPrevista` | `LocalDate` | `DATE` | NOT NULL |
| `fechaDevolucion` | `LocalDate` | `DATE` | NULL (hasta devolución) |
| `estadoPrestamo` | `EstadoPrestamo` | `VARCHAR(20)` | NOT NULL, DEFAULT 'ACTIVO' |

**Reglas de dominio**:
```
registrarDevolucion(fecha):
  - Lanza excepción si estadoPrestamo == CERRADO   [FR-031]
  - Establece fechaDevolucion = fecha
  - Establece estadoPrestamo = CERRADO
  - Si fecha < fechaFinPrevista → devolución anticipada → suma 10 pts al cliente  [FR-021]

esDevolucionAnticipada(fecha):
  = fecha.isBefore(fechaFinPrevista)
```

---

### 1.4 FotoPerfilAnimal

Banco de fotos de animales precargado para asignación automática de foto de perfil (FR-034).

| Atributo | Tipo Java | Tipo BD | Restricciones |
|----------|-----------|---------|--------------|
| `id` | `Long` | `BIGSERIAL` PK | NOT NULL |
| `inicial` | `char` | `CHAR(1)` | NOT NULL (mayúscula o '*' para fallback) |
| `nombreAnimal` | `String` | `VARCHAR(100)` | NOT NULL |
| `rutaFoto` | `String` | `VARCHAR(500)` | NOT NULL |

**Regla de selección** (en `SelectorFotoPerfilAnimal`):
```
seleccionar(nombre):
  inicial = primerLetraDelNombreDePila(nombre).toUpperCase()
  foto = buscarPorInicial(inicial) ?? buscarFallback('*')
  return foto.rutaFoto
```

---

## 2. Enums de dominio

### CategoriaLibro
```
INFANTILES | JUVENILES | ADULTOS | CONOCIMIENTO
```
FR-005: categoría restringida a estos 4 valores.

### EstadoEjemplar
```
ACTIVO | INACTIVO
```
FR-003: baja lógica → `INACTIVO`. El historial se conserva.

### EstadoPrestamo
```
ACTIVO | CERRADO
```
FR-020: devolución → `CERRADO`. Los préstamos cerrados se conservan para auditoría (FR-032).

---

## 3. Esquema relacional

```
┌─────────────────────┐         ┌──────────────────────┐
│      clientes       │         │      ejemplares       │
├─────────────────────┤         ├──────────────────────┤
│ id_cliente    PK    │         │ id_ejemplar    PK     │
│ nombre              │         │ titulo                │
│ apellido            │         │ autor                 │
│ dni         UNIQUE  │         │ cantidad_paginas      │
│ fecha_nacimiento    │         │ editorial             │
│ foto_perfil         │         │ isbn                  │
│ puntos_acumulados   │         │ pertenece_saga        │
│ estado_activo       │         │ categoria_libro       │
└─────────────────────┘         │ copyright_vigente     │
          │                     │ estado_ejemplar       │
          │                     └──────────────────────┘
          │                               │
          └──────────┐  ┌─────────────────┘
                     ▼  ▼
              ┌──────────────────────┐
              │       prestamos      │
              ├──────────────────────┤
              │ id_prestamo    PK    │
              │ id_cliente     FK    │
              │ id_ejemplar    FK    │
              │ fecha_inicio         │
              │ fecha_fin_prevista   │
              │ fecha_devolucion     │
              │ estado_prestamo      │
              └──────────────────────┘

┌──────────────────────────┐
│   fotos_perfil_animal    │
├──────────────────────────┤
│ id             PK        │
│ inicial   CHAR(1) UNIQUE │
│ nombre_animal            │
│ ruta_foto                │
└──────────────────────────┘
```

---

## 4. Scripts de migración Flyway

### V1__create_clientes.sql
```sql
CREATE TABLE clientes (
    id_cliente        BIGSERIAL    PRIMARY KEY,
    nombre            VARCHAR(200) NOT NULL,
    apellido          VARCHAR(200) NOT NULL,
    dni               VARCHAR(20)  NOT NULL UNIQUE,
    fecha_nacimiento  DATE         NOT NULL,
    foto_perfil       VARCHAR(500) NOT NULL,
    puntos_acumulados INTEGER      NOT NULL DEFAULT 0 CHECK (puntos_acumulados >= 0),
    estado_activo     BOOLEAN      NOT NULL DEFAULT TRUE
);
```

### V2__create_ejemplares.sql
```sql
CREATE TABLE ejemplares (
    id_ejemplar       BIGSERIAL    PRIMARY KEY,
    titulo            VARCHAR(500) NOT NULL,
    autor             VARCHAR(300) NOT NULL,
    cantidad_paginas  INTEGER      NOT NULL CHECK (cantidad_paginas > 0),
    editorial         VARCHAR(300) NOT NULL,
    isbn              VARCHAR(20)  NOT NULL,
    pertenece_saga    BOOLEAN      NOT NULL DEFAULT FALSE,
    categoria_libro   VARCHAR(20)  NOT NULL,
    copyright_vigente BOOLEAN      NOT NULL,
    estado_ejemplar   VARCHAR(20)  NOT NULL DEFAULT 'ACTIVO'
        CHECK (estado_ejemplar IN ('ACTIVO', 'INACTIVO'))
);
```

### V3__create_prestamos.sql
```sql
CREATE TABLE prestamos (
    id_prestamo         BIGSERIAL  PRIMARY KEY,
    id_ejemplar         BIGINT     NOT NULL REFERENCES ejemplares(id_ejemplar),
    id_cliente          BIGINT     NOT NULL REFERENCES clientes(id_cliente),
    fecha_inicio        DATE       NOT NULL,
    fecha_fin_prevista  DATE       NOT NULL,
    fecha_devolucion    DATE,
    estado_prestamo     VARCHAR(20) NOT NULL DEFAULT 'ACTIVO'
        CHECK (estado_prestamo IN ('ACTIVO', 'CERRADO'))
);
```

### V4__create_fotos_perfil_animal.sql
```sql
CREATE TABLE fotos_perfil_animal (
    id            BIGSERIAL  PRIMARY KEY,
    inicial       CHAR(1)    NOT NULL UNIQUE,
    nombre_animal VARCHAR(100) NOT NULL,
    ruta_foto     VARCHAR(500) NOT NULL
);
```

### V5__seed_fotos_perfil_animal.sql
```sql
INSERT INTO fotos_perfil_animal (inicial, nombre_animal, ruta_foto) VALUES
('A', 'Ardilla',    '/assets/animales/ardilla.png'),
('B', 'Búho',       '/assets/animales/buho.png'),
('C', 'Conejo',     '/assets/animales/conejo.png'),
('D', 'Delfín',     '/assets/animales/delfin.png'),
('E', 'Elefante',   '/assets/animales/elefante.png'),
('F', 'Flamenco',   '/assets/animales/flamenco.png'),
('G', 'Gato',       '/assets/animales/gato.png'),
('H', 'Hipopótamo', '/assets/animales/hipopotamo.png'),
('I', 'Iguana',     '/assets/animales/iguana.png'),
('J', 'Jaguar',     '/assets/animales/jaguar.png'),
('K', 'Koala',      '/assets/animales/koala.png'),
('L', 'León',       '/assets/animales/leon.png'),
('M', 'Mono',       '/assets/animales/mono.png'),
('N', 'Nutria',     '/assets/animales/nutria.png'),
('O', 'Oso',        '/assets/animales/oso.png'),
('P', 'Pingüino',   '/assets/animales/pinguino.png'),
('Q', 'Quetzal',    '/assets/animales/quetzal.png'),
('R', 'Rana',       '/assets/animales/rana.png'),
('S', 'Serpiente',  '/assets/animales/serpiente.png'),
('T', 'Tigre',      '/assets/animales/tigre.png'),
('U', 'Urogallo',   '/assets/animales/urogallo.png'),
('V', 'Vaca',       '/assets/animales/vaca.png'),
('W', 'Wombat',     '/assets/animales/wombat.png'),
('X', 'Xenops',     '/assets/animales/xenops.png'),
('Y', 'Yak',        '/assets/animales/yak.png'),
('Z', 'Zorro',      '/assets/animales/zorro.png'),
('*', 'Fallback',   '/assets/animales/neutral.png');
```

### V6__create_indexes.sql
```sql
-- Búsqueda full-text en título
CREATE INDEX idx_ejemplares_titulo_fts
    ON ejemplares USING gin(to_tsvector('spanish', titulo));

-- Búsqueda exacta por autor y categoría
CREATE INDEX idx_ejemplares_autor
    ON ejemplares (autor);

CREATE INDEX idx_ejemplares_categoria
    ON ejemplares (categoria_libro);

-- Disponibilidad: ejemplares activos con copyright vigente
CREATE INDEX idx_ejemplares_disponibilidad
    ON ejemplares (estado_ejemplar, copyright_vigente)
    WHERE estado_ejemplar = 'ACTIVO' AND copyright_vigente = true;

-- Préstamos activos por ejemplar (join rápido para disponibilidad)
CREATE INDEX idx_prestamos_activos_por_ejemplar
    ON prestamos (id_ejemplar)
    WHERE estado_prestamo = 'ACTIVO';

-- Préstamos por cliente (límite de préstamos activos)
CREATE INDEX idx_prestamos_activos_por_cliente
    ON prestamos (id_cliente)
    WHERE estado_prestamo = 'ACTIVO';
```

---

## 5. Validaciones de dominio por entidad

| Regla | FR | Dónde se valida |
|-------|----|----------------|
| `idEjemplar` único | FR-006 | BD (PK) + Service |
| `cantidadPaginas > 0` | edge case | BD (CHECK) + Bean Validation |
| `categoriaLibro` ∈ enum | FR-005 | Java enum + BD (CHECK) |
| `copyrightVigente` es booleano obligatorio | FR-004, FR-033 | Bean Validation (`@NotNull`) |
| `dni` único por cliente | FR-012 | BD (UNIQUE) + Service |
| Ejemplar prestable = activo + copyright + sin préstamo activo | FR-023 | `Ejemplar.esPrestable()` + Service |
| No prestar si cliente inactivo | FR-030 | `PrestamoService` |
| No prestar si ejemplar no disponible | FR-018, FR-019 | `PrestamoService` |
| No devolver si préstamo cerrado | FR-031 | `Prestamo.registrarDevolucion()` |
| Historial de préstamos cerrados conservado | FR-032 | Sin DELETE; solo UPDATE estado |
| Página ≤ 0 normaliza a 1 | FR-027 | `EjemplarController` |
| Máximo 100 por página | FR-026 | `PageRequest.of(page, min(size, 100))` |

---

## 6. Relaciones entre entidades

| Relación | Cardinalidad | Notas |
|----------|-------------|-------|
| Cliente → Prestamo | 1:N | Un cliente puede tener múltiples préstamos (activos hasta el límite configurado) |
| Ejemplar → Prestamo | 1:N | Un ejemplar tiene historial de préstamos; solo 1 activo a la vez |
| FotoPerfilAnimal | Independiente | Lookup por inicial del nombre del cliente |

---

## 7. Trazabilidad spec → modelo

| Requisito spec | Entidad / Elemento del modelo |
|---------------|-------------------------------|
| FR-004 (campos ejemplar) | `Ejemplar` + `V2__create_ejemplares.sql` |
| FR-011 (campos cliente) | `Cliente` + `V1__create_clientes.sql` |
| FR-015 (campos préstamo) | `Prestamo` + `V3__create_prestamos.sql` |
| FR-023 (regla disponibilidad) | `Ejemplar.esPrestable()` |
| FR-026 (paginación 100) | `PageRequest` en `EjemplarController` |
| FR-034 (banco fotos) | `FotoPerfilAnimal` + `V5__seed_fotos_perfil_animal.sql` |
| SC-006 (95% ≤ 2s) | `V6__create_indexes.sql` |
