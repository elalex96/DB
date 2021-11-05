CREATE PROCEDURE [dbo].[sp_ExtraeEntregablesFaltantesElaboracion_SASISOPA] --3,10061
    @IdContrato INT,
    @idUsuario INT
AS
BEGIN
    -- =============================================
    -- Author:  Reyna Olvera
    -- Create date: 2018-11-08
    -- Description: 
    -- 20190510 BAAC    Se modifica consulta de las fechas proximas para no considerar el id de la instancia
	-- 20210908	BAAC	Se modifica para considerar siempre los entregables pendientes y los de los proximos 6 meses
	-- 20211007	BAAC	Se modifica para considerar los entregbales de los proximos 5 años
    -- =============================================
		    -- =============================================
    -- Author:  Daniel AC
    -- Create date: 2020-05-11
    -- Description: Se agregar NOLOCKS en las tablas que tienen mas recurrencia y referencias al objero dbo
    -- =============================================
    SET NOCOUNT ON;
	SET LANGUAGE Spanish; 
    DECLARE @Count  INT =   0;

    CREATE TABLE #TempInstancias
    (

     id INT PRIMARY KEY IDENTITY(1, 1),
        FechasLimiteElaboracion DATE,
        idEntregable INT,
        countIntancias INT NULL
    );

    CREATE TABLE #GrupoUsuario
    (
        id INT PRIMARY KEY IDENTITY(1, 1),
        IdUsuarioGrupo int
	);

	CREATE TABLE #Area
  (
	IdArea	INT
  )

  INSERT INTO #Area
  SELECT IdArea
  FROM dbo.EN_Area (NOLOCK)
  WHERE idContrato = @IdContrato
  AND (NombreArea LIKE '%HSSE%' OR NombreArea LIKE '%HSE%')
  GROUP BY  IdArea

    INSERT INTO #GrupoUsuario   (IdUsuarioGrupo

)
    SELECT  IdGrupo 
    FROM    dbo.EN_GruposUsuarios (NOLOCK)
    WHERE   
        IdContrato  =   @IdContrato
        AND Activo  =   1
    UNION 
    SELECT UsuarioID
    FROM dbo.AP_USUARIO
    WHERE IsActivo = 1

    INSERT  INTO    #TempInstancias (FechasLimiteElaboracion,idEntregable)
    SELECT  
		IE.FechasLimiteElaboracion,
		CE.IdEntregable
   FROM 
		dbo.EN_InstanciasEntregable IE	(NOLOCK)
    JOIN    
		dbo.EN_ContratoEntregable   CE  (NOLOCK)
        ON  IE.IdContratoEntregable =   CE.IdContratoEntregable
        AND CE.IdContrato   =   @IdContrato
		AND   CE.Activo   =   1
        AND   IE.Activo   =   1
		AND IE.FechaCalculadaEntregaReg < DATEADD(YEAR,5,GETDATE())
	JOIN
		#Area	AREA
		ON	CE.IdArea	=	AREA.IdArea
    JOIN    
		dbo.EN_Actividad    A	(NOLOCK)
        ON  IE.ActividadID  =   A.ActividadID
    JOIN 
		dbo.EN_Entregable ENT (NOLOCK)
        ON  CE.IdEntregable =   Ent.IdEntregable
		AND ENT.BITJOA = 0
		AND   ISNULL(ENT.IsActivo,0)    =   1
	JOIN
		dbo.CO_Contrato	C (NOLOCK)
		ON	CE.IdContrato	=	C.IdContrato
		AND	C.IdContrato	=	@IdContrato
    LEFT JOIN 
		dbo.EN_MarcoLegal ML  (NOLOCK)
        ON  ENT.IdMarcoLegal    =   ML.IdMarcoLegal
    LEFT JOIN   
		dbo.EN_ExcepcionesActividad EXAR (NOLOCK)
        ON  A.ActividadID   =   EXAR.ActividadIDExcepcion 
        AND IE.idInstanciaEntregable    =   EXAR.IdInstanciasEntregables 
    
