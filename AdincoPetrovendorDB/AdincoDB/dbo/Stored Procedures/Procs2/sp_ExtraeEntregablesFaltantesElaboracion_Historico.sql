CREATE PROCEDURE [dbo].[sp_ExtraeEntregablesFaltantesElaboracion_Historico] --3,10--3,10061
    @IdContrato INT,
    @idUsuario INT
AS
BEGIN
    -- =============================================
    -- Author:  Reyna Olvera
    -- Create date: 2018-11-08
    -- Description: 
    -- 20190510 BAAC    Se modifica consulta de las fechas proximas para no considerar el id de la instancia
	-- 20211007	BAAC	Se modifica para considerar los entregbales de los proximos 5 años
    -- =============================================
	    -- =============================================
    -- Author:  Daniel AC
    -- Create date: 2020-05-11
    -- Description: Se agregar NOLOCKS en las tablas que tienen mas recurrencia y referencias al objero dbo
    -- =============================================
	-- =============================================
    -- Author:  Luis David 
    -- Create date: 28/09/22
    -- Description: Se eliminan subconsultas, reacomodo de tablas según su declaración y su cantidad de datos Issue#809(Entregables)
    -- =============================================
    SET NOCOUNT ON;
	SET LANGUAGE Spanish; 
    DECLARE @Count  INT =   0;
	DROP TABLE IF EXISTS #TempInstancias
	CREATE TABLE #TempInstancias
    (
		id int primary key not null identity(1,1),
		FechasLimiteElaboracion DATE,
        idEntregable INT,
        countIntancias INT NULL
    );
	CREATE NONCLUSTERED INDEX ix_tempTempInstancias ON #TempInstancias (FechasLimiteElaboracion);
	DROP TABLE IF EXISTS #GrupoUsuario
    CREATE TABLE #GrupoUsuario
    (
        IdUsuarioGrupo int
    );
	CREATE NONCLUSTERED INDEX ix_tempGrupoUsuario ON #GrupoUsuario (IdUsuarioGrupo);

	IF 0 < (SELECT COUNT(1)
			FROM
				dbo.AP_USUARIO	U (NOLOCK)
			JOIN
				dbo.AP_PERFILUSUARIO PU (NOLOCK)
				ON	U.UsuarioID = PU.UsuarioID
				AND	U.UsuarioID	=	@idUsuario
			JOIN
				dbo.AP_PERFIL	P (NOLOCK)
				ON	PU.PerfilID	=	P.IdPerfil
				AND	@IdContrato =	P.IdContrato
			JOIN
				dbo.AP_ROL	R (NOLOCK)
				ON	P.IdRol	=	R.IdRol
			WHERE
				LTRIM(R.Descripción) LIKE 'SASISOPA%' )
	BEGIN
		EXEC sp_ExtraeEntregablesFaltantesElaboracion_SASISOPA @IdContrato, @idUsuario
		RETURN
	END
    INSERT INTO #GrupoUsuario   (IdUsuarioGrupo)
    SELECT  IdGrupo
	FROM    dbo.EN_GruposUsuarios	(NOLOCK)
    WHERE   
        IdContrato  =   @IdContrato
        AND Activo  =   1
    UNION 
    SELECT UsuarioID
    FROM dbo.AP_USUARIO (NOLOCK)
    WHERE IsActivo = 1

    INSERT  INTO    #TempInstancias (FechasLimiteElaboracion,idEntregable)
    SELECT  
		IE.FechasLimiteElaboracion,
		CE.IdEntregable
   FROM 
		dbo.EN_InstanciasEntregable IE	(NOLOCK)
    JOIN    
		dbo.EN_ContratoEntregable   CE  (NOLOCK)
        ON  IE.IdContratoEntregable =	CE.IdContratoEntregable
        AND @IdContrato =	CE.IdContrato
	JOIN
		dbo.CO_Contrato	C	(NOLOCK)
		ON	CE.IdContrato	=	C.IdContrato
		AND	@IdContrato = C.IdContrato
		AND	IE.FechaCalculadaEntregaReg < DATEADD(YEAR, 5, GETDATE())
    JOIN    
		dbo.EN_Actividad    A	(NOLOCK)
        ON  IE.ActividadID  =   A.ActividadID
	JOIN #GrupoUsuario AS GU
		on A.idUsuario = GU.IdUsuarioGrupo
    JOIN 
		dbo.EN_Entregable ENT	(NOLOCK)
        ON  CE.IdEntregable =   Ent.IdEntregable
		AND ENT.BITJOA = 0
		AND ENT.IsActivo = 1
    LEFT JOIN   
		dbo.EN_ExcepcionesActividad EXAR
        ON  A.ActividadID   =   EXAR.ActividadIDExcepcion 
        AND IE.idInstanciaEntregable    =   EXAR.IdInstanciasEntregables 
		AND GU.IdUsuarioGrupo = EXAR.idUsuario
    WHERE  EXAR.IdInstanciasEntregables    IS NULL
            AND   A.EstadoID  =   10000
            AND   ENT.IsActivo    =   1
            AND   CE.Activo   =   1
            AND   IE.Activo   =   1
    GROUP   BY  IE.FechasLimiteElaboracion,
	    CE.IdEntregable


