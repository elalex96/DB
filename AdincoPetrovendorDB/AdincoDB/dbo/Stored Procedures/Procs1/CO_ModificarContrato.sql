-- ====================================================================
CREATE PROCEDURE [dbo].[CO_ModificarContrato] 
	-- Add the parameters for the stored procedure here
	@NumeroContrato AS NVARCHAR (MAX),
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
	@IdUbicacionGeografica AS INT,
	@IdRonda AS INT,
	@IsConsorcio AS BIT,
	@IdContrato AS INT,
	@idUsuario AS INT
AS
BEGIN
	-- =================================================================
	-- Author:		Valeria Rodríguez
	-- Create date: 03/01/2019
	-- Description:	Modificación de datos en la tabla CO_Contrato
	-- =================================================================
	SET NOCOUNT ON;
	DECLARE @FinVigencia AS DATE;
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET @FinVigencia = DATEADD(YEAR, @Duracion, @InicioVigencia)
	-- Insert statements for procedure here
	UPDATE CO_Contrato
	SET NumeroContrato = @NumeroContrato,
		DescripcionContrato = @DescripcionContrato,
		IdContratista = @IdContratista,
		IdAreaContractual = @IdAreaContractual,
		IDRegFiducidiario = @IDRegFiducidiario,
		Duracion = @Duracion,
		FechaFirma = @FechaFirma,
		InicioVigencia = @InicioVigencia,
		FinVigencia = @FinVigencia,
		IdTipoContrato = @IdTipoContrato,
		ValorRegaliaAdicional = @ValorRegaliaAdicional,
		IncrementoProgramaMinimo = @IncrementoProgramaMinimo,
		Activo = @Activo,
		PorcentajeRecuperacion = @PorcentajeRecuperacion,
		GasNoAsociado = @GasNoAsociado,
		IsPC = @IsPC,
		IdUbicacionGeografica = @IdUbicacionGeografica,
		IdRonda = @IdRonda,
		IsConsorcio = @IsConsorcio
	WHERE IdContrato = @IdContrato
END
