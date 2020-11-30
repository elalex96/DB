CREATE PROCEDURE [dbo].[sp_EN_ExtraeReporteEntregablesSasisopa]-- 3,10061,'2020-06-01','2021-01-31'
    @IdContrato INT,
    @idUsuario INT,
	@FechaInicio DATETIME,
	@FechaFin	DATETIME
AS
BEGIN
    SET NOCOUNT ON;
	SET LANGUAGE Spanish; 
	CREATE TABLE #AccionesEntregables(IdInstanciaEntregable INT,
									  Contrato VARCHAR(250),
									  NombrePrograma VARCHAR(1500),
									  Politica VARCHAR(1500),
									  Elemento VARCHAR(1500),
									  ACCION VARCHAR(1500),
									  FechaEstimadaEntregaRegulador DATETIME,
									  TieneArchivos VARCHAR(2),
									  CantidadArchivos INT,
									  URL VARCHAR(3000),
									  Comentarios VARCHAR(MAX),
									  OrdenPolitica	INT,
									  OrdenElemento	INT
									  );

	CREATE TABLE #DocumentosInstancias(IdInstanciaEntregable INT,
									  TieneArchivos VARCHAR(2),
									  CantidadArchivos INT,
									  FechaRealEvidencia	DATETIME
									  );

	CREATE TABLE #EntregableVersion
	(
		IdInstanciaEntregable INT,
		IdVersion			INT
	)

	CREATE TABLE #Comentarios
	(
		IdInstanciaEntregable INT,
		Comentario	VARCHAR(8000)
	)

	CREATE TABLE #ComentariosFinales
	(
		IdInstanciaEntregable INT,
		Comentario	VARCHAR(8000)
	)

-- SE OBTIENE LA ULTIMA VERSION DE CADA INSTANCIA PARA BUSCAR LOS DOCUMENTOS SOBRE ESA VERSION	
	INSERT INTO #EntregableVersion
	(
		IdInstanciaEntregable,
		IdVersion
	)
	SELECT
		IE.IdInstanciaEntregable,
		MAX(DV.N_version)
	FROM
		CO_ProgramaImplementa	CPI
	JOIN
		CO_Contrato	C	(NOLOCK)
		ON	CPI.IdContrato	=	C.IdContrato
		AND C.IdContrato	=	@IdContrato
		AND CPI.Activo	=	1
	JOIN
		CO_ProgramaImplementaPoliticas	PIP	(NOLOCK)
		ON	CPI.IdProgramaImplementa	=	PIP.IdProgramaImplementa
	JOIN
		CO_ProgramaImplementaElemento	PIE	(NOLOCK)
		ON	PIP.IdProgramaImplementaPolitica = PIE.IdProgramaImplementaPolitica
	JOIN
		CO_ProgramaImplementaAcciones	PIA	(NOLOCK)
		ON	PIE.IdProgramaImplementaElemento = PIA.IdProgramaImplementaElemento
	JOIN
		EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC	(NOLOCK)
		ON	PIA.IdProgramaImplementaAccion = ENT_ACC.IdProgramaImplementaAccion
	JOIN
		EN_ContratoEntregable	CE	(NOLOCK)
		ON	ENT_ACC.IdContratoEntregable	=	CE.IdContratoEntregable
		AND	ISNULL(ENT_ACC.Activo,1)	=	1
		AND	ISNULL(CE.Activo,1)	=	1
	JOIN
		EN_InstanciasEntregable	IE (NOLOCK)
		ON	CE.IdContratoEntregable = IE.IdContratoEntregable
		AND	ISNULL(IE.Activo,1)	=	1
		AND	IE.FechaCalculadaEntregaReg BETWEEN @FechaInicio AND @FechaFin
	JOIN
		EN_DocumentoVersion	DV	(NOLOCK)
		ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
	GROUP BY
		IE.IdInstanciaEntregable

	-- SE INSERTAN LOS COMENTARIOS DE LOS DOCUMENTOS QUE TIENEN ARCHIVOS
	INSERT INTO #Comentarios
	(
		IdInstanciaEntregable,
		Comentario
	)
	SELECT
		EV.IdInstanciaEntregable,
		ISNULL(ED.Comentario,'')
	FROM
		#EntregableVersion	EV
	JOIN
		EN_DocumentoVersion	DV
		ON	EV.IdInstanciaEntregable	=	DV.idInstanciaEntregable
		AND EV.IdVersion	=	DV.N_version
	JOIN
		EN_EntregableDocumento	ED
		ON	DV.DocumentoEntregableId	=	ED.DocumentoEntregableId
		AND	ED.Activo = 1

	INSERT INTO #ComentariosFinales
	(
		IdInstanciaEntregable,
		Comentario
	)
	SELECT
		IdInstanciaEntregable,
		STUFF(( SELECT  ', '+ Comentario FROM #Comentarios A
				WHERE B.IdInstanciaEntregable = A.IdInstanciaEntregable FOR XML PATH('')),1 ,1, '')  Members
	FROM
		#Comentarios B
	GROUP BY
		IdInstanciaEntregable


	INSERT INTO #AccionesEntregables(IdInstanciaEntregable,
									  Contrato ,
									  NombrePrograma ,
									  Politica,
									  Elemento,
									  ACCION,
									  FechaEstimadaEntregaRegulador ,
									  URL,
									  TieneArchivos,
									  CantidadArchivos,
									  Comentarios,
									  OrdenPolitica,
									  OrdenElemento
									  )
	
	SELECT DISTINCT
		IE.idInstanciaEntregable,
		C.NumeroContrato	AS Contrato,
		PIT.Descripcion	AS NombrePrograma,
		PIP.Descripcion AS Politica, 
		PIE.Descripcion AS Elemento, 
		REPLACE(REPLACE(LTRIM(RTRIM(PIA.Descripcion +' - '+ LTRIM(IE.idInstanciaEntregable))),CHAR(9),''),CHAR(13),'')	AS ACCION,
		ISNULL(IE.FechaRealEntregaRegulador, IE.FechaCalculadaEntregaReg)	AS	FechaEstimadaEntregaRegulador,
		CASE HALT.ContieneURLRepositorio
			WHEN 1
			THEN
				HALT.URLRepositorio
				ELSE
				''
		END AS URL,
		'NO',
		 0,
		CF.Comentario + '' + HALT.Comentario,
		 N.Cardinal,
