	CREATE PROCEDURE sp_ExtraeEntregablesFaltantesElaboracion_HistoricoPorArea-- 3,10061
		@IdContrato INT,
		@idUsuario INT
	AS
	BEGIN
-- =============================================
-- Author: Daniel Ac
-- Create date: 11-10-2020
-- Description: Se reutiliza el sp_ExtraeEntregablesFaltantesElaboracion_Historico pero se filtra por área
-- =============================================
	SET NOCOUNT ON;

	SET LANGUAGE Spanish;
	DECLARE @Count int = 0;

	DECLARE @Areas AS TABLE (
	  ID int IDENTITY (1, 1),
	  Area nvarchar(250)
	);

	DECLARE @TempInstancias AS TABLE (
	  id int PRIMARY KEY IDENTITY (1, 1),
	  FechasLimiteElaboracion date,
	  idEntregable int,
	  countIntancias int NULL
	);

	DECLARE @GrupoUsuario AS TABLE (
	  id int PRIMARY KEY IDENTITY (1, 1),
	  IdUsuarioGrupo int
	);

	DECLARE @Entregables AS TABLE (
	  idInstanciaEntregable INT,
	  IdEntregable INT,
	  IdContratoEntregable INT,
	  DocumentoEntregable VARCHAR(MAX),
	  Regulador  VARCHAR(MAX),
	  MarcoLegal  VARCHAR(MAX),
	  FechasLimiteElaboracion DATETIME,
	  FechaEntregaRegulador DATETIME,
	  FechasLimiteAprobacion DATETIME,
	  Estatus VARCHAR(MAX),
	  FrecuenciaEntregable VARCHAR(MAX),
	  Etapa VARCHAR(MAX),
	  idRegulador VARCHAR(MAX),	 
	  Consecutivo  VARCHAR(MAX),
	  Articulo  VARCHAR(MAX),
	  FocalPoint VARCHAR(MAX),
	  AccountableCompliance VARCHAR(MAX),
	  Accountable VARCHAR(MAX),
	  NombreProgramacionProcesos VARCHAR(MAX),
	  bitMostrarMensaje BIT,
	  MesReportar DATETIME,
	  BitSasisopa BIT,
	  Observaciones VARCHAR(MAX),
	  AreaResponsable VARCHAR(MAX)
	);

	/*OBTENER AREAS QUE PUEDE VER EL USUARIO ACTUAL */
	INSERT INTO @Areas (Area)
	  SELECT
		REPLACE(P.NombrePermiso, 'Acceso a Entregables de ', '')
	  FROM dbo.AP_PermisosUsuarios PU
	  JOIN dbo.AP_Permiso P
		ON P.IdPermiso = PU.IdPermiso
	  WHERE UsuarioID = @IdUsuario
	  AND PU.idContrato = @IdContrato
	  AND P.BitActivo = 1
	  AND PU.BitActivo = 1;

	IF 0 < (SELECT
		COUNT(1)
	  FROM AP_USUARIO U
	  JOIN AP_PERFILUSUARIO PU
		ON U.USUARIOID = PU.USUARIOID
		AND U.UsuarioID = @idUsuario
	  JOIN AP_PERFIL P
		ON PU.PerfilID = P.IdPerfil
		AND P.IdContrato = @IdContrato
	  JOIN AP_ROL R
		ON P.IdRol = R.IdRol
	  WHERE R.Descripción LIKE '%SASISOPA%')
	BEGIN
	
	  EXEC sp_ExtraeEntregablesFaltantesElaboracion_SASISOPA @IdContrato,
															 @idUsuario
	  RETURN
	END

	/*OBTENER LOS GRUPOS DEL CONTRATO*/
	INSERT INTO @GrupoUsuario (IdUsuarioGrupo)
	  SELECT
		IdGrupo
	  FROM EN_GruposUsuarios(NOLOCK)
	  WHERE IdContrato = @IdContrato
	  AND Activo = 1
	  UNION
	  SELECT
		UsuarioID
	  FROM AP_USUARIO
	  WHERE IsActivo = 1

	INSERT INTO @TempInstancias (FechasLimiteElaboracion, idEntregable)
	  SELECT
		IE.FechasLimiteElaboracion,
		CE.IdEntregable
	  FROM EN_InstanciasEntregable IE (NOLOCK)
	  JOIN EN_ContratoEntregable CE (NOLOCK)
		ON IE.IdContratoEntregable = CE.IdContratoEntregable
		AND CE.IdContrato = @IdContrato
	  JOIN CO_Contrato C (NOLOCK)
		ON CE.IdContrato = C.IdContrato
		AND C.IdContrato = @IdContrato
		AND IE.FechasLimiteElaboracion < DATEADD(MONTH, 4, DATEADD(YEAR, 1, C.FechaArranqueEntregables))--'20211231' 
	  JOIN dbo.EN_Actividad A (NOLOCK)
		ON IE.ActividadID = A.ActividadID
	  JOIN dbo.EN_Entregable ENT (NOLOCK)
		ON CE.IdEntregable = Ent.IdEntregable
		AND ENT.BITJOA = 0
	  LEFT JOIN dbo.EN_ExcepcionesActividad EXAR (NOLOCK)
		ON A.ActividadID = EXAR.ActividadIDExcepcion
		AND IE.idInstanciaEntregable = EXAR.IdInstanciasEntregables
	  WHERE IE.FechasLimiteElaboracion < DATEADD(MONTH, 3, DATEADD(YEAR, 1, C.FechaArranqueEntregables))--'20211231' 
	  AND (
	  (A.idUsuario IN (SELECT
		IdUsuarioGrupo
	  FROM @GrupoUsuario)
	  AND EXAR.IdInstanciasEntregables IS NULL
	  AND A.EstadoID = 10000 --> EN ESTATUS ELABORACIÓN
	  AND ENT.IsActivo = 1
	  AND CE.Activo = 1
	  AND IE.Activo = 1
	  )
	  OR (

	  EXAR.idUsuario IN (SELECT
		IdUsuarioGrupo
	  FROM @GrupoUsuario)
	  AND EXAR.IdInstanciasEntregables IS NOT NULL
	  AND EXAR.EstadoID = 10000 --> EN ESTADO ELABORACIÓN
	  AND ENT.IsActivo = 1
	  AND CE.Activo = 1
	  AND IE.Activo = 1))
	  AND CE.IdContrato = @IdContrato
	  GROUP BY IE.FechasLimiteElaboracion,
			   CE.IdEntregable
			    
    --ENTREGABLES PENDIENTES 
	INSERT INTO @Entregables(
	  idInstanciaEntregable,
	  IdEntregable,
	  IdContratoEntregable,
	  DocumentoEntregable,
	  Regulador,
	  MarcoLegal,
	  FechasLimiteElaboracion,
	  FechaEntregaRegulador,
	  FechasLimiteAprobacion,
	  Estatus,
	  FrecuenciaEntregable,
	  Etapa,
	  idRegulador,	 
	  Consecutivo,
	  Articulo,
	  FocalPoint,
	  AccountableCompliance,
	  Accountable,
	  NombreProgramacionProcesos,
	  bitMostrarMensaje,
	  MesReportar,
	  BitSasisopa,
	  Observaciones,
	  AreaResponsable)
	SELECT
	  idInstanciaEntregable=IE.idInstanciaEntregable,
	  IdEntregable=CE.IdEntregable,
	  IdContratoEntregable=CE.IdContratoEntregable,
	  DocumentoEntregable,
	  Regulador=ISNULL(R.Regulador, ''),
	  MarcoLegal=ISNULL(M.MarcoLegal, ''),
	  FechasLimiteElaboracion=IE.FechasLimiteElaboracion,
	  FechaEntregaRegulador=IE.FechaCalculadaEntregaReg,
	  FechasLimiteAprobacion=IE.FechasLimiteAprobacion,
	  Estatus=E.NombreEstado,
	  FrecuenciaEntregable=ISNULL(F.FrecuenciaEntregable, ''),
	  Etapa=ISNULL(ET.Etapa, ''),
	  idRegulador=ISNULL(EN.idRegulador, ''),	 
	  Consecutivo=EN.Consecutivo,
	  Articulo=ISNULL(EN.Articulo, ''),
	  FocalPoint=CASE
		WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint, '')
		ELSE ISNULL(FP.Nombre, '')
	  END,
	  AccountableCompliance=CASE
		WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance, '')
		ELSE ISNULL(AC.Nombre, '')
	  END,
	  Accountable=CASE
		WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable, '')
		ELSE ISNULL(ACC.Nombre, '')
	  END,
	  NombreProgramacionProcesos=ISNULL(P.NombreProceso + ' - ' + IPF.Descripcion, ''),
	  bitMostrarMensaje=ISNULL(EN.bitMostrarMensaje, 0),
	  MesReportar=CASE ISNULL(EN.bitMostrarMensaje, 0)
		WHEN 1 THEN DATEADD(MONTH, -1, IE.FechaCalculadaEntregaReg)
		ELSE IE.FechaCalculadaEntregaReg
	  END,
	  BitSasisopa=CASE
		WHEN ISNULL(CEPIA.IdContratoEntregable, 0) > 1 THEN 1
		ELSE 0
	  END,
	  Observaciones=EN.Observaciones,
	  AreaResponsable=are.NombreArea
	FROM @TempInstancias TI
	JOIN EN_InstanciasEntregable IE
	  ON TI.FechasLimiteElaboracion = IE.FechasLimiteElaboracion
	JOIN EN_ContratoEntregable CE
	  ON IE.IdContratoEntregable = CE.IdContratoEntregable
	  AND TI.idEntregable = CE.IdEntregable
	  AND CE.IdContrato = @IdContrato
	JOIN dbo.EN_Area are
	  ON CE.IdArea = are.idArea
	JOIN @Areas TAR
	  ON are.NombreArea = TAR.Area
	JOIN dbo.EN_Actividad A
	  ON IE.ActividadID = A.ActividadID
	  AND A.EstadoID = 10000  --> EN ESTADO ELABORACIÓN 
	JOIN @GrupoUsuario GU
	  ON A.idUsuario = GU.IdUsuarioGrupo
	JOIN dbo.EN_Estado E
	  ON A.EstadoID = E.EstadoID
	JOIN EN_Entregable EN
	  ON CE.IdEntregable = EN.IdEntregable
	  AND EN.BITJOA = 0
	LEFT JOIN dbo.CO_Regulador R
	  ON EN.IdRegulador = R.IdRegulador
	LEFT JOIN dbo.EN_FrecuenciaEntregable F
	  ON EN.IdFrecuenciaEntregable = F.IdFrecuenciaEntregable
	LEFT JOIN EN_Etapa ET
	  ON EN.IdEtapa = ET.IdEtapa
	LEFT JOIN dbo.EN_MarcoLegal M
	  ON EN.IdMarcoLegal = M.IdMarcoLegal
	LEFT JOIN AP_USUARIO FP       -- OBTENER NOMBRE DEL FOCAL POINT
	  ON CE.FocalPoint = FP.Usuario
	LEFT JOIN AP_USUARIO AC       -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
	  ON CE.AccountableCompliance = AC.Usuario
	LEFT JOIN AP_USUARIO ACC      -- OBTENER EL NOMBRE DEL ACCOUNTABLE
	  ON CE.Accountable = ACC.Usuario
	LEFT JOIN EN_InstanciasEntregables_InstanciaActividad IEIA
	  ON IE.idInstanciaEntregable = IEIA.idInstanciaEntregable
	LEFT JOIN EN_InstanciasActividades IA
	  ON IEIA.idInstanciaActividad = IA.idInstanciaActividad
	LEFT JOIN EN_InstanciasProcesosFecha IPF
	  ON IA.IdInstanciasProcesos = IPF.IdInstanciasProcesos
	LEFT JOIN EN_Procesos P
	  ON IPF.IdProceso = P.IdProceso
	LEFT JOIN EN_ContratoEntregableProgramaImplementaAcciones CEPIA
	  ON CE.IdContratoEntregable = CEPIA.IdContratoEntregable

	-- ENTREGABLE DONDE LAS EXCEPCIONES QUE SE LE ASIGNACION AL USUARIO ACTUAL
	UNION ALL  

	SELECT
	  idInstanciaEntregable=IE.idInstanciaEntregable,
	  IdEntregable=CE.IdEntregable,
	  IdContratoEntregable=CE.IdContratoEntregable,
	  DocumentoEntregable,
	  Regulador=ISNULL(R.Regulador, ''),
	  MarcoLegal=ISNULL(M.MarcoLegal, ''),
	  FechasLimiteElaboracion=IE.FechasLimiteElaboracion,
	  FechaEntregaRegulador=IE.FechaCalculadaEntregaReg,
	  FechasLimiteAprobacion=IE.FechasLimiteAprobacion,
	  Estatus=E.NombreEstado,
	  FrecuenciaEntregable=ISNULL(f.FrecuenciaEntregable, ''),
	  Etapa=ISNULL(Et.Etapa, ''),
	  idRegulador=ISNULL(EN.idRegulador, ''),	 
	  Consecutivo=EN.Consecutivo,
	  Articulo=ISNULL(EN.Articulo, ''),
	  FocalPoint=CASE
		WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint, '')
		ELSE ISNULL(FP.Nombre, '')
	  END,
	  AccountableCompliance=CASE
		WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance, '')
		ELSE ISNULL(AC.Nombre, '')
	  END,
	  Accountable=CASE
		WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable, '')
		ELSE ISNULL(ACC.Nombre, '')
	  END,
	  NombreProgramacionProcesos=ISNULL(P.NombreProceso + ' - ' + IPF.Descripcion, ''),
	  bitMostrarMensaje=ISNULL(EN.bitMostrarMensaje, 0),
	  MesReportar=CASE ISNULL(EN.bitMostrarMensaje, 0)
		WHEN 1 THEN DATEADD(MONTH, -1, IE.FechaCalculadaEntregaReg)
		ELSE IE.FechaCalculadaEntregaReg
	  END,
	  BitSasisopa=CASE
		WHEN ISNULL(CEPIA.IdContratoEntregable, 0) > 1 THEN 1
		ELSE 0
	  END,
	  Observaciones=EN.Observaciones,
	  AreaResponsable=are.NombreArea
	FROM @TempInstancias TI
	JOIN EN_InstanciasEntregable IE
	  ON TI.FechasLimiteElaboracion = IE.FechasLimiteElaboracion
	JOIN EN_ContratoEntregable CE
	  ON IE.IdContratoEntregable = CE.IdContratoEntregable
	  AND TI.idEntregable = CE.IdEntregable
	  AND CE.IdContrato = @IdContrato
	JOIN dbo.EN_Area are
	  ON CE.IdArea = are.idArea
	JOIN @Areas TAR
	  ON are.NombreArea = TAR.Area
	JOIN EN_ExcepcionesActividad EXACT
	  ON IE.idInstanciaEntregable = EXACT.IdInstanciasEntregables
	  AND EXACT.EstadoID = 10000--> EN ESTADO ELABORACIÓN
	JOIN @GrupoUsuario GU
	  ON EXACT.idUsuario = GU.IdUsuarioGrupo
	JOIN dbo.EN_Estado E
	  ON EXACT.EstadoID = E.EstadoID
	JOIN EN_Entregable EN
	  ON CE.IdEntregable = EN.IdEntregable
	  AND EN.BITJOA = 0
	LEFT JOIN dbo.EN_FrecuenciaEntregable F
	  ON EN.IdFrecuenciaEntregable = F.IdFrecuenciaEntregable
	LEFT JOIN dbo.CO_Regulador R
	  ON EN.IdRegulador = R.IdRegulador
	LEFT JOIN EN_Etapa ET
	  ON EN.IdEtapa = ET.IdEtapa
	LEFT JOIN dbo.EN_MarcoLegal M
	  ON EN.IdMarcoLegal = M.IdMarcoLegal
	LEFT JOIN AP_USUARIO FP       -- OBTENER NOMBRE DEL FOCAL POINT
	  ON CE.FocalPoint = FP.Usuario
	LEFT JOIN AP_USUARIO AC       -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
	  ON CE.AccountableCompliance = AC.Usuario
	LEFT JOIN AP_USUARIO ACC      -- OBTENER EL NOMBRE DEL ACCOUNTABLE
	  ON CE.Accountable = ACC.Usuario
	LEFT JOIN EN_InstanciasEntregables_InstanciaActividad IEIA
	  ON IE.idInstanciaEntregable = IEIA.idInstanciaEntregable
	LEFT JOIN EN_InstanciasActividades IA
	  ON IEIA.idInstanciaActividad = IA.idInstanciaActividad
	LEFT JOIN EN_InstanciasProcesosFecha IPF
	  ON IA.IdInstanciasProcesos = IPF.IdInstanciasProcesos
	LEFT JOIN EN_Procesos P
	  ON IPF.IdProceso = P.IdProceso
	LEFT JOIN EN_ContratoEntregableProgramaImplementaAcciones CEPIA
	  ON CE.IdContratoEntregable = CEPIA.IdContratoEntregable
	  

   SELECT @Count=COUNT(1) FROM @Entregables 
   
   SELECT
	  idInstanciaEntregable,
	  IdEntregable,
	  IdContratoEntregable,
	  DocumentoEntregable,
	  Regulador,
	  MarcoLegal,
	  FechasLimiteElaboracion,
	  FechaEntregaRegulador,
	  FechasLimiteAprobacion,
	  Estatus,
	  FrecuenciaEntregable,
	  Etapa,
	  idRegulador,	 
	  Consecutivo,
	  Articulo,
	  FocalPoint,
	  AccountableCompliance,
	  Accountable,
	  NombreProgramacionProcesos,
	  bitMostrarMensaje,
	  MesReportar,
	  BitSasisopa,
	  Observaciones,
	  AreaResponsable,
	  @Count AS countI
   FROM @Entregables
   

END


