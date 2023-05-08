-- =============================================
-- Author:		Pedro Acuña
-- Create date: 16/04/2018
-- Description:	obtener el area contractual filtrador por el id de aceptacion del pedido
-- =============================================

CREATE PROCEDURE SP_ObtenerAreaContractualxIdAceptacionPedido ( @IdAceptacionPedido INT )
AS
	BEGIN
		DECLARE @IdSolicitudPedido INT

		SELECT @IdSolicitudPedido = pedido.IdSolicitudPedido
		FROM   dbo.MM_AceptacionPedido acepta
		INNER JOIN dbo.MM_Pedido pedido
			ON pedido.IdPedido = acepta.IdPedido
		WHERE  acepta.IdAceptacionPedido = @IdAceptacionPedido

		EXEC dbo.SP_MM_ConsultarContratosPorIdSolicitudPedido @IdSolicitudPedido = @IdSolicitudPedido -- int
		
	END