--		 0
--		 CONVERT(INT,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(SUBSTRING(PIE.Descripcion,1,CHARINDEX('.',PIE.Descripcion)),'"',''),'-',''),'.',''))))
		CONVERT(INT,LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(SUBSTRING(PIE.Descripcion,1,CHARINDEX(' ',PIE.Descripcion)),'"',''),'-',''),'.',''))))
	FROM
		CO_ProgramaImplementa	CPI
	JOIN
		CO_Contrato	C	(NOLOCK)
		ON	CPI.IdContrato	=	C.IdContrato
		AND C.IdContrato	=	@IdContrato
	JOIN
		CO_ProgramaImplementacionTipo	PIT
		ON	CPI.IdTipoPrograma = PIT.Id
		AND CPI.Activo	=	1
		AND CPI.IdContrato	=	PIT.IdContrato
	JOIN
		CO_ProgramaImplementaPoliticas	PIP
		ON	CPI.IdProgramaImplementa	=	PIP.IdProgramaImplementa
	JOIN
		CO_ProgramaImplementaElemento	PIE
		ON	PIP.IdProgramaImplementaPolitica = PIE.IdProgramaImplementaPolitica
	JOIN
		CO_ProgramaImplementaAcciones	PIA
		ON	PIE.IdProgramaImplementaElemento = PIA.IdProgramaImplementaElemento
	JOIN
		EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC
		ON	PIA.IdProgramaImplementaAccion = ENT_ACC.IdProgramaImplementaAccion
	LEFT JOIN
		EN_ContratoEntregable	CE	(NOLOCK)
		ON	ENT_ACC.IdContratoEntregable	=	CE.IdContratoEntregable
		AND	ISNULL(ENT_ACC.Activo,1)	=	1
		AND	ISNULL(CE.Activo,1)	=	1
	LEFT JOIN
		EN_InstanciasEntregable	IE (NOLOCK)
		ON	CE.IdContratoEntregable = IE.IdContratoEntregable
		AND	ISNULL(IE.Activo,1)	=	1
	LEFT JOIN
		#EntregableVersion	EV
		ON	IE.idInstanciaEntregable	=	EV.IdInstanciaEntregable
	LEFT JOIN
		EN_HistorialAprobacionesLineaTiempo	HALT	(NOLOCK)
		ON	IE.idInstanciaEntregable	=	HALT.idInstanciaEntregable
		AND	EV.IdVersion	=	HALT.IdLineaTiempo
		AND HALT.idTipoOperacion = 2
	LEFT JOIN
		AP_Numeros	N	(NOLOCK)
		ON	LTRIM(RTRIM(SUBSTRING(PIP.Descripcion,1,CHARINDEX('.',PIP.Descripcion)-1)))	=	N.Romano
	LEFT JOIN
		#ComentariosFinales	CF
		ON	IE.idInstanciaEntregable = CF.IdInstanciaEntregable
	WHERE
		PIT.IdContrato	=	@IdContrato
		AND
		IE.FechaCalculadaEntregaReg BETWEEN @FechaInicio AND @FechaFin
	ORDER BY
			PIT.Descripcion,
			PIP.Descripcion, 
			PIE.Descripcion,
			REPLACE(REPLACE(LTRIM(RTRIM(PIA.Descripcion +' - '+ LTRIM(IE.idInstanciaEntregable))),CHAR(9),''),CHAR(13),''),
			ISNULL(IE.FechaRealEntregaRegulador, IE.FechaCalculadaEntregaReg);


	--Documentos de las instancias

	INSERT INTO #DocumentosInstancias(IdInstanciaEntregable ,
									  TieneArchivos,
									  CantidadArchivos,
									  FechaRealEvidencia
									  )
	SELECT	
			AE.IdInstanciaEntregable,
			'SI',
			COUNT(1),
			MIN(ISNULL(ED.FechaRealEvidencia,'19000101'))
	FROM 
		#AccionesEntregables	AE
	JOIN
		EN_HistorialAprobacionesLineaTiempo	FINR	(NOLOCK)
		ON	AE.idInstanciaEntregable	=	FINR.idInstanciaEntregable
		AND FINR.idTipoOperacion = 4
	JOIN
		EN_DocumentoVersion	DV	(NOLOCK)
		ON	AE.idInstanciaEntregable	=	DV.idInstanciaEntregable
