-- =============================================
-- Author:		Daniel AC
-- Update date: 09/10/2020
-- Description:	Obtener el id del usuario creador de la solped
-- =============================================

CREATE PROCEDURE SP_ObtenerUsuarioCreadorSolpedxIdPedido ( @IdPedido INT )
AS
	BEGIN
		DECLARE @IdUsuarioSolicitante INT 

		SELECT @IdUsuarioSolicitante =solPed.IdUsuarioSolicitante
		FROM  dbo.MM_Pedido  pedido		
		JOIN dbo.MM_SolicitudPedido solPed
			ON pedido.IdSolicitudPedido = solPed.IdSolicitudPedido 
		WHERE  pedido.IdPedido =@IdPedido

		SELECT ISNULL(@IdUsuarioSolicitante,0) AS Requisitor 

	END
