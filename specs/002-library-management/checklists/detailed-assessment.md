# Evaluación Detallada: Checklist vs Especificación

**Fecha**: 2026-06-07  
**Evaluador**: Análisis comparativo detallado  
**Metodología**: Ítem por ítem, señalando estado, ubicación, y brechas

---

## REQUIREMENT COMPLETENESS (CHK001-CHK012)

### CHK001 - ¿Todas las historias de usuario (US1-US4) cubren actores identificados (bibliotecario, cliente)?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- US1: Bibliotecario (registra préstamos/devoluciones)
- US2: Bibliotecario (administra catálogo)
- US3: Bibliotecario (gestiona clientes + foto automática)
- US4: Cliente Y Bibliotecario (consulta disponibilidad, informe)

**Hallazgos**:
- Todos los actores identificados están cubiertos
- El cliente aparece principalmente en US4 para consultas
- Separación clara: bibliotecario = operaciones, cliente = consultas

**Falta**: Nada específico. Sin embargo, considerar si hay operaciones de cliente que deberían estar explicitadas (ej: "cliente ve sus préstamos activos").

---

### CHK002 - ¿User Story 1 (Préstamos) define al menos 4 flujos claros (crear, validar, rechazar, devolver)?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- Scenario 1: Crear préstamo + marcar no disponible
- Scenario 2: Rechazar por no disponible
- Scenario 3: Devolver anticipadamente + suma 10 puntos
- Scenario 4: Devolver no anticipadamente + no suma puntos

**Hallazgos**:
- Los 4 flujos principales están bien definidos
- Cada uno tiene precondición, acción y resultado claro

**Falta**: Nada.

---

### CHK003 - ¿User Story 2 (Catálogo) define CRUD completo (alta, modificación, baja)?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- Scenario 1: Create (registrar nuevo libro con todos los campos)
- Scenario 2: Update (modificar datos existentes + trazabilidad)
- Scenario 3: Delete (dar de baja, marcar inactivo)
- Scenario 4: Validación adicional (copyright vigente bloquea préstamo)

**Hallazgos**:
- CRUD está bien especificado
- Incluye validación de copyright como parte del flujo

**Falta**: Nada.

---

### CHK004 - ¿User Story 3 (Clientes) incluye la asignación automática de foto + gestión de datos?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- Scenario 1: Create + asignación automática de foto animal
- Scenario 2: Update datos sin perder historial de puntos
- Scenario 3: Delete (marcar inactivo)

**Hallazgos**:
- La asignación automática de foto está explícita
- Gestión de datos (CREATE, UPDATE, DELETE) está cubierta
- Se preserva trazabilidad (puntos, historial)

**Falta**: Nada.

---

### CHK005 - ¿User Story 4 (Disponibilidad) cubre búsqueda con múltiples criterios E informe de préstamos?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- Scenario 1: Consultar disponibilidad CON FILTRO (título, autor, categoría)
- Scenario 2: Múltiples filtros con lógica AND
- Scenario 3: Generar informe de préstamos activos + cliente asociado
- Scenario 4: Informe se actualiza después de devolución

**Hallazgs**:
- Búsqueda multifiltro bien especificada
- Informe de préstamos incluido

**Falta**: Nada.

---

### CHK006 - ¿Los requisitos funcionales (FR-001 a FR-024) cubren todos los flujos principales identificados en US?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- FR-001-FR-007: Gestión de libros/ejemplares (cubre US2)
- FR-008-FR-014: Gestión de clientes (cubre US3)
- FR-015-FR-021: Ciclo de préstamos/devoluciones (cubre US1)
- FR-022-FR-024: Búsqueda e informes (cubre US4)

**Hallazgos**:
- Existe mapeo claro entre US y FRs
- Cobertura completa de flujos principales

**Falta**: Nada. (Nota: FR-021 aparece duplicado en la lista, lo que es un error menor de numeración).

---

### CHK007 - ¿FR-001 a FR-007 cubren gestión completa de libros/ejemplares?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- FR-001: Registrar nuevo ejemplar
- FR-002: Modificar datos
- FR-003: Dar de baja
- FR-004: Almacenar campos obligatorios (idEjemplar, título, autor, páginas, editorial, ISBN, saga, categoría, copyright)
- FR-005: Restringir categoría a enum (infantiles, juveniles, adultos, conocimiento)
- FR-006: Validar que cada idEjemplar sea único
- FR-007: No permitir baja si hay préstamos activos

