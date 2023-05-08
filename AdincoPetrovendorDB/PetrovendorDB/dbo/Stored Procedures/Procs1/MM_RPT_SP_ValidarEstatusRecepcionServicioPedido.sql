-- =============================================
-- Author: <Jose Roman>
-- Create date: <12-09-2018>
-- Description: <Se devuelve el estado de la confirmacion del pedido para el texto de marca de agua en el reporte de OC>
-- =============================================

CREATE PROCEDURE [dbo].[MM_RPT_SP_ValidarEstatusRecepcionServicioPedido]
@IdPedido INT,
/*---------------------Parametros contrato---------------------*/
@IdContrato INT = NULL,
@IdUsuario INT = NULL,
@FechaRegistro DATETIME = NULL
/*---------------------Parametros contrato---------------------*/
AS
BEGIN
SELECT CASE
               WHEN P.RecepcionServicio = 1 THEN
                   ''
               WHEN P.RecepcionServicio = 0 THEN
                   'ORDEN DE COMPRA RECHAZADA POR EL PROVEEDOR'
               WHEN P.RecepcionServicio IS NULL
AND O.IdEstatusOperacion = 2
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0 THEN
                   'CONFIRMACIÓN DEL PROVEEDOR VENCIDA'
  WHEN O.IdEstatusOperacion = 1 THEN
'PEDIDO EN APROBACIÓN'
               WHEN 
O.IdEstatusOperacion = 2
AND P.RecepcionServicio is NULL THEN
                   'PEDIDO EN CONFIRMACIÓN DEL PROVEEDOR'
WHEN 
o.IdEstatusOperacion = 3 THEN 
'PEDIDO RECHAZADO'
ELSE
''
           END
FROM dbo.MM_Pedido P
INNER JOIN dbo.MM_HorasVigenciaPedido AS HV
            ON HV.IdPedido = P.IdPedido
INNER JOIN dbo.TA_Operacion O ON O.IdDocumento = P.IdSolicitudPedido AND O.IdTipoOperacion = 9 AND O.NoVersion = P.Version
WHERE P.IdPedido = @IdPedido
END