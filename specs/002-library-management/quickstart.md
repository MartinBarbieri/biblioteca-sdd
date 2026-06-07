# Quickstart: Guía de Validación — Sistema de Gestión de Biblioteca

**Branch**: `002-add-library-management` | **Date**: 2026-06-07  
**Spec**: [spec.md](spec.md) | **Contrato**: [contracts/openapi.yaml](contracts/openapi.yaml)  
**Modelo**: [data-model.md](data-model.md)

Este documento describe cómo validar end-to-end que el sistema cumple los requisitos del spec. No contiene código de implementación; usa `curl` o cualquier cliente HTTP para ejecutar los escenarios.

---

## Prerrequisitos

| Componente | Versión mínima |
|-----------|---------------|
| Java | 21 |
| Maven | 3.9+ |
| Node.js | 20+ |
| PostgreSQL | 15+ |
| Docker (opcional) | 24+ |

**Variables de entorno backend**:
```
SPRING_DATASOURCE_URL=jdbc:postgresql://localhost:5432/biblioteca
SPRING_DATASOURCE_USERNAME=biblioteca_user
SPRING_DATASOURCE_PASSWORD=<password>
```

---

## Levantar el entorno

### Base de datos con Docker (opcional)
```bash
docker run -d \
  --name biblioteca-pg \
  -e POSTGRES_DB=biblioteca \
  -e POSTGRES_USER=biblioteca_user \
  -e POSTGRES_PASSWORD=secret \
  -p 5432:5432 \
  postgres:15
```

### Backend
```bash
cd backend
mvn spring-boot:run
# Flyway aplica migraciones V1–V6 automáticamente al arrancar
# API disponible en: http://localhost:8080/api/v1
# OpenAPI UI:        http://localhost:8080/swagger-ui.html
```

### Frontend
```bash
cd frontend
npm install
npm run dev
# App disponible en: http://localhost:5173
```

---

## Escenarios de validación

Los escenarios están ordenados por dependencia. La URL base es `http://localhost:8080/api/v1`.

---

### Escenario 1: Alta de ejemplar (US2 — FR-001, FR-004, FR-005)

**Propósito**: Verificar que se puede registrar un ejemplar con todos los campos obligatorios.

```bash
curl -s -X POST http://localhost:8080/api/v1/ejemplares \
  -H "Content-Type: application/json" \
  -d '{
    "titulo": "El Señor de los Anillos",
    "autor": "J.R.R. Tolkien",
    "cantidadPaginas": 1200,
    "editorial": "Minotauro",
    "isbn": "978-0-618-64015-7",
    "perteneceSaga": true,
    "categoriaLibro": "ADULTOS",
    "copyrightVigente": true
  }'
```

**Resultado esperado**: HTTP 201 con `idEjemplar` generado y `estadoEjemplar: "ACTIVO"`.

---

### Escenario 2: Alta de ejemplar — páginas ≤ 0 (edge case — FR-004)

**Propósito**: Validar que el sistema rechaza cantidadPaginas inválida.

```bash
curl -s -X POST http://localhost:8080/api/v1/ejemplares \
  -H "Content-Type: application/json" \
  -d '{"titulo": "Test", "autor": "Test", "cantidadPaginas": 0,
       "editorial": "Ed", "isbn": "000", "categoriaLibro": "ADULTOS",
       "copyrightVigente": true}'
```

**Resultado esperado**: HTTP 400 con descripción de error de validación.

---

### Escenario 3: Alta de cliente con foto automática (US3 — FR-008, FR-013, FR-014)

**Propósito**: Verificar asignación automática de foto por inicial del nombre.

```bash
curl -s -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{
    "nombre": "Martina",
    "apellido": "García",
    "dni": "30100200",
    "fechaNacimiento": "1995-04-15"
  }'
```

**Resultado esperado**: HTTP 201. `fotoPerfil` contiene ruta de foto de animal que empieza con `M` (ej: `/assets/animales/mono.png`).

---

### Escenario 4: Alta de cliente — DNI duplicado (FR-012)

```bash
# Segundo intento con mismo DNI
curl -s -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{"nombre": "Luis", "apellido": "López", "dni": "30100200",
       "fechaNacimiento": "1990-01-01"}'
```

