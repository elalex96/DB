
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <24-05-2018>
-- Description:	<Se agrega nueva instalacion>
-- =============================================

CREATE procedure [dbo].[CO_SP_ActualizacionInstalacion]
	@NombreInstalacion VARCHAR(500),
	@IdInstalacionPemex VARCHAR(10),
	@EsBolsa BIT,
	@IdActividad INT = NULL,
	@NombreInstalacionAlterno VARCHAR(500),
	@IdCatalogoSCIEP INT,
	@IdYacimiento INT = NULL,
	@IdCampo INT = NULL,
	@UTMX FLOAT,
	@UTMY FLOAT,
	@IdEstatus INT = NULL,
	@IdUsuario INT,
	@IdInstalacion INT,
	@Activo BIT,
	@ComodinBolsa BIT
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
			ModificadoEn = GETDATE(),
			Activo =	@Activo,
			ComodinBolsa = @ComodinBolsa
		WHERE IdInstalacion = @IdInstalacion

		UPDATE P
		SET	P.Nombre = UPPER(@NombreInstalacion),
			P.Modificado = GETDATE(),
			P.ModificadoPor = LTRIM(@IdUsuario)
		FROM	
			CO_Instalacion	I
		JOIN
			PR_Pozo	P
			ON	I.WelIID	=	P.Id
		WHERE I.IdInstalacion = @IdInstalacion
		AND I.WelIID IS NOT NULL 
		AND I.WelIID > 0
END 