**Hallazgos**:
- CRUD + validaciones están completos
- El modelo de "ejemplar físico único" está claro
- Enum de categoría define dominio cerrado

**Falta**: Nada.

---

### CHK008 - ¿FR-008 a FR-014 cubren gestión completa de clientes incluyendo foto automática?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- FR-008: Registrar nuevo cliente
- FR-009: Modificar datos
- FR-010: Dar de baja
- FR-011: Almacenar campos (nombre, apellido, DNI, fechaNacimiento, fotoPerfil, puntosAcumulados)
- FR-012: Validar DNI único
- FR-013: Asignar foto automáticamente
- FR-014: Foto animal con misma inicial del nombre

**Hallazgos**:
- CRUD de clientes completo
- Foto automática está especificada con algoritmo claro
- Validación de DNI único

**Falta**: Nada.

---

### CHK009 - ¿FR-015 a FR-021 cubren ciclo completo de préstamos/devoluciones?

**Estado**: ⚠️ **PARCIALMENTE CUMPLIDO (con observación)**

**Ubicación en spec.md**:
- FR-015: Registrar préstamo con fechas
- FR-016: Múltiples préstamos paralelos + límite configurable
- FR-017: Rechazar si alcanzó límite
- FR-018: Verificar disponibilidad antes de confirmar
- FR-019: Rechazar si no disponible
- FR-020: Registrar devolución y cerrar préstamo
- FR-021: Sumar 10 puntos si es anticipada
- FR-021 (DUPLICADO): Permitir consultar disponibilidad

**Hallazgos**:
- El ciclo completo está cubierto
- **PROBLEMA**: FR-021 aparece DUPLICADO. La primera dice "sumar 10 puntos", la segunda dice "permitir consultar disponibilidad"
- Esta duplicidad crea confusión de numeración (¿cuál es realmente FR-021?)

**Falta**: 
- **Renumerar FRs**: El segundo FR-021 debería ser FR-022 (y cascada las demás)
- Resolver la duplicidad en la numeración

---

### CHK010 - ¿FR-022 a FR-024 cubren búsqueda y disponibilidad?

**Estado**: ⚠️ **PARCIALMENTE CUMPLIDO (depende de resolución de CHK009)**

**Ubicación en spec.md**:
- FR-022: Búsqueda de ejemplares con criterios múltiples (título parcial, autor, categoría, disponibilidad) + AND lógico
- FR-023: Generar informe de préstamos activos
- FR-024: Bloquear disponibilidad si copyright no vigente

**Hallazgos**:
- Búsqueda bien especificada con los 4 criterios y lógica AND
- Informe de préstamos claro
- Bloqueo por copyright vigente

**Falta**: Esperar resolución de duplicidad en FR-021.

---

### CHK011 - ¿Los requisitos no funcionales (NFR-001 a NFR-007) cubren todas las dimensiones críticas?

**State**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- NFR-001 (Usabilidad): Interfaz simple para encontrar libros
- NFR-002 (Claridad): Disponibilidad mostrada clara y sin ambigüedad
- NFR-003 (Performance): 2 segundos para disponibilidad
- NFR-004 (Escalabilidad): Soportar 100.000 libros + 10.000 clientes
- NFR-005 (Cumplimiento legal): Copyright vigente para ser prestables
- NFR-006 (Arquitectura): Reglas de negocio separadas de interfaz
- NFR-007 (Especificación): Validaciones explícitas como criterios de aceptación

**Hallazgos**:
- Todas las dimensiones críticas están cubiertas
- Alineadas con Principios de Constitución (esp. II, III, IX)

**Falta**: Nada.

---

### CHK012 - ¿Hay requisitos explícitos para cada entidad del dominio (Libro/Ejemplar, Cliente, Préstamo, Asignación de Foto)?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- **Libro (Ejemplar Físico)**: Key Entities + FR-001-FR-007 + US2
- **Cliente**: Key Entities + FR-008-FR-014 + US3
- **Préstamo**: Key Entities + FR-015-FR-021 + US1
- **AsignacionFotoPerfil**: Key Entities + FR-013-FR-014 + US3
- **InformePrestamosActivos**: Key Entities + FR-023 + US4

