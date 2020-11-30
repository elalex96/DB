-- =================================================================
CREATE PROCEDURE [dbo].[CO_InsertarContrato]
	-- Add the parameters for the stored procedure here
	@NumeroContrato AS NVARCHAR(MAX),
	@DescripcionContrato AS NVARCHAR(MAX),
	@IdContratista AS INT,
	@IdAreaContractual AS INT,
	@IDRegFiducidiario AS NVARCHAR(MAX),
	@Duracion AS INT,
	@FechaFirma AS DATE,
	@InicioVigencia AS DATE,
	@IdTipoContrato AS INT,
	@ValorRegaliaAdicional AS FLOAT,
	@IncrementoProgramaMinimo AS FLOAT,
	@Activo AS BIT,
	@PorcentajeRecuperacion AS FLOAT,
	@GasNoAsociado AS BIT,
	@IsPC AS INT,
	@IdUbicacionGeografica AS INT =0,
	@IdRonda AS INT,
	@IsConsorcio AS BIT,
	@idContrato AS INT,
	@idUsuario AS INT
AS
BEGIN
	-- ==============================================================
	-- Author:		Valeria Rodríguez
	-- Create date: 03/01/2019
	-- Description:	Inserción de datos en la tabla CO_Contrato
	-- ==============================================================
	SET NOCOUNT ON;
	DECLARE @FinVigencia AS DATE;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET @FinVigencia = DATEADD(YEAR, @Duracion, @InicioVigencia)

    -- Insert statements for procedure here
	INSERT INTO CO_Contrato (
		NumeroContrato,
		DescripcionContrato,
		IdContratista,
		IdAreaContractual,
		IDRegFiducidiario,
		Duracion,
		FechaFirma,
		InicioVigencia,
		FinVigencia,
		IdTipoContrato,
		ValorRegaliaAdicional,
		IncrementoProgramaMinimo,
		Activo,
		PorcentajeRecuperacion,
		GasNoAsociado,
		IsPC,
		IdUbicacionGeografica,
		IdRonda,
		IsConsorcio,
		CreadoPor)
	VALUES (
		@NumeroContrato,
		@DescripcionContrato,
		@IdContratista,
		@IdAreaContractual,
		@IDRegFiducidiario,
		@Duracion,
		@FechaFirma,
		@InicioVigencia,
		@FinVigencia,
		@IdTipoContrato,
		@ValorRegaliaAdicional,
		@IncrementoProgramaMinimo,
		@Activo,
		@PorcentajeRecuperacion,
		@GasNoAsociado,
		@IsPC,
		@IdUbicacionGeografica,
		@IdRonda,
		@IsConsorcio,
		@idUsuario)
END
