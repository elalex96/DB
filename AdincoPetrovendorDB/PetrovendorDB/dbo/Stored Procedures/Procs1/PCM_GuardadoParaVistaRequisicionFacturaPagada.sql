
CREATE PROCEDURE [dbo].[PCM_GuardadoParaVistaRequisicionFacturaPagada]
AS
BEGIN
    DELETE PCM_RequisicionFacturaPagada

    DECLARE @IdContrato INT = 10036

    DECLARE @TablaSolpedPedido TABLE
    (
        IdSolicitudPedido INT,
        NombreRequisitor NVARCHAR(MAX),
        FechaRequisicion DATETIME,
        MotivoRequisicion NVARCHAR(MAX),
        IdIdentificador INT,
        IdPedido INT,
        subtotal FLOAT,
        IdMoneda INT,
        RazonSocial NVARCHAR(MAX),
        FechaPedido DATETIME
    )
    DECLARE @TablaAceptacion TABLE
    (
        IdAceptacionPedido INT,
        FechaAceptacion DATETIME,
        MontoAceptado FLOAT,
        IdPedido INT
    )
    DECLARE @TablaFactura TABLE
    (
        IdAceptacionPedido INT,
        IdFactura INT,
        FechaRecepcion DATETIME,
        MontoConIva FLOAT,
        FechaCambio DATETIME,
        UUID NVARCHAR(MAX)
    )
    DECLARE @TablaPagado TABLE
    (
        IdFacturaPetrov INT,
        MontoPagado FLOAT,
        FechaPagado DATETIME,
        IdMoneda INT,
        CvTipoDocFacturacion INT
    )
    DECLARE @TablaPPDFiltro TABLE
    (
        IdFacturaPetrov INT,
        MontoPagado FLOAT,
        FechaPagado DATETIME,
        IdMoneda INT,
        CvTipoDocFacturacion INT
    )

    INSERT INTO @TablaSolpedPedido
    (
        IdSolicitudPedido,
        NombreRequisitor,
        FechaRequisicion,
        MotivoRequisicion,
        IdIdentificador,
        IdPedido,
        subtotal,
        IdMoneda,
        RazonSocial,
        FechaPedido
    )
    SELECT sp.IdSolicitudPedido,
           u.Nombre,
           sp.FechaAlta,
           sp.MotivoUrgencia,
           ps.IdPedido,
           p.IdPedido,
           SUM(pd.Subtotal),
           pd.IdMoneda,
           prov.RazonSocial,
           p.CreadoEl
    FROM dbo.MM_SolicitudPedido sp
        LEFT JOIN dbo.MM_Pedido p
            ON p.IdSolicitudPedido = sp.IdSolicitudPedido
               AND ISNULL(p.IdEstatusEliminado, 0) = 0
        LEFT JOIN dbo.MM_PedidoDetalle pd
            ON pd.IdPedido = p.IdPedido
               AND ISNULL(pd.IdEstatusEliminado, 0) = 0
        LEFT JOIN dbo.MM_Pedidos ps
            ON ps.IdIdentificador = p.IdPedido
               AND p.IdProveedorCompras = ps.IdProveedorCliente
        LEFT JOIN dbo.S_Usuario u
            ON u.IdUsuario = sp.IdUsuarioSolicitante
        LEFT JOIN dbo.S_Proveedor prov
            ON prov.IdProveedor = p.IdSubcontratista
    WHERE sp.IdContrato = @IdContrato
          AND ISNULL(sp.IdEstatusEliminado, 0) = 0
    GROUP BY sp.IdSolicitudPedido,
             u.Nombre,
             sp.FechaAlta,
             sp.MotivoUrgencia,
             ps.IdPedido,
             p.IdPedido,
             pd.IdMoneda,
             prov.RazonSocial,
             p.CreadoEl





    INSERT INTO @TablaAceptacion (IdAceptacionPedido, FechaAceptacion, MontoAceptado, IdPedido)
    SELECT ap.IdAceptacionPedido,
           ap.Creado,
           SUM(apd.Cantidad * pd.PrecioUnitario),
           ap.IdPedido
    FROM dbo.MM_AceptacionPedido ap
        INNER JOIN dbo.MM_AceptacionPedidoDetalle apd
            ON apd.IdAceptacionPedido = ap.IdAceptacionPedido
               AND ISNULL(apd.IdEstatusEliminado, 0) = 0
        INNER JOIN dbo.MM_PedidoDetalle pd
            ON pd.IdPedidoDetalle = apd.IdPedidoDetalle
               AND ISNULL(pd.IdEstatusEliminado, 0) = 0
        INNER JOIN @TablaSolpedPedido solPedido
            ON solPedido.IdPedido = ap.IdPedido
    WHERE ISNULL(ap.IdEstatusEliminado, 0) = 0
    GROUP BY ap.IdAceptacionPedido,
             ap.Creado,
             ap.IdPedido



    INSERT INTO @TablaFactura
    (
        IdAceptacionPedido,
        IdFactura,
        FechaRecepcion,
        MontoConIva,
        FechaCambio,
        UUID
    )
    SELECT af.IdAceptacionPedido,
           f.IdFactura,
           f.FechaRecepcion,
           f.MontoConIva,
           f.Fecha,
           f.UUID
    FROM dbo.MM_AceptacionFactura af
        INNER JOIN dbo.FI_Factura f
            ON f.IdFactura = af.IdFactura
               AND f.Activa = 1
        INNER JOIN dbo.TA_Operacion tao
            ON af.IdAceptacionFactura = tao.IdDocumento
               AND ISNULL(tao.IdEstatusEliminado, 0) = 0
        INNER JOIN @TablaAceptacion acepta
            ON acepta.IdAceptacionPedido = af.IdAceptacionPedido
    WHERE tao.IdEstatusOperacion = 2
          AND ISNULL(af.IdEstatusEliminado, 0) = 0


    -- PPD
    INSERT INTO @TablaPPDFiltro (IdFacturaPetrov, MontoPagado, FechaPagado, IdMoneda, CvTipoDocFacturacion)
    SELECT fPetrov.IdFactura,
           SUM(cpr.ImpPagado),
           tr.FechaPago,
           tr.IdMoneda,
           tf.CvTipoDocFacturacion
    FROM dbo.FI_Factura fPetrov
        LEFT JOIN Adinco.dbo.FI_Factura fPrinc
            ON fPrinc.UUID COLLATE DATABASE_DEFAULT = fPetrov.UUID
        LEFT JOIN Adinco.dbo.FI_CPDocRelacionado cpr
            ON cpr.IdDocumento = fPrinc.UUID
        LEFT JOIN Adinco.dbo.FI_ComplementoDePago cp
            ON cp.IdComplementoDePago = cpr.IdComplementoDePago
        LEFT JOIN Adinco.dbo.FI_Factura f
            ON f.IdFactura = cp.IdFactura
        LEFT JOIN Adinco.dbo.FI_TransferFactura tf
            ON tf.IdFactura = f.IdFactura
        LEFT JOIN Adinco.dbo.FI_Transfer tr
            ON tr.IdTransferencia = tf.IdTransfer
        INNER JOIN @TablaFactura ttf
            ON ttf.UUID = fPetrov.UUID
    WHERE tf.CvTipoDocFacturacion = 6
          AND fPrinc.IdContrato = @IdContrato
    GROUP BY fPetrov.IdFactura,
             tr.FechaPago,
             tr.IdMoneda,
             tf.CvTipoDocFacturacion

    INSERT INTO @TablaPagado (IdFacturaPetrov, MontoPagado, FechaPagado, IdMoneda, CvTipoDocFacturacion)
    SELECT IdFacturaPetrov,
           MontoPagado,
           FechaPagado,
           IdMoneda,
           CvTipoDocFacturacion
    FROM @TablaPPDFiltro

    -- PUE E HISTORICO PPD
    -- se descartan las PPD que se insertaron anteriormente
    INSERT INTO @TablaPagado (IdFacturaPetrov, MontoPagado, FechaPagado, IdMoneda)
    SELECT fPetrov.IdFactura,
           SUM(tf.MontoPagado),
           tr.FechaPago,
           tr.IdMoneda
    FROM dbo.FI_Factura fPetrov
        LEFT JOIN Adinco.dbo.FI_Factura fPrinc
            ON fPrinc.UUID COLLATE DATABASE_DEFAULT = fPetrov.UUID
        LEFT JOIN Adinco.dbo.FI_TransferFactura tf
            ON tf.IdFactura = fPrinc.IdFactura
        LEFT JOIN Adinco.dbo.FI_Transfer tr
            ON tr.IdTransferencia = tf.IdTransfer
        INNER JOIN @TablaFactura ttf
            ON ttf.UUID = fPetrov.UUID
        LEFT JOIN @TablaPPDFiltro filtro
            ON filtro.IdFacturaPetrov = fPetrov.IdFactura
    WHERE tf.IdFactura IS NOT NULL
          AND tf.CvTipoDocFacturacion NOT IN ( 2, 3, 6 )
          AND fPrinc.IdContrato = @IdContrato
          AND filtro.IdFacturaPetrov IS NULL -- donde no existan las PPD agregadas anteriormente
    GROUP BY fPetrov.IdFactura,
             tr.FechaPago,
             tr.IdMoneda


    INSERT INTO dbo.PCM_RequisicionFacturaPagada
    (
        Requisicion,
        NombreRequisitor,
        FechaRequisicion,
        MotivoRequisicion,
        OrdenCompra,
        FechaOrdenCompra,
        MontoOrdenCompra,
        Moneda,
        MontoOrdenCompraUSD,
        IdAceptacionPedido,
        FechaAceptacion,
        MontoAceptado,
        MontoAceptadoUSD,
        IdFactura,
        RazonSocial,
        FechaRecepcion,
        MontoFacturado,
        MontoFacturadoUSD,
        MontoPagado,
        MonedaPagado,
        MontoPagadoUSD,
        FechaPagado,
        TipoCambioRequisicion,
        TipoCambioPagado,
        UUID
    )
    SELECT solPedido.IdSolicitudPedido AS Requisicion,
           solPedido.NombreRequisitor,
           solPedido.FechaRequisicion,
           solPedido.MotivoRequisicion,
           solPedido.IdIdentificador AS OrdenCompra,
           solPedido.FechaPedido AS FechaOrdenCompra,
           solPedido.subtotal AS MontoOrdenCompra,
           CASE
               WHEN solPedido.IdMoneda = 1 THEN
                   'MXN'
               WHEN solPedido.IdMoneda = 2 THEN
                   'USD'
           END AS Moneda,
           CASE
               WHEN solPedido.IdMoneda = 1 THEN
                   solPedido.subtotal / cambio.TipoCambio
               WHEN solPedido.IdMoneda = 2 THEN
                   solPedido.subtotal
           END AS MontoOrdenCompraUSD,
           acepta.IdAceptacionPedido,
           acepta.FechaAceptacion,
           acepta.MontoAceptado,
           CASE
               WHEN solPedido.IdMoneda = 1 THEN
                   acepta.MontoAceptado / cambio.TipoCambio
               WHEN solPedido.IdMoneda = 2 THEN
                   acepta.MontoAceptado
           END AS MontoAceptadoUSD,
           fact.IdFactura,
           solPedido.RazonSocial,
           fact.FechaRecepcion,
           fact.MontoConIva AS MontoFacturado,
           CASE
               WHEN solPedido.IdMoneda = 1 THEN
                   fact.MontoConIva / cambio.TipoCambio
               WHEN solPedido.IdMoneda = 2 THEN
                   fact.MontoConIva
           END AS MontoFacturadoUSD,

           -- en caso de que la moneda pagada no corresponda con la moneda facturada
           CASE
               WHEN pagado.CvTipoDocFacturacion = 6 THEN
                   CASE
                       WHEN pagado.IdMoneda = 1
                            AND cambioFact.IdMoneda = 2 THEN
                           pagado.MontoPagado / cambioPagado.TipoCambio
                       WHEN (pagado.IdMoneda = 2 AND cambioFact.IdMoneda = 1) THEN
                           pagado.MontoPagado * cambioPagado.TipoCambio
                       ELSE
                           pagado.MontoPagado
                   END
               ELSE
                   pagado.MontoPagado
           END AS MontoPagado,
           CASE
               WHEN pagado.IdMoneda = 1 THEN
                   'MXN'
               WHEN pagado.IdMoneda = 2 THEN
                   'USD'
           END AS MonedaPagado,
           CASE
               WHEN pagado.CvTipoDocFacturacion = 6 THEN
                   CASE
                       WHEN pagado.IdMoneda = 1
                            AND cambioFact.IdMoneda = 2 THEN
                           pagado.MontoPagado * cambioPagado.TipoCambio
                       WHEN (pagado.IdMoneda = 2 AND cambioFact.IdMoneda = 1)
                            OR pagado.IdMoneda = 1 THEN
                           pagado.MontoPagado / cambioPagado.TipoCambio
                       ELSE
                           pagado.MontoPagado
                   END
               ELSE
                   CASE
                       WHEN pagado.IdMoneda = 1 THEN
                           pagado.MontoPagado / cambioPagado.TipoCambio
                       WHEN pagado.IdMoneda = 2 THEN
                           pagado.MontoPagado
                   END
           END AS MontoPagadoUSD,
           pagado.FechaPagado,
           cambio.TipoCambio AS TipoCambioRequisicion,
           cambioPagado.TipoCambio AS TipoCambioPagado,
           fact.UUID
    FROM @TablaSolpedPedido solPedido
        LEFT JOIN @TablaAceptacion acepta
            ON acepta.IdPedido = solPedido.IdPedido
        LEFT JOIN @TablaFactura fact
            ON fact.IdAceptacionPedido = acepta.IdAceptacionPedido
        LEFT JOIN @TablaPagado pagado
            ON fact.IdFactura = pagado.IdFacturaPetrov
        LEFT JOIN Adinco.dbo.CO_TipoCambioDiario cambio
            ON cambio.IdMoneda = solPedido.IdMoneda
               AND DAY(cambio.Fecha) = DAY(solPedido.FechaPedido)
               AND MONTH(cambio.Fecha) = MONTH(solPedido.FechaPedido)
               AND YEAR(cambio.Fecha) = YEAR(solPedido.FechaPedido)
        LEFT JOIN Adinco.dbo.CO_TipoCambioDiario cambioFact
            ON cambioFact.IdMoneda = solPedido.IdMoneda
               AND DAY(cambioFact.Fecha) = DAY(fact.FechaCambio)
               AND MONTH(cambioFact.Fecha) = MONTH(fact.FechaCambio)
               AND YEAR(cambioFact.Fecha) = YEAR(fact.FechaCambio)
        LEFT JOIN Adinco.dbo.CO_TipoCambioDiario cambioPagado
            ON cambioPagado.IdMoneda = pagado.IdMoneda
               AND DAY(cambioPagado.Fecha) = DAY(pagado.FechaPagado)
               AND MONTH(cambioPagado.Fecha) = MONTH(pagado.FechaPagado)
               AND YEAR(cambioPagado.Fecha) = YEAR(pagado.FechaPagado)
    ORDER BY acepta.IdAceptacionPedido

END