--		AND	AE.IdVersion	=	DV.N_version
		AND DV.Activo = 1
	LEFT JOIN
		EN_EntregableDocumento	ED
		ON	DV.DocumentoEntregableId	=	ED.DocumentoEntregableId
	GROUP BY AE.IdInstanciaEntregable


	--Modifica la tabla principal a las instancias que contienen archivos

	UPDATE AE
		SET	AE.TieneArchivos =	DI.TieneArchivos,
			AE.CantidadArchivos = DI.CantidadArchivos,
			AE.FechaEstimadaEntregaRegulador	=	CASE WHEN DI.FechaRealEvidencia IS NOT NULL AND DI.FechaRealEvidencia > '19000101' 
													THEN DI.FechaRealEvidencia ELSE AE.FechaEstimadaEntregaRegulador END
	FROM	
		#AccionesEntregables	AE
	JOIN
		#DocumentosInstancias DI
		ON AE.idInstanciaEntregable	=	DI.idInstanciaEntregable



	--Select final
	SELECT 
		Contrato,
		NombrePrograma,
		Politica,
		Elemento,
		ACCION,
		FechaEstimadaEntregaRegulador,
		TieneArchivos,
		CantidadArchivos,
		URL,
		ISNULL(Comentarios,'') AS Comentarios
	FROM 
		#AccionesEntregables
	ORDER BY NombrePrograma,
			OrdenPolitica,
			Politica,
--			Elemento,
			OrdenElemento,
			ACCION,
			FechaEstimadaEntregaRegulador

END
