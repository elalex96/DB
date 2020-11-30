CREATE PROCEDURE EstatusDeRecepcionDeFactura @IdAceptacionPedido INT
AS
BEGIN

    /*CONSULTA PARA RETORNAR EL ID DEL ESTATUS ACTUAL DE LA APROBACIÓN DE LA FACTURA*/
    DECLARE @IdEstatusOperacion INT;

    SELECT @IdEstatusOperacion = tao.IdEstatusOperacion
    FROM dbo.MM_AceptacionFactura af
        INNER JOIN dbo.TA_Operacion tao
            ON af.IdAceptacionFactura = tao.IdDocumento
               AND ISNULL(tao.IdEstatusEliminado, 0) = 0 --> NO ESTE ELIMINADA
    WHERE af.IdAceptacionPedido = @IdAceptacionPedido
          AND tao.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA
          AND ISNULL(af.IdEstatusEliminado, 0) = 0;

    SELECT @IdEstatusOperacion;
END;