WHERE  
		IE.FechaCalculadaEntregaReg < DATEADD(YEAR,5,GETDATE())
		AND ((A.idUsuario IN (SELECT IdUsuarioGrupo FROM #GrupoUsuario)
            AND   EXAR.IdInstanciasEntregables    IS NULL
            AND   A.EstadoID  =   10000
          )
	 OR (
        EXAR.idUsuario   IN (SELECT IdUsuarioGrupo FROM #GrupoUsuario)
        AND EXAR.IdInstanciasEntregables    IS NOT NULL
        AND EXAR.EstadoID   =   10000   ) )
        AND CE.IdContrato   =   @IdContrato
    GROUP   BY  IE.FechasLimiteElaboracion,
	    CE.IdEntregable

    SELECT @Count = MAX(id)
    FROM #TempInstancias;

    SELECT IE.idInstanciaEntregable AS  idInstanciaEntregable,
        CE.IdEntregable  AS  IdEntregable,
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
        END  AS Accountable,
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
		EN.Observaciones  

    FROM    
		#TempInstancias TI
    JOIN    
		dbo.EN_InstanciasEntregable	IE  (NOLOCK)
		ON  TI.FechasLimiteElaboracion  =   IE.FechasLimiteElaboracion
    JOIN    
		dbo.EN_ContratoEntregable   CE (NOLOCK)
		ON  IE.IdContratoEntregable =   CE.IdContratoEntregable
        AND TI.idEntregable = CE.IdEntregable
        AND CE.IdContrato = @IdContrato
    JOIN    
		dbo.EN_Actividad A (NOLOCK)
		ON  IE.ActividadID  =   A.ActividadID
        AND A.EstadoID  =   10000
    JOIN    
		#GrupoUsuario   GU
		ON  A.idUsuario =   GU.IdUsuarioGrupo
    JOIN    
		dbo.EN_Estado   E (NOLOCK)
		ON  A.EstadoID  =   E.EstadoID
	JOIN   
		dbo.EN_Entregable EN (NOLOCK)
		ON CE.IdEntregable  =   EN.IdEntregable
		AND EN.BITJOA = 0
    LEFT    JOIN    
		dbo.CO_Regulador R (NOLOCK)
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
        dbo.AP_USUARIO FP      (NOLOCK) -- OBTENER NOMBRE DEL FOCAL POINT
		ON  CE.FocalPoint   =   FP.Usuario
    LEFT    JOIN
        dbo.AP_USUARIO AC      (NOLOCK) -- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
        ON  CE.AccountableCompliance    =   AC.Usuario
    LEFT    JOIN
        dbo.AP_USUARIO ACC     (NOLOCK) -- OBTENER EL NOMBRE DEL ACCOUNTABLE
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
            ELSE	ISNULL(AC.Nombre,'') 
        END     AS AccountableCompliance,
       CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
            ELSE ISNULL(ACC.Nombre,'')
        END     AS Accountable,
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
		EN.Observaciones  
    FROM    
		#TempInstancias TI
    JOIN    
		dbo.EN_InstanciasEntregable IE (NOLOCK)
        ON TI.FechasLimiteElaboracion   =   IE.FechasLimiteElaboracion
    JOIN    
		dbo.EN_ContratoEntregable   CE (NOLOCK)
	    ON  IE.IdContratoEntregable =   CE.IdContratoEntregable
        AND TI.idEntregable =   CE.IdEntregable
        AND CE.IdContrato   =   @IdContrato
    JOIN    
		dbo.EN_ExcepcionesActividad EXACT (NOLOCK)
        ON  IE.idInstanciaEntregable    =   EXACT.IdInstanciasEntregables
        AND EXACT.EstadoID  =   10000
    JOIN    
		#GrupoUsuario   GU
		ON  EXACT.idUsuario =   GU.IdUsuarioGrupo
    JOIN    
		dbo.EN_Estado   E (NOLOCK)
        ON  EXACT.EstadoID  =   E.EstadoID
    JOIN    
		dbo.EN_Entregable   EN (NOLOCK)
        ON CE.IdEntregable = EN.IdEntregable
		AND EN.BITJOA = 0
    LEFT  JOIN    
		dbo.EN_FrecuenciaEntregable F (NOLOCK)
   ON  EN.IdFrecuenciaEntregable   =   F.IdFrecuenciaEntregable
    LEFT    JOIN    
		dbo.CO_Regulador    R (NOLOCK)
        ON  EN.IdRegulador  =   R.IdRegulador 
    LEFT    JOIN
		EN_Etapa    ET (NOLOCK)  
      ON  EN.IdEtapa  =   ET.IdEtapa
    LEFT    JOIN    
		dbo.EN_MarcoLegal   M (NOLOCK)
		ON  EN.IdMarcoLegal =   M.IdMarcoLegal
    LEFT    JOIN
        dbo.AP_USUARIO FP       (NOLOCK)-- OBTENER NOMBRE DEL FOCAL POINT
        ON  CE.FocalPoint   =   FP.Usuario
    LEFT JOIN
        dbo.AP_USUARIO AC       (NOLOCK)-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
        ON  CE.AccountableCompliance    =   AC.Usuario
    LEFT    JOIN
        AP_USUARIO ACC      (NOLOCK)-- OBTENER EL NOMBRE DEL ACCOUNTABLE
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
