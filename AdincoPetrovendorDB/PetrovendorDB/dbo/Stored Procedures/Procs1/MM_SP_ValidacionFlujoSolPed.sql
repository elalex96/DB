-- =============================================
-- Author:		<Jose Roman>
-- Create date: <03-01-2018>
-- Description:	<Se valida si ya existe un flujo de aprobacion para la solped>
-- =============================================

CREATE PROCEDURE MM_SP_ValidacionFlujoSolPed	
	@IdSolicitudPedido INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT COUNT(IdOperacion)
	FROM dbo.TA_Operacion o 
	WHERE IdDocumento = @IdSolicitudPedido
	AND o.IdTipoOperacion= 2
END
