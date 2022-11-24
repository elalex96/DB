CREATE PROCEDURE [dbo].[sp_JACmbSolPed] (@IdProveedor INT)
AS
BEGIN
    SELECT operacion.IdDocumento AS IdSolPed,
           CONCAT(operacion.IdDocumento, ' - ', solPed.MotivoUrgencia) AS Descripcion
    FROM dbo.TA_Operacion operacion
        INNER JOIN dbo.MM_SolicitudPedido solPed
            ON operacion.IdDocumento = solPed.IdSolicitudPedido
    WHERE operacion.IdEstatusOperacion = 2 --Ya fue aprobada por los aprobadores de la solped
          AND operacion.IdProveedor = @IdProveedor
          AND operacion.IdTipoOperacion = 2 -- es de tipo Solicitud de pedido
END

