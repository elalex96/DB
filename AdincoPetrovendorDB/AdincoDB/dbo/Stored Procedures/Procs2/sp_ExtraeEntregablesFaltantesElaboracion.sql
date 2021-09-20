USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[sp_ExtraeEntregablesFaltantesElaboracion]    Script Date: 16/09/2021 04:29:44 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ExtraeEntregablesFaltantesElaboracion]-- 3,10061
    @IdContrato INT,
    @idUsuario INT
AS
BEGIN--285718
    -- =============================================
    -- Author:  Reyna Olvera
    -- Create date: 2018-11-08
    -- Description: 
    -- 20190510 BAAC    Se modifica consulta de las fechas proximas para no considerar el id de la instancia
    -- =============================================
    SET	NOCOUNT	ON;
	SET LANGUAGE Spanish; 
    DECLARE	@Count	INT	=	0;

--IF @idUsuario IN (3, 5, 10437, 10536, 10150, 10751, 10765)
--BEGIN
--	EXEC sp_ExtraeEntregablesFaltantesElaboracion_Shell @IdContrato, @idUsuario
--	RETURN
--END

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

	INSERT INTO	#GrupoUsuario	(IdUsuarioGrupo)
	SELECT	IdGrupo	
	FROM	EN_GruposUsuarios
	WHERE	IdUsuario	=	@idUsuario
		AND IdContrato	=	@IdContrato
		AND	Activo	=	1
	UNION 
	SELECT @idUsuario
	
   INSERT	INTO	#TempInstancias	(FechasLimiteElaboracion,idEntregable)
  
	SELECT	MIN(IE.FechasLimiteElaboracion),	CE.IdEntregable
 
   FROM	EN_InstanciasEntregable	IE
    
	JOIN	EN_ContratoEntregable	CE	
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
		AND	CE.IdContrato	=	@IdContrato

    JOIN	dbo.EN_Actividad	A
		ON	IE.ActividadID	=	A.ActividadID

    JOIN dbo.EN_Entregable ENT 
		ON	CE.IdEntregable	=	Ent.IdEntregable
		AND ENT.BITJOA = 0

    LEFT JOIN dbo.EN_MarcoLegal	ML 
		ON	ENT.IdMarcoLegal	=	ML.IdMarcoLegal

    LEFT JOIN	dbo.EN_ExcepcionesActividad	EXAR
        ON	A.ActividadID	=	EXAR.ActividadIDExcepcion 
        AND	IE.idInstanciaEntregable	=	EXAR.IdInstanciasEntregables 

    WHERE (	        A.idUsuario	IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	@idUsuario
              AND	EXAR.IdInstanciasEntregables	IS NULL
              AND	A.EstadoID	=	10000
              AND	ENT.IsActivo	=	1
              AND	CE.Activo	=	1
              AND	IE.Activo	=	1
          )
          OR (
				EXAR.idUsuario		IN (SELECT IdUsuarioGrupo	FROM	 #GrupoUsuario)--	=	@idUsuario 
            AND	EXAR.IdInstanciasEntregables	IS NOT NULL
            AND	EXAR.EstadoID	=	10000
            AND	ENT.IsActivo	=	1
            AND	CE.Activo	=	1
            AND	IE.Activo	=	1	) 
			AND	CE.IdContrato	=	@IdContrato
    GROUP	BY	CE.IdEntregable;




    SELECT @Count = MAX(id)
    FROM #TempInstancias;

    SELECT IE.idInstanciaEntregable	AS	idInstanciaEntregable,
           CE.IdEntregable	AS	IdEntregable,
           CE.IdContratoEntregable	AS	IdContratoEntregable,
           DocumentoEntregable	AS DocumentoEntregable,  
           ISNULL(R.Regulador,'')	AS	Regulador,
           ISNULL( M.MarcoLegal,'')	AS	MarcoLegal,
           IE.FechasLimiteElaboracion,
           IE.FechaCalculadaEntregaReg	AS	FechaEntregaRegulador,
           IE.FechasLimiteAprobacion,
           E.NombreEstado	AS	Estatus,
           ISNULL(F.FrecuenciaEntregable,'')	AS	FrecuenciaEntregable,
           ISNULL(ET.Etapa,'')	AS	Etapa,
           ISNULL(EN.idRegulador,'')	AS	idRegulador,
           @Count AS countI,
           EN.Consecutivo,
		   ISNULL(EN.Articulo,'') AS Articulo,
		   CASE WHEN FP.Nombre IS NULL THEN ISNULL(CE.FocalPoint,'')
				ELSE ISNULL(FP.Nombre,'') 
			END		AS FocalPoint,
			CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
				ELSE ISNULL(AC.Nombre,'') 
			END		AS AccountableCompliance,
			CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
				ELSE ISNULL(ACC.Nombre,'')
			END		AS Accountable,
			ISNULL(P.NombreProceso+' - '+IPF .Descripcion,'')	AS  NombreProgramacionProcesos,

			ISNULL(EN.bitMostrarMensaje,0) as bitMostrarMensaje,
			CASE	ISNULL(EN.bitMostrarMensaje,0)
				WHEN	1
				THEN		DATEADD(MONTH,-1, IE.FechaCalculadaEntregaReg)
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
    FROM	#TempInstancias	TI
    JOIN	EN_InstanciasEntregable	IE	
	ON	TI.FechasLimiteElaboracion	=	IE.FechasLimiteElaboracion

    JOIN	EN_ContratoEntregable	CE 
	ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
			AND TI.idEntregable = CE.IdEntregable
			AND CE.IdContrato =	@IdContrato

    JOIN	dbo.EN_Actividad A
	ON	IE.ActividadID	=	A.ActividadID
			AND	A.EstadoID	=	10000

	JOIN	#GrupoUsuario	GU
	ON	A.idUsuario	=	GU.IdUsuarioGrupo

    JOIN	dbo.EN_Estado	E
	ON	A.EstadoID	=	E.EstadoID

    JOIN	EN_Entregable EN 
	ON CE.IdEntregable	=	EN.IdEntregable
		AND EN.BITJOA = 0

    LEFT	JOIN	dbo.CO_Regulador R 
	ON EN.IdRegulador	=	R.IdRegulador

    LEFT	JOIN	dbo.EN_FrecuenciaEntregable F 
	ON EN.IdFrecuenciaEntregable	=	F.IdFrecuenciaEntregable

    LEFT	JOIN	EN_Etapa ET 
	ON EN.IdEtapa	=	ET.IdEtapa

    LEFT	JOIN	dbo.EN_MarcoLegal M 
	ON EN.IdMarcoLegal	=	M.IdMarcoLegal
	LEFT	JOIN
		AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
		ON	CE.FocalPoint	=	FP.Usuario
	LEFT	JOIN
		AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
		ON	CE.AccountableCompliance	=	AC.Usuario
	LEFT	JOIN
		AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
		ON	CE.Accountable	=	ACC.Usuario
    
	LEFT	JOIN
			EN_InstanciasEntregables_InstanciaActividad IEIA
			ON IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
	LEFT	JOIN
			EN_InstanciasActividades	IA
			ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
	LEFT JOIN 
			EN_InstanciasProcesosFecha	IPF
			ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
	LEFT JOIN 
			EN_Procesos	P
			ON	IPF.IdProceso	=	P.IdProceso
	LEFT	JOIN
		EN_ContratoEntregableProgramaImplementaAcciones CEPIA
		ON CE.IdContratoEntregable	=	CEPIA.IdContratoEntregable
    
    UNION
	-- LAS EXCEPCIONES QUE SE LE ASIGNACION AL USUARIO
    SELECT IE.idInstanciaEntregable AS idInstanciaEntregable,
           CE.IdEntregable AS IdEntregable,
           CE.IdContratoEntregable AS IdContratoEntregable,
           DocumentoEntregable AS DocumentoEntregable,  
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
			END		AS FocalPoint,
			CASE WHEN AC.Nombre IS NULL THEN ISNULL(CE.AccountableCompliance,'')
				ELSE ISNULL(AC.Nombre,'') 
			END		AS AccountableCompliance,
			CASE WHEN ACC.Nombre IS NULL THEN ISNULL(CE.Accountable,'')
				ELSE ISNULL(ACC.Nombre,'')
			END		AS Accountable,
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
    FROM	#TempInstancias	TI
    JOIN	EN_InstanciasEntregable	IE 
		ON TI.FechasLimiteElaboracion	=	IE.FechasLimiteElaboracion

    JOIN	EN_ContratoEntregable	CE 
		ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
        AND	TI.idEntregable	=	CE.IdEntregable
        AND	CE.IdContrato	=	@IdContrato

    JOIN	EN_ExcepcionesActividad	EXACT 
		ON	IE.idInstanciaEntregable	=	EXACT.IdInstanciasEntregables
        AND EXACT.EstadoID	=	10000
        

	JOIN	#GrupoUsuario	GU
	ON	EXACT.idUsuario	=	GU.IdUsuarioGrupo

    JOIN	dbo.EN_Estado	E
		ON	EXACT.EstadoID	=	E.EstadoID

    JOIN	EN_Entregable	EN 
		ON CE.IdEntregable = EN.IdEntregable
		AND EN.BITJOA = 0

    LEFT	JOIN	dbo.EN_FrecuenciaEntregable	F 
		ON	EN.IdFrecuenciaEntregable	=	F.IdFrecuenciaEntregable


    LEFT	JOIN	dbo.CO_Regulador	R 
		ON	EN.IdRegulador	=	R.IdRegulador 
	  
    LEFT	JOIN	EN_Etapa	ET 
		ON	EN.IdEtapa	=	ET.IdEtapa

    LEFT	JOIN	dbo.EN_MarcoLegal	M 
	ON	EN.IdMarcoLegal	=	M.IdMarcoLegal
	LEFT	JOIN
		AP_USUARIO FP		-- OBTENER NOMBRE DEL FOCAL POINT
		ON	CE.FocalPoint	=	FP.Usuario
	LEFT	JOIN
		AP_USUARIO AC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE COMPLIANCE
		ON	CE.AccountableCompliance	=	AC.Usuario
	LEFT	JOIN
		AP_USUARIO ACC		-- OBTENER EL NOMBRE DEL ACCOUNTABLE
		ON	CE.Accountable	=	ACC.Usuario

	LEFT	JOIN
			EN_InstanciasEntregables_InstanciaActividad IEIA
			ON IE.idInstanciaEntregable	=	IEIA.idInstanciaEntregable
	LEFT	JOIN
			EN_InstanciasActividades	IA
			ON	IEIA.idInstanciaActividad	=	IA.idInstanciaActividad
	LEFT JOIN 
			EN_InstanciasProcesosFecha	IPF
			ON	IA.IdInstanciasProcesos	=	IPF.IdInstanciasProcesos
	LEFT JOIN 
			EN_Procesos	P
			ON	IPF.IdProceso	=	P.IdProceso
	LEFT	JOIN
		EN_ContratoEntregableProgramaImplementaAcciones CEPIA
		ON CE.IdContratoEntregable	=	CEPIA.IdContratoEntregable

	ORDER BY	
		IE.FechasLimiteElaboracion	ASC;
  
    END;


