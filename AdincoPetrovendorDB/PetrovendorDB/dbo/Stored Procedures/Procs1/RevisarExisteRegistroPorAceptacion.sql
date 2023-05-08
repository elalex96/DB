
CREATE PROCEDURE RevisarExisteRegistroPorAceptacion @IdAceptacionPedido INT
AS
BEGIN
	/*VALIDAR QUE NO EXISTA REGISTRADO GASTOS RELACIONADOS A LA FACTURA ACTUAL EN CO_REGISTRO */
    IF EXISTS
    (
        SELECT 1
        FROM dbo.MM_AceptacionPedido AP
            JOIN dbo.MM_AceptacionFactura AF
                ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				AND ISNULL(AF.IdEstatusEliminado,0)=0 --> QUE NO ESTE ELIMINADA
            JOIN dbo.FI_Factura F
                ON AF.IdFactura = F.IdFactura
            JOIN dbo.MM_AceptacionPedidoDetalle apd
                ON apd.IdAceptacionPedido = AP.IdAceptacionPedido
                   AND ISNULL(apd.IdEstatusEliminado, 0) = 0
            JOIN dbo.CO_Registro R
                ON apd.IdAceptacionPedidoDetalle = R.IdAceptacionPedidoDetalle
                   AND F.IdFactura = R.IdFactura
        WHERE AP.IdAceptacionPedido = @IdAceptacionPedido
              AND ISNULL(AP.IdEstatusEliminado, 0) = 0
    )
    BEGIN
        SELECT 1; -- existe el gasto entonces no debe de guardarse
    END;
    ELSE
    BEGIN
        SELECT 0; -- no existe el gasto entonces debe de guardarse
    END;
END;