USE Petrovendor
GO
DROP PROC IF EXISTS SEL_MM_MostrarLocalidad
GO
CREATE PROC SEL_MM_MostrarLocalidad
@IdUsuario int,
@IdContrato int,
@rfc varchar(200)
AS 
BEGIN
	DECLARE @columnas VARCHAR(500) = ''
		IF(@RFC IN (
		'PCM171127RVA', --Cardenas Mora
		'PAL120710ID0', --COMPAÑIA PETROLERA DE ALTAMIRA
		'PMS090112TB0' -- PICO MEXICO SERVICIOS PETROLEROS
		))
		BEGIN
			SET @columnas = @columnas + 'NombreLocalidad,';
		END
	SELECT @columnas
END