**Hallazgos**:
- Todas las entidades tienen definición en Key Entities
- Todas tienen FRs asociados
- Todas tienen scenarios de aceptación

**Falta**: Nada. (Aunque ver CHK031-CHK032 para responsabilidades entre entidades).

---

## REQUIREMENT CLARITY (CHK013-CHK020)

### CHK013 - ¿El modelo "Libro = Ejemplar Físico Único" está completamente especificado?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- Key Entities: "Cada copia física es un registro independiente con ID único de ejemplar"
- FR-004: "Múltiples ejemplares del mismo ISBN tendrán ID únicos distintos"
- FR-006: "validar que cada idEjemplar sea único dentro del catalogo (no es ISBN lo que debe ser único, sino cada ejemplar físico)"
- Clarifications Q3: "Cada libro es un ejemplar físico único con ID único; múltiples copias = múltiples registros"

**Hallazgos**:
- El modelo está muy claro
- La distinción entre ISBN (título) e idEjemplar (copia física) es explícita
- Clarificaciones refuerzan la decisión arquitectónica

**Falta**: Nada.

---

### CHK014 - ¿"Foto de perfil automática" especifica exactamente el algoritmo?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- FR-013: "asignar automaticamente una foto de perfil de animal"
- FR-014: "una foto cuyo animal inicie con la misma letra del nombre de pila del cliente"
- Clarifications Q2: "Se asigna foto de respaldo neutral/genérica y registrar en logs para revisión operativa"
- Edge Cases: "Nombre de cliente con inicial sin foto de animal disponible: **RESUELTO** → Se asigna foto neutral"

**Hallazgos**:
- Algoritmo está especificado: inicial → nombre de pila → animal que inicia con esa letra
- Fallback está especificado: foto neutral + log si no hay match
- El caso borde está resuelto

**Falta**: ¿De dónde vienen las fotos de animales? ¿Hay un banco de datos predefinido? ¿Por género? Esto podría especificarse como requisito de datos.

---

### CHK015 - ¿"Límite de préstamos configurables" está claramente definido?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- FR-016: "límite configurable por bibliotecario (puede variar por cliente individual o por política general del día)"
- Clarifications Q5: "Límite configurable por bibliotecario (varía por cliente o por día)"
- Assumptions: "Límite de préstamos: configurable por bibliotecario, puede variar por cliente o aplicarse como política general del día"

**Hallazgos**:
- La flexibilidad del límite está clara
- Dos opciones: por cliente individual O política global del día
- Bibliotecario es el actor que configura

**Falta**: ¿Hay un límite por defecto? ¿Cuál es el rango permitido (1-N)?

---

### CHK016 - ¿"Búsqueda disponible" especifica los 4 criterios y lógica AND?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- FR-022: "búsqueda de ejemplares disponibles por: título (búsqueda parcial), autor, categoría, estado de disponibilidad. Los filtros se aplican con lógica AND (todos los criterios seleccionados deben coincidir)"
- Clarifications Q4: "Búsqueda por: título, autor, categoría, disponibilidad (AND lógico entre filtros)"
- US4-Scenario 2: Valida el AND lógico con ejemplo

**Hallazgos**:
- Los 4 criterios están explícitos
- Lógica AND está clara
- Se permite búsqueda parcial en título

**Falta**: ¿Qué pasa si el usuario no selecciona ningún filtro? ¿Se devuelven todos los disponibles?

---

### CHK017 - ¿La consulta de disponibilidad "2 segundos" es SLA o indicativo? ¿Condiciones?

**Estado**: ⚠️ **PARCIALMENTE CUMPLIDO**

**Ubicación en spec.md**:
- NFR-003: "la consulta de disponibilidad MUST completarse en <= 2 segundos en **condiciones operativas normales**"
- SC-001: "El 95% de consultas de disponibilidad se completan en 2 segundos o menos durante **operacion habitual**"
- SC-006: "En pruebas de carga objetivo **(100000 libros y 10000 clientes)**, la busqueda de disponibilidad mantiene cumplimiento del umbral de 2 segundos en al menos 95% de consultas"

