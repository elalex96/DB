
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <26-11-2018>
-- Description:	<Se valida que la solped no contenga un flujo de aprobacion para poder modificarse>
-- =============================================

CREATE PROCEDURE MM_SP_ValidarSolPedModificable	
	@IdSolicitudPedido INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT COUNT(IdOperacion) 
	FROM dbo.TA_Operacion 
	WHERE IdDocumento = @IdSolicitudPedido
		AND ISNULL(IdEstatusEliminado, 0) = 0
END 