/****** Object:  StoredProcedure [dbo].[CO_SP_AgregarInstalacion]    Script Date: 25/02/2019 09:10:57 a. m. ******/
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <24-05-2018>
-- Description:	<Se agrega nueva instalacion>
-- =============================================
CREATE PROCEDURE [dbo].[CO_SP_AgregarInstalacion]
	@NombreInstalacion VARCHAR(500),
	@IdInstalacionPemex VARCHAR(10),
	@EsBolsa BIT,
	@IdActividad INT,
	@NombreInstalacionAlterno VARCHAR(500),
	@IdCatalogoSCIEP INT,
	@IdContrato INT,
	@IdYacimiento INT,
	@IdCampo INT,
	@UTMX FLOAT,
	@UTMY FLOAT,
	@IdEstatus INT,
	@IdUsuario INT,
	@Activo BIT,
	@ComodinBolsa BIT
AS
BEGIN
	DECLARE @IdAreaContractual INT = (SELECT IdAreaContractual FROM dbo.CO_Contrato WHERE IdContrato = @IdContrato)
	DECLARE @CountInstalaciones INT=(SELECT COUNT(1) FROM dbo.CO_Instalacion WHERE NombreInstalacion=@NombreInstalacion AND IdAreaContractual = @IdAreaContractual)
	IF(@IdCampo = 0)
	BEGIN
		SET @IdCampo = NULL
	END
    IF(@IdActividad = 0)
	BEGIN
		SET @IdActividad = NULL
	end
    IF(@IdYacimiento = 0)
	BEGIN
		SET @IdYacimiento = NULL
	end
    IF(@IdEstatus = 0)
	BEGIN
		SET @IdEstatus = NULL
	END

    IF(@CountInstalaciones=0)
	BEGIN
	INSERT INTO dbo.CO_Instalacion
	(
	    NombreInstalacion,
	    IdInstalacionPemex,
	    EsBolsa,
	    IdActividad,
		IdUsuario,
		FecMovto,
	    NombreInstalacionAlterno,
	    IdCatalogoSCIEP,
	    IdAreaContractual,
	    Activo,
	    IdYacimiento,
	    IdCampo,
	    UTMX,
	    UTMY,
	    IdEstatus,
	    CreadoPor,
	    CreadoEn,
		ComodinBolsa
	)
	VALUES
	(   @NombreInstalacion,
		@IdInstalacionPemex,
		@EsBolsa,
		@IdActividad,
		@IdUsuario,
		GETDATE(),
		@NombreInstalacionAlterno,
		@IdCatalogoSCIEP,
		@IdAreaContractual,
		@Activo,
		@IdYacimiento,
		@IdCampo,
		@UTMX,
		@UTMY,
		@IdEstatus,
		@IdUsuario,
		GETDATE(),
		@ComodinBolsa
	)
	END
	ELSE
	PRINT('Ya existe una instalación con ese nombre');
END