**Hallazgos**:
- NFR-003 dice "2 segundos en condiciones operativas normales" (vago)
- SC-001 dice "95%" (métrica clara pero diferente a NFR-003)
- SC-006 especifica la carga: 100k libros, 10k clientes, 95% de queries en 2 seg
- Hay INCONSISTENCIA: ¿NFR-003 es 100% o 95%?

**Falta**: 
- **Aclaración crítica**: ¿El NFR-003 es "100% en condiciones normales" o "95%"?
- Definir "condiciones operativas normales" con exactitud (carga esperada, usuarios concurrentes, etc.)
- Aclarar si SC-006 reemplaza a NFR-003 o es un escenario adicional

---

### CHK018 - ¿El "punto de 10 puntos por devolución anticipada" es exacto o un rango?

**State**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- FR-021: "MUST sumar 10 puntos"
- US1-Scenario 3: "suma 10 puntos al cliente"
- US1-Scenario 4: (implícito: no suma si no es anticipada)
- SC-004: "El 100% de devoluciones anticipadas registradas incrementan exactamente 10 puntos del cliente"

**Hallazgos**:
- Es exacto: 10 puntos (no rango)
- SC-004 lo enfatiza: "exactamente 10"
- Está bien especificado

**Falta**: Nada.

---

### CHK019 - ¿"Devolución anticipada" está cuantificada exactamente?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- US1-Scenario 3: "fecha fin prevista posterior a hoy" → devolución hoy = anticipada
- US1-Scenario 4: "fecha fin prevista es hoy o anterior" → devuelvo → NO suma puntos
- FR-021: "cuando la devolucion se registre antes de la fecha final prevista"

**Hallazgos**:
- La definición es clara: ANTES de fechaFinPrevista = anticipada
- Incluye el mismo día (si hoy < fechaFinPrevista, es anticipada)
- Scenarios cubren los bordes (hoy vs fecha fin)

**Falta**: Nada.

---

### CHK020 - ¿"Copyright vigente" está definido como booleano o requiere más precisión?

**Estado**: ⚠️ **PARCIALMENTE CUMPLIDO (falta precisión)**

**Ubicación en spec.md**:
- FR-004: "estado de copyright vigente"
- FR-023: "impedir considerar disponible para prestamo cualquier libro con copyright no vigente"
- NFR-005: "Todos los libros registrados MUST mantener estado de copyright vigente para ser prestables"
- Assumptions: "El país de operación define legalmente que solo libros con copyright vigente pueden prestarse"

**Hallazgos**:
- Se menciona como un "estado" (vigente/no vigente) pero NO está claro si:
  - ¿Es booleano (true/false)?
  - ¿Es una fecha que vence (timestamp)?
  - ¿Es una referencia a un registro legal externo?
- Quién es responsable de actualizar el estado cuando cambia legalmente?

**Falta**: 
- **Aclaración crítica**: Definir el modelo del copyright:
  - ¿Booleano o fecha?
  - ¿Quién verifica si es vigente?
  - ¿Cada cuánto se revisa?
  - ¿Hay un servicio externo que consulta el estado legal?
- Agregar FR específico: "El sistema MUST validar el estado de copyright contra [fuente de verdad legal]"

---

## REQUIREMENT CONSISTENCY (CHK021-CHK026)

### CHK021 - ¿No hay contradicción entre FR-016 (múltiples préstamos) y FR-017 (rechazar si alcanzó límite)?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- FR-016: "permitir que un cliente tenga múltiples préstamos activos en paralelo, con un límite configurable"
- FR-017: "rechazar préstamos cuando el cliente ha alcanzado su límite máximo"

**Hallazgos**:
- La lógica es consistente: PERMITE múltiples HASTA el límite, LUEGO rechaza
- No hay contradicción

**Falta**: Nada.

---

### CHK022 - ¿FR-007 (no dar de baja libro con préstamos) es consistente con disponibilidad en FR-018-FR-019?

**Estado**: ⚠️ **INCONSISTENCIA POTENCIAL**

**Ubicación en spec.md**:
- FR-007: "impedir que un ejemplar con prestamos activos sea dado de baja operativamente"
- FR-018-FR-019: Validar disponibilidad antes de préstamo, rechazar si no disponible
- US1-Scenario 2: Rechaza si ejemplar ya está prestado