**Resultado esperado**: HTTP 409 con `codigo: "DNI_DUPLICADO"`.

---

### Escenario 5: Alta de cliente con nombre con caracteres especiales (edge case)

```bash
curl -s -X POST http://localhost:8080/api/v1/clientes \
  -H "Content-Type: application/json" \
  -d '{"nombre": "D'\''Artagnan", "apellido": "García-Pérez",
       "dni": "99887766", "fechaNacimiento": "2000-06-10"}'
```

**Resultado esperado**: HTTP 201 — el sistema acepta el nombre con apóstrofe y el apellido con guion.

---

### Escenario 6: Registrar préstamo exitoso (US1 — FR-015, FR-018, FR-019)

**Prerequisito**: Ejemplar del escenario 1 (id=1) y cliente del escenario 3 (id=1).

```bash
curl -s -X POST http://localhost:8080/api/v1/prestamos \
  -H "Content-Type: application/json" \
  -d '{
    "idEjemplar": 1,
    "idCliente": 1,
    "fechaInicio": "2026-06-07",
    "fechaFinPrevista": "2026-06-21"
  }'
```

**Resultado esperado**: HTTP 201. `estadoPrestamo: "ACTIVO"`.

---

### Escenario 7: Verificar disponibilidad tras préstamo (US4 — FR-022, FR-023, FR-024)

```bash
curl -s http://localhost:8080/api/v1/ejemplares/1/disponibilidad
```

**Resultado esperado**: `disponible: false`, `motivo: "PRESTADO"`.

---

### Escenario 8: Intentar prestar ejemplar ya prestado (US1-Scenario 2 — FR-019)

```bash
curl -s -X POST http://localhost:8080/api/v1/prestamos \
  -H "Content-Type: application/json" \
  -d '{"idEjemplar": 1, "idCliente": 1,
       "fechaInicio": "2026-06-07", "fechaFinPrevista": "2026-06-21"}'
```

**Resultado esperado**: HTTP 409, `codigo: "EJEMPLAR_NO_DISPONIBLE"`.

---

### Escenario 9: Devolución anticipada suma 10 puntos (US1-Scenario 3 — FR-021)

**Prerequisito**: Préstamo activo del escenario 6 (id=1), `fechaFinPrevista: 2026-06-21`.

```bash
curl -s -X POST http://localhost:8080/api/v1/prestamos/1/devolucion \
  -H "Content-Type: application/json" \
  -d '{"fechaDevolucion": "2026-06-10"}'
```

**Resultado esperado**: `devolucionAnticipada: true`, `puntosOtorgados: 10`.

---

### Escenario 10: Devolución duplicada rechazada (edge case — FR-031)

```bash
# Intentar devolver el mismo préstamo nuevamente
curl -s -X POST http://localhost:8080/api/v1/prestamos/1/devolucion \
  -H "Content-Type: application/json" \
  -d '{"fechaDevolucion": "2026-06-10"}'
```

**Resultado esperado**: HTTP 409, `codigo: "PRESTAMO_YA_CERRADO"`.

---

### Escenario 11: Ejemplar disponible tras devolución (US1-Scenario 3 continuación)

```bash
curl -s http://localhost:8080/api/v1/ejemplares/1/disponibilidad
```

**Resultado esperado**: `disponible: true`.

---

### Escenario 12: Intentar prestar a cliente inactivo (edge case — FR-030)

**Prerequisito**: Cliente inactivo (dar de baja al cliente id=1 primero).

```bash
curl -s -X DELETE http://localhost:8080/api/v1/clientes/1
# Luego intentar nuevo préstamo:
curl -s -X POST http://localhost:8080/api/v1/prestamos \
  -H "Content-Type: application/json" \
  -d '{"idEjemplar": 1, "idCliente": 1,
       "fechaInicio": "2026-06-07", "fechaFinPrevista": "2026-06-21"}'
```

**Resultado esperado**: HTTP 409, `codigo: "CLIENTE_INACTIVO"`.

---

### Escenario 13: Ejemplar con copyright no vigente no es disponible (US2-Scenario 4 — FR-029)

