-- =============================================
-- Author:		Pedro Acuña
-- Create date: 12/12/2018
-- Description:	obtener los pedidos de esta solicitud
-- =============================================

CREATE PROCEDURE SP_ADM_ObtenerDatosCmbPedidoS3 @TipoDocumento INT, @IdSolicitudPedido INT
AS
	BEGIN
		IF ( @TipoDocumento = 10 )
			BEGIN
				SELECT		ps.IdPedido AS IdPedidoGral
				FROM		dbo.MM_Pedido p
				INNER JOIN	dbo.MM_Pedidos ps
					ON ps.IdIdentificador = p.IdPedido
				WHERE
							p.IdSolicitudPedido = @IdSolicitudPedido
							AND ISNULL ( p.IdEstatusEliminado, 0 ) = 0
			END
	END