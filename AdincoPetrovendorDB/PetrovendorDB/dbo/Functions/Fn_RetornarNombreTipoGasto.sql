-- =============================================
-- Author: Pedro Acuña
-- Create date: 28/08/2018
-- Description: retornar el tipo de gasto
-- =============================================

CREATE FUNCTION Fn_RetornarNombreTipoGasto
	( @IdSolicitudPedido INT )
RETURNS NVARCHAR(MAX)
AS
	BEGIN
		DECLARE @retorno NVARCHAR(MAX)

		SELECT		@retorno = tg.TipoGasto
		FROM		dbo.MM_SolicitudPedido sp
		INNER JOIN	dbo.MM_TipoGastos tg
			ON tg.IdTipoGasto = sp.IdTipoGasto
		WHERE		sp.IdSolicitudPedido = @IdSolicitudPedido

		RETURN @retorno
	END