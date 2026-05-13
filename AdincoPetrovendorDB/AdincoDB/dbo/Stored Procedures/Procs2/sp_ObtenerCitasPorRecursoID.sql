CREATE PROCEDURE [dbo].[sp_ObtenerCitasPorRecursoID]
		@Usuario as varchar(150),
		@FechaFinalEntrega as VarChar(10) -- = '02/10/2017';
AS BEGIN    

DECLARE 
		@FECHAFINAL AS DATETIME,		
		@DIASELABORACION AS INT;

--TIPO:
--Normal = 0,
--Pattern = 1,
--Occurrence = 2,
--ChangedOccurrence = 3,
--DeletedOccurrence = 4

--ESTATUS
--0-Libre
--1-Tentativo
--2-ocupado
--3-Fuera de oficina
--4-Trabajando en algo mas

--LABEL COLOR
--https://documentation.devexpress.com/WindowsForms/1754/Controls-and-Libraries/Scheduler/Fundamentals/Appointments/Appointment-Labels-and-Statuses
--3 Personal -Verde
--2 Business -Azul
--1 Important -Rosa
--10 Phone Call -Amarillo

--Formato dd/mm//YYY
SET @FECHAFINAL = convert(datetime, @FechaFinalEntrega, 103);
SET @DIASELABORACION = 5;

-----------------------------------------------------------------------
-----------------------CITA ELABORACI�N-------------------------------
SELECT 		
	     CE.IdContratoEntregable [CitaID]
		, 0 AS [Tipo]
		, dbo.fn_AGREGADIASHABILES(@FECHAFINAL, 0,0,0,0, (ISNULL(CE.DiasAprobacion,0) + ISNULL(CE.DiasRevision,0) + @DIASELABORACION), -1) AS [FechaInicio]
		, dbo.fn_AGREGADIASHABILES(@FECHAFINAL, 23,59,59,0, (ISNULL(CE.DiasAprobacion,0) + ISNULL(CE.DiasRevision,0) + @DIASELABORACION), -1) AS [FechaFin]
		, 1 AS TodoElDia -- Gets or sets a value indicating if the current appointment is an all-day appointment.
		, 'Elaboraci�n de ' + E.DocumentoEntregable AS [Asunto]
		, '' As [Ubicacion]
		, E.Descripcion As [Descripcion]
		, 0 AS [Estatus]
		, 3 AS [Label]
		, CE.Elabora AS [RecursoID]
		, ISNULL(CE.DiasRevision,0) AS DiasRevision
		, ISNULL(CE.DiasAprobacion,0) AS DiasAprobacion
		, '' RecursoIDs
		, '' RecordatorioInfo
		, '' ReaparicionInfo
  FROM  EN_Entregable E 
  INNER JOIN EN_ContratoEntregable CE 
	ON E.IdEntregable = CE.IdEntregable		
	AND E.BITJOA = 0
  WHERE CE.Elabora =@Usuario
		AND LEN(RTRIM(LTRIM(CE.Elabora))) > 0 --Pendiente revisar***

UNION ALL

-----------------------------------------------------------------------
-----------------------CITA REVISI�N-------------------------------
SELECT 		
	     CE.IdContratoEntregable [CitaID]
		, 0 AS [Tipo]
		, dbo.fn_AGREGADIASHABILES(@FECHAFINAL, 0,0,0,0, (ISNULL(CE.DiasAprobacion,0) + ISNULL(CE.DiasRevision,0)), -1) AS [FechaInicio]
		, dbo.fn_AGREGADIASHABILES(@FECHAFINAL, 23,59,59,0, (ISNULL(CE.DiasAprobacion,0) + ISNULL(CE.DiasRevision,0)), -1) AS [FechaFin]
		, 1 AS TodoElDia -- Gets or sets a value indicating if the current appointment is an all-day appointment.
		, 'Revisi�n de ' + E.DocumentoEntregable AS [Asunto]
		, '' As [Ubicacion]
		, E.Descripcion As [Descripcion]
		, 0 AS [Estatus]
		, 2 AS [Label]
		, CE.Revisa AS [RecursoID]
		, ISNULL(CE.DiasRevision,0) AS DiasRevision
		, ISNULL(CE.DiasAprobacion,0) AS DiasAprobacion
		, '' RecursoIDs
		, '' RecordatorioInfo
		, '' ReaparicionInfo
  FROM  EN_Entregable E 
  INNER JOIN EN_ContratoEntregable CE ON E.IdEntregable = CE.IdEntregable	
  AND E.BITJOA = 0
  WHERE CE.Revisa = @Usuario
		AND LEN(RTRIM(LTRIM(CE.Revisa))) > 0 --Pendiente revisar***

