
CREATE procedure [dbo].[SP_RPT_OCM_CometarioOfertaPorPedido] --1219
	@IdPedido INT

AS
BEGIN 
	SELECT too.Descripcion AS Comentario
		FROM TA_Operacion AS TOO 
		INNER JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = too.IdDocumento
		INNER JOIN dbo.MM_Pedido AS p ON p.IdSolicitudPedido = sp.IdSolicitudPedido
	WHERE p.IdPedido = @IdPedido 
		AND TOO.IdTipoOperacion = 6
END
