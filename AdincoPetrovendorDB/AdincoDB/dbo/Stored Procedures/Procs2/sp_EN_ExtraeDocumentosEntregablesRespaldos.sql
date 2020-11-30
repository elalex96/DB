CREATE PROCEDURE dbo.sp_EN_ExtraeDocumentosEntregablesRespaldos--	 3,10061,'20200101','20200331','Descarga todos los archiOs'--24
    @IdContrato INT,
    @idUsuario INT,
	@FechaInicio DATETIME,
	@FechaFin	DATETIME,
	@Opcion VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;

IF @IdContrato = 10054
BEGIN
	EXEC sp_EN_ExtraeDocumentosEntregablesRespaldos_ENI @IdContrato, @idUsuario, @FechaInicio, @FechaFin, @Opcion
	RETURN
END

	CREATE TABLE #EN_InstanciaPeriodo (IdInstanciaEntregable INT, Nombre VARCHAR(250));
	CREATE TABLE #EN_InstanciaRespaldo (IdInstanciaEntregable INT);


	--TODOS LAS INSTANCIAS CON ARCHIVO DE RANGO DE FECHAS
	INSERT INTO #EN_InstanciaPeriodo (
								IdInstanciaEntregable ,
								Nombre
								)
	SELECT DISTINCT IE.idInstanciaEntregable AS IdInstanciaEntregable,
			LTRIM(IE.idInstanciaEntregable) + '.zip' AS Nombre
	FROM
		EN_InstanciasEntregable	IE (NOLOCK)
	JOIN
			EN_ContratoEntregable	CE	(NOLOCK)
			ON	IE.IdContratoEntregable	=	CE.IdContratoEntregable
			AND	CE.IdContrato	=	@IdContrato
			AND	ISNULL(IE.Activo,1)	=	1
			AND	ISNULL(CE.Activo,1)	=	1
	JOIN
		EN_Entregable	E
		ON	CE.IdEntregable	=	E.IdEntregable
		AND E.BitJOA	=	0											--JOA
	JOIN
		EN_HistorialAprobacionesLineaTiempo	FINR	(NOLOCK)
		ON	IE.idInstanciaEntregable	=	FINR.idInstanciaEntregable
		AND FINR.idTipoOperacion = 4
	JOIN
		EN_DocumentoVersion	DV
		ON	IE.idInstanciaEntregable	=	DV.idInstanciaEntregable
		AND FINR.IdLineaTiempo	=	DV.N_version
		AND DV.Activo = 1
	LEFT JOIN
		EN_ContratoEntregableProgramaImplementaAcciones	ENT_ACC
		ON CE.IdContratoEntregable	=	ENT_ACC.IdContratoEntregable		--SASISOPA NULL
	WHERE
		CE.IdContrato	=	@IdContrato
	AND
			ENT_ACC.IdProgramaImplementaAccion IS NULL
	AND
			E.BitJOA	=	0												--JOA
		AND
			IE.FechaCalculadaEntregaReg BETWEEN  @FechaInicio AND @FechaFin;

	IF(@Opcion = 'Descarga todos los archivos')
	BEGIN
		
		SELECT * FROM #EN_InstanciaPeriodo
	END
	ELSE
	BEGIN
	--SACA LAS INSTANCIAS QUE YA SE RESPALDARON ANTERIORIMENTE EN EL RANGO DE FECHAS ESTABLECIDO
		INSERT INTO  #EN_InstanciaRespaldo (IdInstanciaEntregable )
		SELECT DISTINCT IER.IdInstanciaEntregable
		FROM 
			EN_InstanciasBitacoraRespaldos IER
		JOIN
		
	EN_InstanciasEntregable	IE
			ON	IER.IdInstanciaEntregable	=	IE.IdInstanciaEntregable
		JOIN
			EN_ContratoEntregable	CE
			ON IE.IdContratoEntregable	=	CE.IdContratoEntregable
		WHERE
			CE.IdContrato	=	@IdContrato
			AND IE.FechaCalculadaEntregaReg BETWEEN  @FechaInicio AND @FechaFin;

		SELECT IP.IdInstanciaEntregable, LTRIM(IP.idInstanciaEntregable) + '.zip' AS Nombre
		FROM 
			#EN_InstanciaPeriodo IP
		LEFT JOIN
			#EN_InstanciaRespaldo	IR
			ON IP.IdInstanciaEntregable	=	IR.IdInstanciaEntregable
		WHERE 
			IR.IdInstanciaEntregable IS NULL
	END

END
