CREATE PROCEDURE PCM_ReporteMontosOC_2
AS
BEGIN
    DELETE PCM_ReporteMontosOC

    INSERT INTO dbo.PCM_ReporteMontosOC
    (
        IdPedido,
        IdPedidoDetalle,
        IdAceptacionPedido,
        DescripcionLarga,
        Cantidad,
        Monto_Total,
        Fecha_Aceptacion,
        Usuario_Acepto
    )
    SELECT PS.IdPedido,
           PD.IdPedidoDetalle,
           AP.IdAceptacionPedido,
           M.DescripcionLarga,
           APD.Cantidad,
           PD.PrecioUnitario * APD.Cantidad AS Monto_Total,
           APD.Creado AS Fecha_Aceptacion,
           S.Nombre AS Usuario_Acepto
    FROM MM_Pedido P
        INNER JOIN MM_Pedidos PS
            ON P.IdPedido = PS.IdIdentificador
        INNER JOIN MM_PedidoDetalle PD
            ON P.IdPedido = PD.IdPedido
        INNER JOIN MM_Material M
            ON PD.IdMaterial = M.IdMaterial
        INNER JOIN MM_AceptacionPedidoDetalle APD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
        INNER JOIN MM_AceptacionPedido AP
            ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
        INNER JOIN S_Usuario S
            ON S.IdUsuario = APD.CreadoPor
    WHERE
    --P.idpedido = 10841
    --AND 
    P.idContrato = 10036 AND
    ISNULL(P.IdEstatusEliminado, 0) <> 1
    AND ISNULL(AP.IdEstatusEliminado, 0) <> 1
    AND ISNULL(PD.IdEstatusEliminado, 0) <> 1;
END
