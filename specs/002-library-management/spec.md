# Feature Specification: Sistema de Gestion de Biblioteca

**Feature Branch**: `002-add-library-management`

**Created**: 2026-06-07

**Status**: Draft

**Input**: User description: "Desarrollar un sistema de biblioteca que permita gestionar libros, clientes y prestamos..."

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Gestionar prestamos y devoluciones (Priority: P1)

Como bibliotecario, quiero registrar prestamos y devoluciones para controlar que libros estan activos, su disponibilidad y los puntos por devolucion anticipada.

**Why this priority**: Sin este flujo no existe operacion central de la biblioteca ni control de disponibilidad real.

**Independent Test**: Puede validarse creando un cliente y libro de prueba, registrando un prestamo con fechas y luego una devolucion anticipada para verificar disponibilidad y suma de puntos.

**Acceptance Scenarios**:

1. **Given** un libro disponible y un cliente activo, **When** el bibliotecario registra un prestamo con fecha inicio y fecha fin prevista, **Then** el sistema crea el prestamo y marca el libro como no disponible.
2. **Given** un libro con prestamo activo, **When** el bibliotecario intenta prestar ese mismo ejemplar, **Then** el sistema rechaza la operacion por falta de disponibilidad.
3. **Given** un prestamo activo y fecha fin prevista posterior a hoy, **When** el bibliotecario registra una devolucion hoy, **Then** el sistema cierra el prestamo, marca el libro como disponible y suma 10 puntos al cliente.
4. **Given** un prestamo activo cuya fecha fin prevista es hoy o anterior, **When** se registra la devolucion, **Then** el sistema cierra el prestamo y no suma puntos por entrega anticipada.

---

### User Story 2 - Administrar catalogo de libros (Priority: P1)

Como bibliotecario, quiero dar de alta, modificar y dar de baja libros para mantener el catalogo actualizado y legalmente valido.

**Why this priority**: El prestamo depende de un catalogo correcto; sin libros administrables no hay servicio de biblioteca.

**Independent Test**: Puede validarse creando, actualizando y dando de baja libros, comprobando que solo libros activos y con copyright vigente sean elegibles para prestamo.

**Acceptance Scenarios**:

1. **Given** datos completos y validos del libro, **When** el bibliotecario registra un nuevo libro, **Then** el sistema almacena titulo, autor, paginas, editorial, ISBN, saga, categoria y copyright vigente.
2. **Given** un libro existente, **When** el bibliotecario modifica sus datos, **Then** el sistema guarda los cambios y mantiene trazabilidad del libro.
3. **Given** un libro activo sin prestamos activos, **When** el bibliotecario da de baja el libro, **Then** el sistema lo marca como inactivo y deja de mostrarlo como disponible.
4. **Given** un libro con copyright no vigente, **When** se intenta habilitar para prestamo, **Then** el sistema bloquea su disponibilidad para cumplir reglas legales.

---

### User Story 3 - Administrar clientes y foto automatica (Priority: P2)

Como bibliotecario, quiero gestionar clientes y que el sistema asigne foto de perfil automaticamente para mantener fichas completas sin pasos manuales extra.

**Why this priority**: Es necesaria para operar prestamos, pero puede desarrollarse despues del nucleo de prestamos y catalogo.

**Independent Test**: Puede validarse registrando clientes con distintas iniciales y verificando asignacion automatica de foto animal, junto con alta, modificacion y baja.

**Acceptance Scenarios**:

1. **Given** datos validos de un cliente nuevo, **When** se registra el cliente, **Then** el sistema guarda nombre, apellido, DNI, fecha de nacimiento, puntos y asigna foto de animal con la misma inicial del nombre.
2. **Given** un cliente existente, **When** el bibliotecario actualiza datos permitidos, **Then** el sistema persiste cambios sin perder historial de puntos.
3. **Given** un cliente sin prestamos activos, **When** el bibliotecario lo da de baja, **Then** el cliente queda inactivo para nuevos prestamos.

---