**Hallazgos**:
- FR-007 dice: Si hay préstamos activos → no se puede dar de baja
- FR-018-FR-019 implican: Si no está disponible → rechazar nuevo préstamo
- **PREGUNTA**: ¿Un libro CON préstamo activo es "disponible" o "no disponible"?
  - Si tiene préstamo activo → debe ser "no disponible" para nuevos préstamos
  - Si es "no disponible" → debe aparecer así en búsquedas
  - ¿O desaparece de búsquedas por completo?

**Falta**: 
- Aclaración: ¿Un libro con préstamo activo aparece en búsquedas como "no disponible" o no aparece?
- Especificar si el estado "inactivo" (por baja administrativa) es diferente del estado "prestado" (disponible pero en uso)

---

### CHK023 - ¿FR-013 y FR-014 son consistentes con Clarification Q2 (foto neutral)?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- FR-013: "asignar automaticamente"
- FR-014: "animal inicie con la misma letra"
- Clarifications Q2: "Se asigna foto neutral/genérica y registra en logs" (si no hay match)
- Edge Cases: Resuelto → foto neutral

**Hallazgos**:
- FR-013 y FR-014 especifican el caso normal
- Clarifications Q2 + Edge Cases especifican el fallback
- Todo es consistente

**Falta**: Nada. Considerar que el fallback debería documentarse en una FR adicional o como parte de FR-013-FR-014.

---

### CHK024 - ¿NFR-001 (UX simple) y NFR-004 (escalabilidad 100k/10k) no crean trade-offs sin resolución?

**Estado**: ⚠️ **TRADE-OFF NO RESUELTO**

**Ubicación en spec.md**:
- NFR-001: "flujo simple y comprensible para usuarios no tecnicos" + "encontrar libros disponibles debe ser simple"
- NFR-004: "soportar al menos 100000 libros y 10000 clientes"

**Hallazgos**:
- Potencial trade-off: Interfaz simple puede ser lenta si la base es grande
- FR-022 especifica búsqueda con 4 criterios pero NO especifica cómo optimizarla
- NFR-003 dice "2 segundos" pero es vago sobre cómo lograrlo

**Falta**: 
- Especificar mecanismos de optimización en FRs o NFRs:
  - ¿Paginación?
  - ¿Índices en BD (título, autor, categoría)?
  - ¿Caché?
  - ¿Búsqueda full-text?
  - ¿Lazy loading?
- Ejemplo: "FR-022b: El sistema MUST usar índices en título, autor y categoría para mantener < 2 seg en 100k libros"

---

### CHK025 - ¿Los criterios de éxito (SC-001-SC-006) son alcanzables con los FR definidos?

**Estado**: ⚠️ **PARCIALMENTE ALCANZABLES (depende de optimizaciones no especificadas)**

**Ubicación en spec.md**:
- SC-001: 95% queries en 2 seg (operación habitual) ← depende de FR-022 optimizada
- SC-002: 90% altas de libro en <2 min ← depende de FR-001 + UI
- SC-003: 100% préstamos bloqueados si no disponibles ← depende de FR-018-FR-019 (clara)
- SC-004: 100% devoluciones = +10 puntos (clara) ← depende de FR-021 (clara)
- SC-005: 99% informe coincidente (clara) ← depende de FR-023 (clara)
- SC-006: 95% búsquedas en 2 seg bajo carga 100k/10k ← depende de FR-022 OPTIMIZADA

**Hallazgos**:
- SC-003, SC-004, SC-005 son claras y alcanzables
- SC-001, SC-002, SC-006 dependen de optimizaciones NO especificadas en FRs
- Gap: No hay FRs que digan "usar índices" o "paginación"

**Falta**: 
- Agregar FRs de optimización explícitas
- Ej: "FR-022b: MUST implementar índices de base de datos en título, autor, categoría para mantener latencia < 2 seg"
- Ej: "FR-022c: Resultados de búsqueda MUST estar paginados (max 100 items por página)"

---

### CHK026 - ¿La autenticación (Clarification Q1) no crea inconsistencias con permisos?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- Clarifications Q1: "Solo bibliotecario autenticado; cliente consulta disponibilidad sin autenticación"
- US4-Scenario 1: "usuario consulta disponibilidad con filtro" (usuario genérico = cliente sin auth)
- Assumptions: "Autenticación en v1: solo bibliotecario requiere login. Cliente consulta disponibilidad sin autenticación"