-------------------------
INSERT  INTO    #TempInstancias (FechasLimiteElaboracion,idEntregable)
    SELECT  
		IE.FechasLimiteElaboracion,
		CE.IdEntregable
   FROM 
		dbo.EN_InstanciasEntregable IE	(NOLOCK)
    JOIN    
		dbo.EN_ContratoEntregable   CE  (NOLOCK)
        ON  IE.IdContratoEntregable =	CE.IdContratoEntregable
        AND @IdContrato =	CE.IdContrato
	JOIN
		dbo.CO_Contrato	C	(NOLOCK)
		ON	CE.IdContrato	=	C.IdContrato
		AND	@IdContrato = C.IdContrato
		AND	IE.FechaCalculadaEntregaReg < DATEADD(YEAR, 5, GETDATE())
    JOIN    
		dbo.EN_Actividad    A	(NOLOCK)
        ON  IE.ActividadID  =   A.ActividadID
	JOIN #GrupoUsuario AS GU
		on A.idUsuario = GU.IdUsuarioGrupo
    JOIN 
		dbo.EN_Entregable ENT	(NOLOCK)
        ON  CE.IdEntregable =   Ent.IdEntregable
		AND ENT.BITJOA = 0
		AND ENT.IsActivo = 1
    LEFT JOIN   
		dbo.EN_ExcepcionesActividad EXAR
        ON  A.ActividadID   =   EXAR.ActividadIDExcepcion 
        AND IE.idInstanciaEntregable    =   EXAR.IdInstanciasEntregables 
		AND GU.IdUsuarioGrupo = EXAR.idUsuario
    WHERE  
        EXAR.IdInstanciasEntregables    IS NOT NULL
        AND EXAR.EstadoID   =   10000
        AND ENT.IsActivo    =   1
        AND CE.Activo   =   1
        AND IE.Activo   =   1  
    GROUP   BY  IE.FechasLimiteElaboracion,
	    CE.IdEntregable