### User Story 4 - Consultar disponibilidad e informes operativos (Priority: P3)

Como cliente y bibliotecario, quiero consultar disponibilidad de libros y obtener informes de prestamos vigentes para tomar decisiones rapidas.

**Why this priority**: Aporta eficiencia operativa y visibilidad, pero depende de que existan libros, clientes y prestamos.

**Independent Test**: Puede validarse con prestamos activos y cerrados, consultando disponibilidad por libro y generando informe de prestamos en cualquier momento.

**Acceptance Scenarios**:

1. **Given** un libro con o sin prestamos activos, **When** un usuario consulta su disponibilidad, **Then** el sistema responde en no mas de 2 segundos con estado claro (disponible/no disponible).
2. **Given** multiples prestamos activos, **When** el bibliotecario genera el informe de libros prestados, **Then** el informe lista cada libro actualmente prestado y el cliente asociado.
3. **Given** que un prestamo fue devuelto, **When** se vuelve a generar el informe, **Then** ese prestamo no aparece como activo.

### Edge Cases

- Intento de alta de libro con ISBN ya existente.
- Intento de prestamo para cliente dado de baja o inexistente.
- Intento de baja de libro con prestamo activo.
- Devolucion duplicada de un mismo prestamo ya cerrado.
- Cliente registrado con inicial sin foto de animal disponible.
- Nombre de cliente con caracteres especiales o espacios iniciales.
- Libro con cantidad de paginas cero o negativa.
- Consulta de disponibilidad cuando existen multiples prestamos historicos del mismo libro.
- Intento de prestamo de libro con copyright no vigente.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: El sistema MUST permitir registrar un nuevo libro con todos los campos obligatorios definidos por negocio.
- **FR-002**: El sistema MUST permitir modificar los datos de un libro existente.
- **FR-003**: El sistema MUST permitir dar de baja un libro.
- **FR-004**: El sistema MUST almacenar para cada libro: titulo, autor, cantidad de paginas, editorial, ISBN, indicador de saga, categoria y estado de copyright vigente.
- **FR-005**: El sistema MUST restringir categoria de libro a: infantiles, juveniles, adultos o conocimiento.
- **FR-006**: El sistema MUST validar que el ISBN sea unico dentro del catalogo.
- **FR-007**: El sistema MUST impedir que un libro con prestamos activos sea dado de baja operativamente.
- **FR-008**: El sistema MUST permitir registrar un nuevo cliente.
- **FR-009**: El sistema MUST permitir modificar datos de cliente.
- **FR-010**: El sistema MUST permitir dar de baja un cliente.
- **FR-011**: El sistema MUST almacenar para cada cliente: nombre, apellido, DNI, fecha de nacimiento, foto de perfil y puntos acumulados.
- **FR-012**: El sistema MUST validar que el DNI sea unico por cliente.
- **FR-013**: El sistema MUST asignar automaticamente una foto de perfil de animal al registrar un cliente.
- **FR-014**: El sistema MUST asignar una foto cuyo animal inicie con la misma letra del nombre de pila del cliente.
- **FR-015**: El sistema MUST permitir registrar prestamos con fecha de inicio y fecha final prevista.
- **FR-016**: El sistema MUST permitir que un cliente tenga varios prestamos activos en paralelo.
- **FR-017**: El sistema MUST verificar disponibilidad antes de confirmar cualquier prestamo.
- **FR-018**: El sistema MUST rechazar prestamos cuando el libro no este disponible.
- **FR-019**: El sistema MUST registrar devoluciones y actualizar el estado del prestamo a cerrado.
- **FR-020**: El sistema MUST sumar 10 puntos al cliente cuando la devolucion se registre antes de la fecha final prevista.
- **FR-021**: El sistema MUST permitir consultar disponibilidad de un libro considerando prestamos activos.
- **FR-022**: El sistema MUST generar en cualquier momento un informe de libros actualmente prestados con identificacion del cliente asociado.
- **FR-023**: El sistema MUST impedir considerar disponible para prestamo cualquier libro con copyright no vigente.

