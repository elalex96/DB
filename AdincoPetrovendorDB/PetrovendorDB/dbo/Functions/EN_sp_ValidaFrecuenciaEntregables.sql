use adinco
GO
DROP PROCEDURE IF EXISTS EN_sp_ValidaFrecuenciaEntregables
GO
CREATE PROCEDURE EN_sp_ValidaFrecuenciaEntregables
@IdContrato int = null,
@IdUsuario int = null,
@Frecuencia varchar(max)
as
BEGIN
DECLARE @Mensaje varchar(max)
	IF EXISTS (select * from EN_FrecuenciaEntregable where LTRIM (frecuenciaentregable) = LTRIM(@Frecuencia))
	BEGIN
		SET @Mensaje = ('NO_VALIDO')
	END
	ELSE
	BEGIN
		SET @Mensaje = ('VALIDO')
	END
	SELECT @Mensaje as 'MENSAJE'
END