```bash
# Crear ejemplar sin copyright
curl -s -X POST http://localhost:8080/api/v1/ejemplares \
  -H "Content-Type: application/json" \
  -d '{"titulo": "Libro Antiguo", "autor": "Anónimo",
       "cantidadPaginas": 300, "editorial": "Arcaica", "isbn": "000-0-000",
       "categoriaLibro": "CONOCIMIENTO", "copyrightVigente": false}'

# Consultar disponibilidad del nuevo ejemplar (ej: id=2)
curl -s http://localhost:8080/api/v1/ejemplares/2/disponibilidad
```

**Resultado esperado**: `disponible: false`, `motivo: "COPYRIGHT_NO_VIGENTE"`.

---

### Escenario 14: Búsqueda con filtros — AND lógico (US4-Scenario 2 — FR-025)

```bash
curl -s "http://localhost:8080/api/v1/ejemplares?categoriaLibro=ADULTOS&autor=Tolkien&soloDisponibles=true"
```

**Resultado esperado**: HTTP 200 con lista de ejemplares que satisfacen TODOS los filtros.

---

### Escenario 15: Búsqueda sin filtros — paginación (US4-Scenario 6 — FR-026)

```bash
curl -s "http://localhost:8080/api/v1/ejemplares?page=0&size=100"
```

**Resultado esperado**: HTTP 200 con `tamanoPagina ≤ 100` y `totalElementos` correcto.

---

### Escenario 16: Búsqueda sin resultados (US4-Scenario 5 — edge case)

```bash
curl -s "http://localhost:8080/api/v1/ejemplares?titulo=XYZ_SIN_COINCIDENCIA_9999"
```

**Resultado esperado**: HTTP 200, `contenido: []`, `totalElementos: 0`.

---

### Escenario 17: Página ≤ 0 normalizada a 1 (FR-027)

```bash
curl -s "http://localhost:8080/api/v1/ejemplares?page=-5"
```

**Resultado esperado**: HTTP 200 devolviendo la primera página (igual que `page=0`).

---

### Escenario 18: Informe de préstamos activos (US4-Scenario 3 — FR-028)

```bash
curl -s "http://localhost:8080/api/v1/prestamos"
```

**Resultado esperado**: Lista de préstamos con `estadoPrestamo: "ACTIVO"` y datos del cliente y ejemplar asociados.

---

### Escenario 19: Informe no muestra préstamos devueltos (US4-Scenario 4)

Después del escenario 9 (devolución ejecutada), repetir:
```bash
curl -s "http://localhost:8080/api/v1/prestamos"
```

**Resultado esperado**: El préstamo 1 no aparece en la lista (ya fue cerrado).

---

### Escenario 20: Baja de ejemplar con préstamo activo — rechazada (FR-007)

**Prerequisito**: Crear un préstamo activo para un ejemplar.

```bash
curl -s -X DELETE http://localhost:8080/api/v1/ejemplares/1
```

**Resultado esperado**: HTTP 409 mientras el ejemplar tenga préstamo activo.

---

## Validación de performance (SC-001, SC-006)

Para validar el objetivo de performance (95% de consultas ≤ 2s con 100k ejemplares):

1. Poblar la base de datos con al menos 100.000 ejemplares (script de seed disponible en fase de implementación).
2. Ejecutar consulta de disponibilidad 100 veces y medir tiempos:
```bash
for i in $(seq 1 100); do
  time curl -s "http://localhost:8080/api/v1/ejemplares?soloDisponibles=true&page=0&size=20" > /dev/null
done
```
3. Verificar que al menos 95 de las 100 ejecuciones completaron en ≤ 2000 ms.
4. Confirmar que los índices definidos en [data-model.md](data-model.md) sección 4 (V6) están presentes en la BD:
```sql
SELECT indexname, tablename FROM pg_indexes
WHERE tablename IN ('ejemplares', 'prestamos')
ORDER BY tablename, indexname;
```

---

## Referencias

| Artefacto | Descripción |
|-----------|-------------|
| [spec.md](spec.md) | Fuente de verdad de requisitos |
| [data-model.md](data-model.md) | Entidades, esquema BD e índices |
| [contracts/openapi.yaml](contracts/openapi.yaml) | Contrato REST completo |
| [research.md](research.md) | Decisiones técnicas y justificaciones |
| [plan.md](plan.md) | Estructura del proyecto y contexto técnico |