### Non-Functional Requirements

- **NFR-001 (Usabilidad)**: La interfaz MUST permitir encontrar libros disponibles en un flujo simple y comprensible para usuarios no tecnicos.
- **NFR-002 (Claridad de informacion)**: El estado de disponibilidad MUST mostrarse de forma clara y sin ambiguedad.
- **NFR-003 (Tiempo de respuesta)**: La consulta de disponibilidad MUST completarse en <= 2 segundos en condiciones operativas normales.
- **NFR-004 (Escalabilidad)**: El sistema MUST soportar al menos 100000 libros y 10000 clientes sin degradar el objetivo de disponibilidad definido.
- **NFR-005 (Cumplimiento legal)**: Todos los libros registrados MUST mantener estado de copyright vigente para ser prestables.
- **NFR-006 (Calidad de arquitectura)**: Reglas de negocio y validaciones MUST estar separadas de la capa de interfaz.
- **NFR-007 (Calidad de especificacion)**: Validaciones importantes MUST estar explicitadas como criterios de aceptacion en historias y requisitos.

### Key Entities *(include if feature involves data)*

- **Libro**: Representa una obra prestable del catalogo. Atributos clave: titulo, autor, paginas, editorial, ISBN, perteneceSaga, categoria, copyrightVigente, estadoActivo.
- **Cliente**: Representa una persona habilitada para prestar libros. Atributos clave: nombre, apellido, DNI, fechaNacimiento, fotoPerfil, puntosAcumulados, estadoActivo.
- **Prestamo**: Representa la asignacion temporal de un libro a un cliente. Atributos clave: libro, cliente, fechaInicio, fechaFinPrevista, fechaDevolucion, estado.
- **AsignacionFotoPerfil**: Regla de negocio que vincula inicial del nombre de pila con un animal disponible para foto de perfil.
- **InformePrestamosActivos**: Vista de negocio que lista prestamos en estado activo con libro y cliente asociado.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 95% de consultas de disponibilidad se completan en 2 segundos o menos durante operacion habitual.
- **SC-002**: Bibliotecarios completan alta de libro con datos obligatorios en menos de 2 minutos en al menos 90% de los intentos observados.
- **SC-003**: El 100% de prestamos registrados quedan bloqueados cuando el libro no esta disponible o su copyright no esta vigente.
- **SC-004**: El 100% de devoluciones anticipadas registradas incrementan exactamente 10 puntos del cliente.
- **SC-005**: El informe de prestamos activos refleja en tiempo real al menos el 99% de coincidencia con el estado operativo de prestamos.
- **SC-006**: En pruebas de carga objetivo (100000 libros y 10000 clientes), la busqueda de disponibilidad mantiene cumplimiento del umbral de 2 segundos en al menos 95% de consultas.

## Ambiguedades Identificadas

- **AMB-001**: "Tomar varios libros prestados" no define limite maximo por cliente.
  - **Supuesto aplicado**: No se establece limite global en esta version; el control de cupos queda para futuras iteraciones.
- **AMB-002**: No se define comportamiento cuando no existe animal con la inicial del nombre.
  - **Supuesto aplicado**: Se usa una foto de respaldo neutral y se registra advertencia operativa.
- **AMB-003**: "Dar de baja" no especifica si es eliminacion fisica o logica.
  - **Supuesto aplicado**: Se interpreta como baja logica para preservar trazabilidad historica.

## Assumptions

- El sistema es de uso interno de biblioteca y contempla al menos los actores bibliotecario y cliente.
- Pagos, multas, compra de libros y recomendaciones automaticas quedan fuera de alcance de esta version.
- Login avanzado por roles no forma parte del alcance inicial salvo minima separacion funcional de vistas/acciones por actor.
- Los datos historicos de prestamos deben conservarse para auditoria operativa e informes.
- El pais de operacion define legalmente que solo libros con copyright vigente pueden prestarse.
- Esta especificacion define QUE debe hacer el sistema; decisiones de stack y arquitectura tecnica se deferiran a planificacion.
