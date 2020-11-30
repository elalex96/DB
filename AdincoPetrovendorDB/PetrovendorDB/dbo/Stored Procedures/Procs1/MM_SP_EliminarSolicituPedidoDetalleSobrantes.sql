
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <22-11-2018>
-- Description:	<Se eliminan todos los detalles de la solped que fueron eliminados en la modificacion>
-- =============================================

CREATE PROCEDURE MM_SP_EliminarSolicituPedidoDetalleSobrantes
	@IdDetalles NVARCHAR(max),
	@IdSolicitudPedido INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	DELETE dbo.MM_SolicitudPedidoDetalle
	WHERE IdSolicitudPedidoDetalle NOT IN (SELECT splitdata FROM dbo.fnSplitString(@IdDetalles, ','))
		AND IdSolicitudPedido = @IdSolicitudPedido
END