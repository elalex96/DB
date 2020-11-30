-- =============================================
-- Author:		Josue Glez
-- Create date: 14/11/2017
-- Description:	Obtiene la lista de aprobaciones de un pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaAprobacionesPorPedido_RPT] --10008
	@idPedido int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

SELECT U.Nombre, TA.FechaCambioEstatus, TA.Comentario
FROM dbo.MM_Pedido p 
LEFT	JOIN	dbo.TA_Operacion TAO ON (p.IdSolicitudPedido = TAO.IdDocumento)
LEFT JOIN	dbo.TA_Tarea TA ON TAO.IdOperacion = TA.IdOperacion
LEFT JOIN DBO.S_Usuario u ON U.IdUsuario = TA.IdAprobador
WHERE
TAO.IdTipoOperacion = 9 AND p.IdPedido = @idPedido

END