**Hallazgos**:
- La separación es clara: bibliotecario = operaciones autenticadas, cliente = lectura sin auth
- No hay inconsistencia

**Falta**: Nada. Considerar si el cliente debería poder ver "sus propios préstamos activos" (requerirá alguna forma de identificación por DNI).

---

## ACCEPTANCE CRITERIA QUALITY (CHK027-CHK030)

### CHK027 - ¿Cada US tiene ≥3 escenarios DADO-CUANDO-ENTONCES? ¿Son independientes?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- US1: 4 escenarios GWT
- US2: 4 escenarios GWT
- US3: 3 escenarios GWT
- US4: 4 escenarios GWT

**Hallazgos**:
- Todos cumplen ≥3 escenarios
- Todos están en formato DADO-CUANDO-ENTONCES
- Cada uno es independiente (no dependen uno del otro para ser válido)

**Falta**: Nada.

---

### CHK028 - ¿Hay cobertura positivo/negativo? ¿Rechazo por story?

**Estado**: ⚠️ **PARCIALMENTE CUMPLIDO**

**Ubicación en spec.md**:
- US1: ✓ Positivo (Scenario 1, 3), ✓ Negativo (Scenario 2), ✓ Alternativa (Scenario 4)
- US2: ✓ Positivo (Scenario 1, 2), ✓ Negativo (Scenario 3, 4)
- US3: ✓ Positivo (Scenario 1, 2), ✓ Negativo (Scenario 3)
- US4: ✓ Positivo (Scenario 1, 2, 3, 4), ✗ **FALTA NEGATIVO EXPLÍCITO**

**Hallazgs**:
- US1, US2, US3 tienen cobertura clara de positivo y negativo
- US4 es TODA positiva (happy path)
  - Scenario 1: Consulta exitosa
  - Scenario 2: Búsqueda con múltiples filtros (exitosa)
  - Scenario 3: Informe generado (exitoso)
  - Scenario 4: Informe actualizado (exitoso)
  - **FALTA**: Scenario negativo ej: "búsqueda sin resultados", "intentar crear informe sin préstamos"

**Falta**: 
- Agregar al menos 1 escenario negativo para US4
  - Ej: "Cuando el usuario busca con criterios que no tienen coincidencias, entonces el sistema retorna lista vacía"
  - Ej: "Cuando no hay préstamos activos, entonces el informe está vacío"

---

### CHK029 - ¿Success criteria son medibles y objetivas?

**Estado**: ✅ **CUMPLIDO**

**Ubicación en spec.md**:
- SC-001: "95% ... 2 segundos" → Medible (porcentaje, tiempo)
- SC-002: "90% ... 2 minutos" → Medible (porcentaje, tiempo)
- SC-003: "100% ... bloqueados" → Medible (porcentaje)
- SC-004: "100% ... 10 puntos exactamente" → Medible (porcentaje, valor)
- SC-005: "99% ... coincidencia" → Medible (porcentaje)
- SC-006: "95% ... 2 segundos en carga 100k/10k" → Medible (porcentaje, tiempo, condición)

**Hallazgos**:
- Todos son medibles con métrica objetiva
- No hay criterios subjetivos ("bonito", "rápido", "fácil")

**Falta**: Nada.

---

### CHK030 - ¿Hay cobertura explícita de casos borde (Edge Cases)?

**Estado**: ⚠️ **PARCIALMENTE CUMPLIDO**

**Ubicación en spec.md**:
- Edge Cases (9 identificados):
  1. ISBN duplicado → Cubierto por FR-006 (validar idEjemplar único) pero **NO hay escenario GWT**
  2. Préstamo para cliente inactivo → **NO ESPECIFICADO en US/FR**
  3. Baja de libro con préstamos → Cubierto por FR-007 + US2-Scenario 3 ✓
  4. Devolución duplicada → **NO ESPECIFICADO**
  5. Inicial sin foto → Resuelto (foto neutral) + Clarifications ✓
  6. Caracteres especiales en nombre → **NO ESPECIFICADO**
  7. Páginas negativas → **NO ESPECIFICADO**
  8. Múltiples préstamos históricos → Implícito en FR-021 pero **NO hay scenario explícito**
  9. Préstamo de libro sin copyright → Cubierto por FR-024 + US2-Scenario 4 ✓