-------------------------
    SELECT @Count = MAX(id)
    FROM #TempInstancias;

    SELECT IE.idInstanciaEntregable AS  idInstanciaEntregable,
        CE.IdEntregable  AS	IdEntregable,
        CE.IdContratoEntregable  AS  IdContratoEntregable,
        DocumentoEntregable,
        ISNULL(R.Regulador,'')   AS  Regulador,
        ISNULL( M.MarcoLegal,'') AS  MarcoLegal,
        IE.FechasLimiteElaboracion,
        IE.FechaCalculadaEntregaReg  AS  FechaEntregaRegulador,
        IE.FechasLimiteAprobacion,
        E.NombreEstado   AS  Estatus,
        ISNULL(F.FrecuenciaEntregable,'')    AS FrecuenciaEntregable,
        ISNULL(ET.Etapa,'')  AS  Etapa,
        ISNULL(EN.idRegulador,'')    AS  idRegulador,
        @Count AS countI,
       EN.Consecutivo,
        ISNULL(EN.Articulo,'') AS Articulo,
        CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
            ELSE ISNULL(FP.Nombre,'') 
        END     AS FocalPoint,
        CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
            ELSE ISNULL(AC.Nombre,'') 
        END     AS AccountableCompliance,
        CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
            ELSE ISNULL(ACC.Nombre,'')
        END   AS Accountable,
		ISNULL(P.NombreProceso+' - '+IPF .Descripcion,'')	AS  NombreProgramacionProcesos,

		ISNULL(EN.bitMostrarMensaje,0) as bitMostrarMensaje,
		CASE	ISNULL(EN.bitMostrarMensaje,0)
			WHEN	1
			THEN	DATEADD(MONTH,-1, IE.FechaCalculadaEntregaReg)
		ELSE
			IE.FechaCalculadaEntregaReg
		END	AS MesReportar,
		CASE 
			WHEN ISNULL(CEPIA.IdContratoEntregable,0) > 1
			THEN	1
		ELSE	0
		END	AS BitSasisopa,
		EN.Observaciones,
		CASE
				WHEN EN.BitAwareness = 1 THEN 'SI'
				ELSE 'NO'
			END AS TipoJOA
    FROM    
		#TempInstancias TI
    JOIN    
		dbo.EN_InstanciasEntregable	IE  (NOLOCK)
		ON  TI.FechasLimiteElaboracion  =   IE.FechasLimiteElaboracion
    JOIN    
		dbo.EN_ContratoEntregable   CE  (NOLOCK)
		ON  IE.IdContratoEntregable =   CE.IdContratoEntregable
        AND TI.idEntregable = CE.IdEntregable
        AND @IdContrato = CE.IdContrato
    JOIN    
		dbo.EN_Actividad A (NOLOCK)
		ON  IE.ActividadID  =   A.ActividadID
        AND 10000 = A.EstadoID
    JOIN    
		#GrupoUsuario   GU
		ON  A.idUsuario =   GU.IdUsuarioGrupo
    JOIN    
		dbo.EN_Estado   E (NOLOCK)
		ON  A.EstadoID  =   E.EstadoID
	JOIN   
		dbo.EN_Entregable EN  (NOLOCK)
		ON CE.IdEntregable  =   EN.IdEntregable
		AND 0 = EN.BITJOA
		AND 1 = EN.IsActivo 
    LEFT JOIN    
		dbo.CO_Regulador R  (NOLOCK)
		ON EN.IdRegulador   =   R.IdRegulador  
	LEFT    JOIN    
		dbo.EN_FrecuenciaEntregable F (NOLOCK)
		ON EN.IdFrecuenciaEntregable    =   F.IdFrecuenciaEntregable
    LEFT    JOIN    
		dbo.EN_Etapa ET (NOLOCK)
		ON EN.IdEtapa   =   ET.IdEtapa
    LEFT    JOIN    
		dbo.EN_MarcoLegal M (NOLOCK)
		ON EN.IdMarcoLegal  =   M.IdMarcoLegal
    LEFT    JOIN
        dbo.AP_USUARIO FP   (NOLOCK)    -- OBTENER NOMBRE DEL FOCAL POINT
		ON  CE.FocalPoint   =   FP.Usuario
    LEFT    JOIN
        dbo.AP_USUARIO AC    (NOLOCK)   -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
        ON  CE.AccountableCompliance    =   AC.Usuario
    LEFT    JOIN
        dbo.AP_USUARIO ACC   (NOLOCK)   -- OBTENER EL NOMBRE DEL ACCOUNTABLE
        ON  CE.Accountable  =   ACC.Usuario
	LEFT	JOIN
		dbo.EN_InstanciasEntregables_InstanciaActividad IEIA (NOLOCK)
		ON IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
	LEFT	JOIN
		dbo.EN_InstanciasActividades	IA (NOLOCK)
		ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
	LEFT JOIN 
		dbo.EN_InstanciasProcesosFecha	IPF (NOLOCK)
		ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
	LEFT JOIN 
		dbo.EN_Procesos	P (NOLOCK)
		ON	IPF.IdProceso	=	P.IdProceso
	LEFT	JOIN
		dbo.EN_ContratoEntregableProgramaImplementaAcciones CEPIA (NOLOCK)
		ON CE.IdContratoEntregable	=	CEPIA.IdContratoEntregable
    UNION

    -- LAS EXCEPCIONES QUE SE LE ASIGNACION AL USUARIO
    SELECT IE.idInstanciaEntregable AS idInstanciaEntregable,
        CE.IdEntregable AS IdEntregable,
        CE.IdContratoEntregable AS IdContratoEntregable,
        DocumentoEntregable,
        ISNULL(R.Regulador,'') AS Regulador,
        ISNULL( M.MarcoLegal,'') AS MarcoLegal,
        IE.FechasLimiteElaboracion,
        IE.FechaCalculadaEntregaReg AS FechaEntregaRegulador,
		IE.FechasLimiteAprobacion,
		E.NombreEstado AS Estatus,
        ISNULL(f.FrecuenciaEntregable,'') AS FrecuenciaEntregable,
        ISNULL(Et.Etapa,'') as Etapa,
        ISNULL(EN.idRegulador,'')as idRegulador,
	    @Count AS countI,
        EN.Consecutivo,
        ISNULL(EN.Articulo,'') AS Articulo,
        CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
            ELSE ISNULL(FP.Nombre,'') 
        END     AS FocalPoint,
	    CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
            ELSE ISNULL(AC.Nombre,'') 
        END     AS AccountableCompliance,
        CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
            ELSE ISNULL(ACC.Nombre,'')
        END     AS Accountable,
		ISNULL(P.NombreProceso+' - '+IPF .Descripcion,'')	AS  NombreProgramacionProcesos  ,

		ISNULL(EN.bitMostrarMensaje,0) as bitMostrarMensaje,
		CASE	ISNULL(EN.bitMostrarMensaje,0)
			WHEN	1
			THEN	DATEADD(MONTH,-1, IE.FechaCalculadaEntregaReg)
		ELSE
			IE.FechaCalculadaEntregaReg
		END	AS MesReportar,
		CASE 
			WHEN ISNULL(CEPIA.IdContratoEntregable,0) > 1
			THEN	1
		ELSE	0
		END	AS BitSasisopa,
		EN.Observaciones,	
		CASE
				WHEN EN.BitAwareness = 1 THEN 'SI'
				ELSE 'NO'
			END AS TipoJOA
    FROM    
		#TempInstancias TI
    JOIN    
		dbo.EN_InstanciasEntregable IE (NOLOCK)
        ON TI.FechasLimiteElaboracion   =   IE.FechasLimiteElaboracion
    JOIN    
		dbo.EN_ContratoEntregable   CE  (NOLOCK)
	    ON  IE.IdContratoEntregable = CE.IdContratoEntregable
        AND TI.idEntregable =   CE.IdEntregable
        AND @IdContrato = CE.IdContrato
    JOIN    
		dbo.EN_ExcepcionesActividad EXACT  (NOLOCK)
        ON  IE.idInstanciaEntregable    =   EXACT.IdInstanciasEntregables
        AND 10000 = EXACT.EstadoID 
    JOIN    
		#GrupoUsuario   GU
		ON  EXACT.idUsuario =   GU.IdUsuarioGrupo
    JOIN    
		dbo.EN_Estado   E (NOLOCK)
        ON  EXACT.EstadoID  =   E.EstadoID
    JOIN    
		dbo.EN_Entregable   EN  (NOLOCK)
        ON CE.IdEntregable = EN.IdEntregable
		AND 0 = EN.BITJOA 
		AND 1 = EN.IsActivo
    LEFT    JOIN    
		dbo.EN_FrecuenciaEntregable F (NOLOCK)
        ON  EN.IdFrecuenciaEntregable   =   F.IdFrecuenciaEntregable
    LEFT    JOIN    
		dbo.CO_Regulador    R (NOLOCK)
        ON  EN.IdRegulador  =   R.IdRegulador 
    LEFT    JOIN    
		dbo.EN_Etapa    ET (NOLOCK)
        ON  EN.IdEtapa  =   ET.IdEtapa
    LEFT    JOIN    
		dbo.EN_MarcoLegal   M (NOLOCK)
		ON  EN.IdMarcoLegal =   M.IdMarcoLegal
    LEFT    JOIN
        dbo.AP_USUARIO FP  (NOLOCK)     -- OBTENER NOMBRE DEL FOCAL POINT
        ON  CE.FocalPoint   =   FP.Usuario
    LEFT    JOIN
        dbo.AP_USUARIO AC   (NOLOCK)    -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
        ON  CE.AccountableCompliance    =   AC.Usuario
    LEFT    JOIN
        dbo.AP_USUARIO ACC  (NOLOCK)    -- OBTENER EL NOMBRE DEL ACCOUNTABLE
        ON  CE.Accountable  =   ACC.Usuario
	LEFT	JOIN
		dbo.EN_InstanciasEntregables_InstanciaActividad IEIA (NOLOCK)
		ON IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
	LEFT	JOIN
		dbo.EN_InstanciasActividades	IA (NOLOCK)
		ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
	LEFT JOIN 
		dbo.EN_InstanciasProcesosFecha	IPF (NOLOCK)
		ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
	LEFT JOIN 
		dbo.EN_Procesos	P (NOLOCK)
		ON	IPF.IdProceso	=	P.IdProceso
	LEFT	JOIN
		dbo.EN_ContratoEntregableProgramaImplementaAcciones CEPIA (NOLOCK)
		ON CE.IdContratoEntregable	=	CEPIA.IdContratoEntregable
    ORDER BY    IE.FechasLimiteElaboracion  ASC;
END