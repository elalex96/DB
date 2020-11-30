--SELECT IdPedido FROM dbo.MM_Pedido
--WHERE Version = 1 AND IdSolicitudPedido = 12321


--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
create PROCEDURE Mobile_ReporteAprobacionPedido
    @IdDocumento AS INT,
	@Version AS INT
-- WITH ENCRYPTION, RECOMPILE, EXECUTE AS CALLER|SELF|OWNER| 'user_name'
AS
BEGIN
	 SELECT TOP 1 IdPedido FROM dbo.MM_Pedido
	WHERE Version = @Version AND IdSolicitudPedido = @IdDocumento
END