**Hallazgos**:
- 3 de 9 edge cases están bien cubiertos con FRs + scenarios
- 6 de 9 faltan scenarios GWT explícitos o FRs claros

**Falta**: 
- **Crítico**: Formalizar scenarios de aceptación para edge cases:
  - Edge case 1: Agregar scenario "Intento registrar libro con ISBN existente → Sistema rechaza"
  - Edge case 2: Agregar FR + scenario para cliente inactivo
  - Edge case 4: Agregar scenario "Intento devolver dos veces → Sistema rechaza segunda"
  - Edge case 6: Agregar scenario "Registrar cliente con nombre con caracteres especiales → Sistema acepta"
  - Edge case 7: Agregar scenario "Registrar libro con páginas = 0 → Sistema rechaza"
  - Edge case 8: Consultar si el scenario ya está cubierto o necesita uno explícito

---

## ARCHITECTURE & DOMAIN MODEL ALIGNMENT (CHK031-CHK032)

### CHK031 - ¿El modelo refleja reglas de negocio sin ser anémico (Principio II)?

**Estado**: ⚠️ **PARCIALMENTE CUMPLIDO (falta claridad de responsabilidades)**

**Ubicación en spec.md**:
- **Libro**: Atributos + estado activo/inactivo + copyright vigente
- **Cliente**: Atributos + puntos acumulados + foto de perfil
- **Préstamo**: Atributos + estado + fechas
- **AsignacionFotoPerfil**: Regla de negocio explícita

**Hallazgos**:
- Las entidades tienen atributos bien definidos
- Los atributos representan estado (no son anémicas)
- **PERO**: No está claro DÓNDE vive cada regla:
  - ¿Quién valida que un libro solo es prestable si: activo AND copyright vigente?
  - ¿Quién valida que no se puede dar de baja un libro con préstamos activos?
  - ¿Quién calcula "devolución anticipada"?
  - ¿Quién asigna la foto de perfil?

**Falta**: 
- **Agregados y responsabilidades**: Especificar qué entidad/agregado es responsable de cada regla
- Ejemplo (sugerencia arquitectónica, no obligatorio):
  - Agregado **Libro**: Valida que solo se devuelve si está activo + copyright
  - Agregado **Cliente**: Valida que no excede límite de préstamos
  - Agregado **Préstamo**: Valida fechas, calcula si es anticipada, suma puntos al devolver
  - Servicio **AsignacionFoto**: Encargado de asignar foto basándose en inicial

---

### CHK032 - ¿Hay definición clara de responsabilidades entre entidades (Principio III)?

**Estado**: ❌ **NO CUMPLIDO**

**Ubicación en spec.md**:
- FRs especifican QUÉ debe hacer el sistema pero NO especifican QUIÉN (qué entidad/servicio)
- Ej: FR-018 dice "verificar disponibilidad" pero ¿quién lo hace?
- Ej: FR-021 dice "sumar 10 puntos" pero ¿quién lo calcula?

**Hallazgos**:
- Las FRs están centradas en el SISTEMA (comportamiento) no en ENTIDADES (responsabilidades)
- No hay claridad de límites de agregados
- No hay claridad de qué servicio coordina cada flujo

**Falta**:
- **CRÍTICO para Principio III (Separation of Concerns)**:
  - Especificar qué entidad/agregado es responsable de cada operación
  - Ejemplo de lo que falta:
    - "Agregado Libro: Valida disponibilidad (no tiene préstamos activos)"
    - "Agregado Cliente: Valida que no excede límite configurable"
    - "Agregado Préstamo: Valida fechas, calcula puntos de anticipación"
    - "Servicio PréstamoAppService: Coordina crear préstamo (valida libro, cliente, límite, luego crea Préstamo)"
  - Esta info debería ir en data-model.md durante la fase de PLAN

---

## RESUMEN DE HALLAZGOS

### ✅ CUMPLIDOS (20 items)
CHK001, CHK002, CHK003, CHK004, CHK005, CHK006, CHK007, CHK008, CHK011, CHK012, CHK013, CHK014, CHK015, CHK016, CHK018, CHK019, CHK021, CHK023, CHK027, CHK029

