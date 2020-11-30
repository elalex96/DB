CREATE PROCEDURE PCM_ReporteMontosPresupuestoPedidos_3
AS
BEGIN
	DELETE PCM_MontosPresupuestoPedidos

	INSERT INTO dbo.PCM_MontosPresupuestoPedidos
	(
	    IdPedido,
	    IdPedidoDetalle,
	    IdAceptacionpedido,
	    DescripcionLarga,
	    Cantidad,
	    Monto_Total,
	    MonedaPedido_Aceptado,
	    MonedaPedido_AceptadoDLS,
	    Fecha_Aceptacion,
	    Usuario_Acepto,
	    subtareaSolped,
	    subtareaAcepta,
	    tipoCambio
	)
    SELECT PS.IdPedido,
           PD.IdPedidoDetalle,
           AP.IdAceptacionPedido,
           M.DescripcionLarga,
           APD.Cantidad,
           PD.PrecioUnitario * APD.Cantidad AS Monto_Total,
           CASE PD.IdMoneda
               WHEN 1 THEN
                   'MXN'
               WHEN 2 THEN
                   'USD'
           END AS MonedaPedido_Aceptado,
           CASE PD.IdMoneda
               WHEN 1 THEN
           (PD.PrecioUnitario * APD.Cantidad) / cambio.TipoCambio
               WHEN 2 THEN
                   PD.PrecioUnitario * APD.Cantidad
           END AS MonedaPedido_AceptadoDLS,
           APD.Creado AS Fecha_Aceptacion,
           S.Nombre AS Usuario_Acepto,
           servSolped.NombreServicio subtareaSolped,
           servAcepta.NombreServicio subtareaAcepta,
           cambio.TipoCambio AS tipoCambio
    FROM MM_Pedido P
        INNER JOIN MM_Pedidos PS
            ON P.IdPedido = PS.IdIdentificador
               AND P.IdProveedorCompras = PS.IdProveedorCliente
        INNER JOIN MM_PedidoDetalle PD
            ON P.IdPedido = PD.IdPedido
        INNER JOIN MM_Material M
            ON PD.IdMaterial = M.IdMaterial
        INNER JOIN MM_AceptacionPedidoDetalle APD
            ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
        INNER JOIN dbo.MM_AceptacionPedidoDetalleInstalacion apdi
            ON apdi.IdAceptacionPedidoDetalle = APD.IdAceptacionPedidoDetalle
        INNER JOIN MM_AceptacionPedido AP
            ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
        INNER JOIN S_Usuario S
            ON S.IdUsuario = APD.CreadoPor
        INNER JOIN dbo.MM_PeticionOfertaDetalle pod
            ON pod.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
        INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
            ON spdl.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
        LEFT JOIN Adinco.dbo.CO_TipoCambioDiario cambio
            ON cambio.IdMoneda = P.IdMoneda
               AND DAY(cambio.Fecha) = DAY(P.CreadoEl)
               AND MONTH(cambio.Fecha) = MONTH(P.CreadoEl)
               AND YEAR(cambio.Fecha) = YEAR(P.CreadoEl)
        LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes linea
            ON linea.IdLineaPresupuestoMes = spdl.IdLineaPresupuesto
        LEFT JOIN Adinco.dbo.CO_Servicio servSolped
            ON servSolped.IdServicio = linea.IdServicio
        LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes lineaAcepta
            ON lineaAcepta.IdLineaPresupuestoMes = apdi.IdLineaPresupuesto
        LEFT JOIN Adinco.dbo.CO_Servicio servAcepta
            ON servAcepta.IdServicio = lineaAcepta.IdServicio
    WHERE
    -- P.idpedido = 10841
    --AND 
    P.idContrato = 10036 AND
    ISNULL(P.IdEstatusEliminado, 0) <> 1
    AND ISNULL(AP.IdEstatusEliminado, 0) <> 1
    AND ISNULL(PD.IdEstatusEliminado, 0) <> 1;

END
