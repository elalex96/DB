
-- =============================================
-- Author: Daniel AC
-- Create date: 12-04-2022
-- Description:	 Se actualiza información para retornar el no de tarea correctamente 
-- =============================================
CREATE procedure [dbo].[SP_MM_ConsultaIdTareaPorPedido]
	@IdSolicitudPedido INT,
	@Version INT,
    @IdContrato    INT = null, 
	@IdUsuario     INT,
    @FechaRegistro DATETIME = null
AS
BEGIN
	SELECT t.IdTarea
	FROM MM_Pedido P
	JOIN dbo.TA_Operacion O ON
		 P.IdSolicitudPedido  = O.IdDocumento
		 AND P.Version =O.NoVersion 
	JOIN dbo.TA_Tarea T
		ON  O.IdOperacion = T.IdOperacion 
	WHERE P.IdSolicitudPedido = @IdSolicitudPedido
		AND O.IdTipoOperacion = 9 --> CTE APROBACION DE PEDIDO
		AND O.NoVersion=@Version
		AND T.IdAprobador=@IdUsuario
		AND ISNULL(t.Activo,0)=1 --> CTE DEBE ESTAR ACTIVA LA TAREA
	GROUP BY t.IdTarea
END