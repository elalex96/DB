
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <29-11-2018>
-- Description:	<>
-- =============================================
-- Author:		<Luis David De La Cruz>
-- Create date: <02/03/2021>
-- Description:	<Se optimiza la consulta para la pantalla detalle_pedido del issue 984>
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
	INNER JOIN TA_Operacion AS O 
	ON TA.IdOperacion = O.IdOperacion 
	INNER JOIN S_Usuario AS U 
	ON TA.IdAprobador = U.IdUsuario 
	WHERE TA.IdOperacion = @IdOperacion
		AND TA.IdAprobador = @IdAprobador

END