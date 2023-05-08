CREATE PROCEDURE dbo.sp_EN_GuardaEntregablesBitacoraRespaldos-- 3,10061,'2019-10-01','2019-12-31','Descarga de archivo'
    @IdContrato INT,
    @idUsuario INT,
	@FechaInicio DATETIME,
	@FechaFin	DATETIME,
	@Opcion	VARCHAR(250)
AS
BEGIN
    SET NOCOUNT ON;
	DECLARE @IdBitacoraRespaldos INT = 0;
	
	CREATE TABLE #EN_Instancia (IdInstanciaEntregable INT, Nombre VARCHAR(250));

	INSERT INTO #EN_Instancia (
								IdInstanciaEntregable ,
								Nombre
								)
	EXEC sp_EN_ExtraeDocumentosEntregablesRespaldos @IdContrato,@idUsuario,@FechaInicio,@FechaFin, @Opcion;

	INSERT INTO EN_BitacoraRespaldos (	FechaInicio,
										FechaFin,
										Opcion,
										CreadoPor,
										CreadoEn,
										Activo)
	SELECT @FechaInicio,@FechaFin, @Opcion,@idUsuario,GETDATE(),1 


	SET @IdBitacoraRespaldos = @@IDENTITY;

	INSERT INTO EN_InstanciasBitacoraRespaldos(	IdBitacoraRespaldos,
												IdInstanciaEntregable,
												Activo)
	SELECT @IdBitacoraRespaldos , IdInstanciaEntregable , 1 FROM #EN_Instancia


END