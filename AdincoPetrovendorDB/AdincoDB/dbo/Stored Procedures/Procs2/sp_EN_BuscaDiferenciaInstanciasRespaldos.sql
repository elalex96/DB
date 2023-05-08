CREATE PROCEDURE dbo.sp_EN_BuscaDiferenciaInstanciasRespaldos --3,10061,'2020','20210131'
    @IdContrato INT,
    @idUsuario INT,
	@FechaInicio DATETIME,
	@FechaFin	DATETIME
AS
BEGIN
	SET LANGUAGE spanish;

	DECLARE 
	@RespaldadosAnteriormente INT = 0,
	@FaltantesRespaldo	INT = 0

	CREATE TABLE #EN_InstanciaPeriodo (IdInstanciaEntregable INT, Nombre VARCHAR(250));
	CREATE TABLE #EN_InstanciaRespaldo (IdInstanciaEntregable INT);


	--TODOS LAS INSTANCIAS CON ARCHIVO DE RANGO DE FECHAS
	INSERT INTO #EN_InstanciaPeriodo (
								IdInstanciaEntregable ,
								Nombre
								)
	EXEC sp_EN_ExtraeDocumentosEntregablesRespaldos @IdContrato,@idUsuario,@FechaInicio,@FechaFin,'Descarga todos los archivos';
	
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


	SELECT @RespaldadosAnteriormente = COUNT(1) -- RespaldadosAnteriormente
	FROM
		#EN_InstanciaPeriodo IP
	LEFT JOIN
		#EN_InstanciaRespaldo	IR
		ON IP.IdInstanciaEntregable	=	IR.IdInstanciaEntregable
	WHERE 
		IR.IdInstanciaEntregable IS NOT NULL



	SELECT @FaltantesRespaldo = COUNT(1) -- FaltantesRespaldo
	FROM
		#EN_InstanciaPeriodo IP
	LEFT JOIN
		#EN_InstanciaRespaldo	IR
		ON IP.IdInstanciaEntregable	=	IR.IdInstanciaEntregable
	WHERE 
		IR.IdInstanciaEntregable IS NULL



	SELECT  CONCAT(datename(month, @FechaInicio), ' ', YEAR(@FechaInicio)) +' - '+ CONCAT(datename(month, @FechaFin), ' ', YEAR(@FechaFin))  AS RangoFechas ,
			@RespaldadosAnteriormente AS RespaldadosAnteriormente, 
		   @FaltantesRespaldo AS FaltantesRespaldo
		  


END

