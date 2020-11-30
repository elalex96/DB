
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <29-11-2018>
-- Description:	<>
-- =============================================

CREATE PROCEDURE SP_ConsultarEstatusAprobadorPedido	
	@IdOperacion INT,
	@IdAprobador INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN

	SELECT IdEstatus 
	FROM TA_Tarea AS TA
	INNER JOIN TA_Operacion AS O ON O.IdOperacion = TA.IdOperacion
	INNER JOIN S_Usuario AS U ON U.IdUsuario = TA.IdAprobador 
	WHERE TA.IdOperacion = @IdOperacion
		AND TA.IdAprobador = @IdAprobador

END