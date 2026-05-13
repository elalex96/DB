-- =============================================
-- Author:		<Jose Roman>
-- Create date: <27-08-2018>
-- Description:	<Se consulta la justificacion de una solicitud de pedido por ID Operacion>
-- =============================================

create PROCEDURE MM_SP_ConsultarJustificacionSolPed	
	@IdOperacion INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT sp.MotivoUrgencia
	FROM dbo.TA_Operacion o
	INNER JOIN dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = o.IdDocumento
	WHERE o.IdOperacion = @IdOperacion
END