### ⚠️ PARCIALMENTE CUMPLIDOS / CON OBSERVACIONES (10 items)
- **CHK009**: Duplicidad en FR-021 (numeración)
- **CHK010**: Depende de CHK009
- **CHK017**: Inconsistencia en métrica de performance (100% vs 95%)
- **CHK020**: Copyright vigente no está definido (booleano vs fecha)
- **CHK022**: Inconsistencia potencial en disponibilidad (¿aparece en búsquedas sí/no?)
- **CHK024**: Trade-off UX vs Escalabilidad no resuelto
- **CHK025**: Success Criteria dependen de optimizaciones no especificadas
- **CHK028**: US4 falta escenario negativo
- **CHK030**: 6 de 9 edge cases sin scenarios GWT
- **CHK031**: Falta claridad de responsabilidades en entidades

### ❌ NO CUMPLIDOS (2 items)
- **CHK032**: No hay definición de responsabilidades entre entidades (CRÍTICO para Principio III)

---

## RECOMENDACIONES DE CORRECCIÓN

### ALTO IMPACTO (resolver antes de planning)

1. **CHK009**: Renumerar FR-021 duplicado
   - Primer FR-021 (actual): "Sumar 10 puntos por devolución anticipada"
   - Segundo FR-021: Debería ser **FR-022** "Permitir consultar disponibilidad"
   - Cascada de renumeración: FR-022→FR-023, FR-023→FR-024

2. **CHK017**: Aclarar métrica de performance
   - ¿NFR-003 es "100% en 2 seg" o "95% en 2 seg"?
   - Recomendación: "NFR-003: >= 95% de consultas en <=2 seg en condiciones operativas normales (100k libros, 10k clientes, carga típica)"

3. **CHK020**: Definir modelo de copyright
   - Agregar a FR-004: "estado de copyright: booleano (vigente=true, no vigente=false) O fecha de vencimiento"
   - Agregar FR nueva: "Sistema MUST verificar copyright vigente de cada libro antes de permitir préstamo"

4. **CHK022**: Aclarar disponibilidad de libro con préstamo
   - Agregar a FR-024 o como FR nueva: "Un ejemplar con préstamo activo NO es disponible (estado=PRESTADO) y debe aparecer en búsquedas como 'No disponible'"

5. **CHK032 (CRÍTICO)**: Especificar responsabilidades
   - Esto debería ir en data-model.md (fase PLAN), pero puede añadirse a spec.md como subsección "Domain Model Responsibilities" preparatorio

### MEDIO IMPACTO (resolver antes de planning)

6. **CHK024-CHK025**: Especificar mecanismos de optimización
   - Agregar FRs de optimización:
     - "FR-025: Sistema MUST usar índices de base de datos en campos: título, autor, categoría para búsquedas"
     - "FR-026: Resultados de búsqueda MUST estar paginados (máx 100 items por página)"

7. **CHK028**: Agregar scenario negativo a US4
   - Scenario 5: "Búsqueda sin resultados"

8. **CHK030**: Formalizar scenarios para edge cases
   - Agregar 6 scenarios GWT para edge cases 1, 2, 4, 6, 7, 8

### BAJO IMPACTO (no bloquean planning)

9. **CHK014**: Banco de fotos de animales
   - Considerar para requirements de datos pero no es bloqueante

---

## CALIFICACIÓN GENERAL DEL CHECKLIST

| Categoría | Score | Estado |
|-----------|-------|--------|
| Completeness | 12/12 | ✅ Completo (con 1 observación de numeración) |
| Clarity | 6.5/8 | ⚠️ Parcial (2 aclaraciones críticas faltantes) |
| Consistency | 5/6 | ⚠️ Parcial (1 inconsistencia potencial) |
| Acceptance Criteria | 3.5/4 | ⚠️ Parcial (falta 1 negativo, 6 edge cases) |
| Architecture | 0/2 | ❌ No cumplido (falta responsabilidades) |
| **TOTAL** | **27.5/32** | **⚠️ 86% Listo (resolver 5 críticos antes de plan) |

---

**Recomendación**: Especificación LISTA PARA PLANNING con 5 correcciones de ALTO IMPACTO a resolver en esta fase antes de pasar a `/speckit.plan`.
