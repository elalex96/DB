
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <24-05-2018>
-- Description:	<Se agrega nueva instalacion>
-- =============================================

CREATE procedure [dbo].[CO_SP_ActualizacionInstalacion]
	@NombreInstalacion NVARCHAR(max),
	@IdInstalacionPemex NVARCHAR(10),
	@EsBolsa BIT,
	@IdActividad INT = NULL,
	@NombreInstalacionAlterno NVARCHAR(max),
	@IdCatalogoSCIEP INT,
	@IdYacimiento INT = NULL,
	@IdCampo INT = NULL,
	@UTMX FLOAT,
	@UTMY FLOAT,
	@IdEstatus INT = NULL,
	@IdUsuario INT,
	@IdInstalacion INT
AS
BEGIN
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
	end
	UPDATE dbo.CO_Instalacion
	    SET NombreInstalacion = @NombreInstalacion,
			IdInstalacionPemex = @IdInstalacionPemex,
			EsBolsa = @EsBolsa,
			IdActividad = @IdActividad,
			NombreInstalacionAlterno = @NombreInstalacionAlterno,
			IdCatalogoSCIEP = @IdCatalogoSCIEP,
			IdYacimiento = @IdYacimiento,
			IdCampo = @IdCampo,
			UTMX = @UTMX,
			UTMY = @UTMY,
			IdEstatus = @IdEstatus,
			ModificadoPor = @IdUsuario,
			ModificadoEn = GETDATE()
		WHERE IdInstalacion = @IdInstalacion
END