-- =============================================
-- Author: Pedro Acuña
-- Create date: 07/11/2018
-- Description: retornar el mes en español, ya que set language no se puede ocupar dentro de una funcion
-- =============================================

CREATE FUNCTION Fn_RetornarMesEspanol
	( @IdMes INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)

		SELECT	@retorno = CASE WHEN @IdMes = 1 THEN
									'Enero'
						   WHEN @IdMes = 2 THEN
							   'Febrero'
						   WHEN @IdMes = 3 THEN
							   'Marzo'
						   WHEN @IdMes = 4 THEN
							   'Abril'
						   WHEN @IdMes = 5 THEN
							   'Mayo'
						   WHEN @IdMes = 6 THEN
							   'Junio'
						   WHEN @IdMes = 7 THEN
							   'Julio'
						   WHEN @IdMes = 8 THEN
							   'Agosto'
						   WHEN @IdMes = 9 THEN
							   'Septiembre'
						   WHEN @IdMes = 10 THEN
							   'Octubre'
						   WHEN @IdMes = 11 THEN
							   'Noviembre'
						   WHEN @IdMes = 12 THEN
							   'Diciembre'
						   END

		RETURN @retorno
	END