UNION ALL

-----------------------------------------------------------------------
-----------------------CITA APROBACI�N-------------------------------
SELECT 		
	     CE.IdContratoEntregable [CitaID]
		, 0 AS [Tipo]
		, dbo.fn_AGREGADIASHABILES(@FECHAFINAL, 0,0,0,0, ISNULL(CE.DiasAprobacion,0), -1) AS [FechaInicio]
		, dbo.fn_AGREGADIASHABILES(@FECHAFINAL, 23,59,59,0, ISNULL(CE.DiasAprobacion,0), -1) AS [FechaFin]
		, 1 AS TodoElDia -- Gets or sets a value indicating if the current appointment is an all-day appointment.
		, 'Aprobaci�n de ' + E.DocumentoEntregable AS [Asunto]
		, '' As [Ubicacion]
		, E.Descripcion As [Descripcion]
		, 0 AS [Estatus]
		, 1 AS [Label]
		, CE.Aprueba AS [RecursoID]
		, ISNULL(CE.DiasRevision,0) AS DiasRevision
		, ISNULL(CE.DiasAprobacion,0) AS DiasAprobacion
		, '' RecursoIDs
		, '' RecordatorioInfo
		, '' ReaparicionInfo
  FROM  EN_Entregable E 
  INNER JOIN EN_ContratoEntregable CE ON E.IdEntregable = CE.IdEntregable
  AND E.BITJOA = 0	
  WHERE CE.Aprueba = @Usuario
		AND LEN(RTRIM(LTRIM(CE.Aprueba))) > 0 --Pendiente revisar***

UNION ALL
-----------------------------------------------------------------------
-----------------------------ENTREGA ----------------------------------
SELECT 		
	     CE.IdContratoEntregable [CitaID]
		, 0 AS [Tipo]
		, DATETIMEFROMPARTS (DATEPART(year, @FECHAFINAL), DATEPART(month, @FECHAFINAL), DATEPART(day, @FECHAFINAL), 0, 0, 0, 0) AS [FechaInicio]
		, DATETIMEFROMPARTS (DATEPART(year, @FECHAFINAL), DATEPART(month, @FECHAFINAL), DATEPART(day, @FECHAFINAL), 23, 59, 59, 0) AS [FechaFin]
		, 1 AS TodoElDia -- Gets or sets a value indicating if the current appointment is an all-day appointment.
		, 'Entrega de ' + E.DocumentoEntregable AS [Asunto]
		, '' As [Ubicacion]
		, E.Descripcion As [Descripcion]
		, 0 AS [Estatus]
		, 10 AS [Label]
		, CE.Entrega AS [RecursoID]
		, ISNULL(CE.DiasRevision,0) AS DiasRevision
		, ISNULL(CE.DiasAprobacion,0) AS DiasAprobacion
		, '' RecursoIDs
		, '' RecordatorioInfo
		, '' ReaparicionInfo
  FROM  EN_Entregable E 
  INNER JOIN EN_ContratoEntregable CE ON E.IdEntregable = CE.IdEntregable		
  AND E.BITJOA = 0
  WHERE CE.Entrega = @Usuario		

END