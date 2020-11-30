CREATE PROCEDURE sp_BI_LlenaTabla_BI_AvancePedido
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Proveedores TABLE
    (
        IdProveedor INT
    );


    INSERT INTO @Proveedores
    (
        IdProveedor
    )
    VALUES
    (606),
    (676),
    (690),
    (1315),
    (1424),
    (1835);


    DECLARE @Pedido TABLE
    (
        IdPedido INT,
        IdSolicitudPedido INT,
        IdOperacion INT,
        Comprador VARCHAR(MAX),
        IdPedidoGeneral INT,
        ContratoId INT,
        Contrato VARCHAR(MAX),
        EnAprobacion BIT,
        PedidoEnAprobacion BIT,
        PedidoAprobado BIT,
        EstatusAprobacion VARCHAR(MAX),
        EstatusConfirmacion VARCHAR(MAX),
        PedidoConfirmado BIT,
        PedidoVencido BIT,
        PedidoEnConfirmacion BIT,
        TotalidadAceptada BIT,
        PorcentajeAceptadoPedido FLOAT,
        Proveedor VARCHAR(MAX),
        ProveedorId INT,
        ProveedorClienteId INT,
        MontoPedido FLOAT,
        Moneda VARCHAR(MAX),
        Corporativo VARCHAR(MAX),
        QuienDebe NVARCHAR(10),
        EstatusAvancePedido NVARCHAR(MAX),
        MontoEstatus FLOAT,
        MontoEstatusUSD FLOAT,
        MontoPedidoUSD FLOAT,
        Solicitante VARCHAR(MAX),
        FechaRegistro DATETIME
    );

    DECLARE @PedidoMonto TABLE
    (
        IdPedido INT,
        Monto FLOAT
    );

    DECLARE @PedidoAceptado TABLE
    (
        IdPedido INT,
        PorcentajeAceptado FLOAT
    );

    DECLARE @PedidoPrecioDLS AS TABLE
    (
        IdPedido INT,
        PrecioDolar FLOAT
    );

    DECLARE @AceptacionPedido TABLE
    (
        IdAceptacionPedido INT,
        IdPedido INT,
        MontoAceptado FLOAT,
        Recepcionado BIT,
        PorcentajeAceptado FLOAT,
        CargaCNN BIT,
        AprobacionCNN BIT,
        CNNEnAprobacion BIT,
        CargaFactura BIT,
        FacturaEnAprobacion BIT,
        AprobacionFactura BIT,
        PagoRealizado BIT,
        QuienDebe NVARCHAR(10),
        FlujoAceptacionTerminado BIT,
        PedirCarta BIT,
        MontoFacturado FLOAT,
        MonedaFactura VARCHAR(100),
        MontoFacturadoUSD FLOAT,
        MontoAceptadoUSD FLOAT
    );

    DECLARE @Estatus TABLE
    (
        IdAceptacionPedido INT,
        IdAceptacionCartaPCN INT
    );


    DECLARE @CCN TABLE
    (
        IdAceptacionPedido INT,
        Estatus VARCHAR(300)
    );

    DECLARE @Facturas TABLE
    (
        IdAceptacionFactura INT,
        IdAceptacionPedido INT,
        IdUnicoFactura INT,
        EstatusPago VARCHAR(MAX),
        IdEstatus INT,
        UUID_Adinco VARCHAR(500),
        IdFacturaAdinco INT,
        Subtotal FLOAT,
        MonedaFactura VARCHAR(100),
        MontoFacturadoUSD FLOAT
    );

    --OBTENER LOS PEDIDOS 
    INSERT INTO @Pedido
    (
        IdPedido,
        IdSolicitudPedido,
        IdPedidoGeneral,
        Proveedor,
        ProveedorId,
        ContratoId,
        Contrato,
        Comprador,
        EstatusAprobacion,
        EstatusConfirmacion,
        EnAprobacion,
        PedidoAprobado,
        PedidoVencido,
        PedidoEnConfirmacion,
        PedidoConfirmado,
        MontoPedido,
        Moneda,
        Corporativo,
        ProveedorClienteId,
        PorcentajeAceptadoPedido,
        TotalidadAceptada,
        FechaRegistro,
        Solicitante
    )
    SELECT P.IdPedido AS 'idpedido unico',
           P.IdSolicitudPedido AS 'idunico de requisicion',
           PS.IdPedido AS 'Numero de Pedido',
           Pr.RazonSocial AS 'Proveedor',
           Pr.IdProveedor,
           P.IdContrato,
           CO.NumeroContrato AS 'Contrato',
           U.Nombre AS 'Comprador',
           ES.Nombre AS 'Estatus Pedido',
           CASE
               WHEN P.RecepcionServicio = 1 THEN
                   'Confirmación Aceptada'
               WHEN P.RecepcionServicio = 0 THEN
                   'Confirmación Rechazada'
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0
                    AND TAO.IdEstatusOperacion = 2 THEN
                   'Confirmación Vencida'
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0
                    AND TAO.IdEstatusOperacion = 2 THEN
                   'En Confirmación'
               ELSE
                   'Confirmación No Iniciada '
           END AS 'Estatus Confirmación',
           CASE
               WHEN TAO.IdEstatusOperacion = 1 THEN
                   1
               ELSE
                   0
           END AS 'En aprobación',
           CASE
               WHEN TAO.IdEstatusOperacion = 2 THEN
                   1
               ELSE
                   0
           END AS 'Pedido aprobado',
           CASE
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0
                    AND TAO.IdEstatusOperacion = 2 THEN -->'Confirmación Vencida '
                   1
               ELSE
                   0
           END AS 'Pedido Vencido',
           CASE
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0
                    AND TAO.IdEstatusOperacion = 2 THEN --> 'En Confirmación'
                   1
               ELSE --> 'Confirmación No Iniciada '
                   0
           END AS 'Pedido en Confirmacion',
           CASE
               WHEN P.RecepcionServicio = 1 THEN --> 'Confirmación Aceptada'
                   1
               WHEN ISNULL(RecepcionServicio, 0) = 0 THEN -->  'Confirmación Rechazada'
                   0
           END AS 'Pedido confirmado',
           0 AS 'Monto Pedido',
           TM.TipoMonedaCorto AS 'Moneda',
           COR.RazonSocial AS 'Corporativo',
           P.IdProveedorCompras,
           0,
           0,
           P.CreadoEl,
           US.Nombre
    FROM @Proveedores AS PC
        JOIN dbo.S_Proveedor AS COR (NOLOCK)
            ON PC.IdProveedor = COR.IdProveedor
        JOIN MM_Pedido AS P (NOLOCK)
            ON PC.IdProveedor = P.IdProveedorCompras
        JOIN MM_Pedidos AS PS (NOLOCK)
            ON P.IdPedido = PS.IdIdentificador
               AND P.IdProveedorCompras = PS.IdProveedorCliente
        JOIN dbo.TA_Operacion TAO (NOLOCK)
            ON P.IdSolicitudPedido = TAO.IdDocumento
               AND P.Version = TAO.NoVersion --> LA VERSION DEL PEDIDO DEBE SER IGUAL AL DE LA APROBACIÓN DE PEDIDO  
               AND TAO.IdTipoOperacion = 9 --> APROBACIÓN DE TIPO PEDIDO    
        JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
            ON P.IdPedido = HV.IdPedido
        JOIN dbo.TA_Estatus AS ES (NOLOCK)
            ON TAO.IdEstatusOperacion = ES.IdEstatus
        JOIN S_Proveedor AS Pr (NOLOCK)
            ON P.IdSubcontratista = Pr.IdProveedor
        JOIN S_Usuario AS U (NOLOCK)
            ON P.CreadoPor = U.IdUsuario
        JOIN PV_TipoMoneda AS TM (NOLOCK)
            ON P.IdMoneda = TM.IdMoneda
        JOIN Adinco.dbo.CO_Contrato AS CO (NOLOCK)
            ON P.IdContrato = CO.IdContrato
        JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
            ON P.IdSolicitudPedido = SP.IdSolicitudPedido
        JOIN dbo.S_Usuario AS US (NOLOCK)
            ON SP.IdUsuarioSolicitante = US.IdUsuario
    WHERE P.IdEliminado IS NULL --> SOLO PEDIDO ACTIVOS
    GROUP BY P.IdPedido,
             P.IdSolicitudPedido,
             CAST(P.CreadoEl AS DATE),
             Pr.RazonSocial,
             U.Nombre,
             PS.IdPedido,
             ES.Nombre,
             CO.NumeroContrato,
             P.FechaEnvioPedido,
             P.RecepcionServicio,
             HV.FechaVigencia,
             TAO.IdEstatusOperacion,
             P.IdEstatusEliminado,
             COR.RazonSocial,
             P.IdContrato,
             Pr.IdProveedor,
             P.IdProveedorCompras,
             TM.TipoMonedaCorto,
             P.CreadoEl,
             US.Nombre;
    --OBTENER EL SUBTOTAL DE LOS PEDIDOS
    INSERT INTO @PedidoMonto
    (
        IdPedido,
        Monto
    )
    SELECT P.IdPedido,
           SUM(PD.Subtotal)
    FROM @Pedido P
        JOIN MM_PedidoDetalle AS PD (NOLOCK)
            ON P.IdPedido = PD.IdPedido
    GROUP BY P.IdPedido;

    --ACTUALIZAR MONTO DEL PEDIDO EN @PEDIDO
    UPDATE P
    SET MontoPedido = PM.Monto
    FROM @Pedido P
        JOIN @PedidoMonto PM
            ON P.IdPedido = PM.IdPedido;

    --OBTENER ACEPTACIONES DE PEDIDO
    INSERT INTO @AceptacionPedido
    (
        IdAceptacionPedido,
        IdPedido,
        MontoAceptado,
        Recepcionado,
        PedirCarta,
        AprobacionCNN,
        CargaFactura,
        AprobacionFactura,
        PagoRealizado,
        FlujoAceptacionTerminado,
        MontoFacturado,
        MontoFacturadoUSD,
        MontoAceptadoUSD,
        MonedaFactura
    )
    SELECT AP.IdAceptacionPedido,
           P.IdPedido,
           SUM(PD.PrecioUnitario * APD.Cantidad),
           1,
           RCN.PedirCarta,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           0,
           ''
    FROM @Pedido P
        JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
            ON P.IdPedido = AP.IdPedido
        JOIN dbo.RelacionCartaCNPedido AS RCN (NOLOCK)
            ON AP.IdAceptacionPedido = RCN.IdAceptacionPedido
        JOIN dbo.MM_AceptacionPedidoDetalle AS APD (NOLOCK)
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
        JOIN dbo.MM_PedidoDetalle AS PD (NOLOCK)
            ON P.IdPedido = PD.IdPedido
               AND APD.IdPedidoDetalle = PD.IdPedidoDetalle
    WHERE ISNULL(AP.IdEstatusEliminado, 0) <> 1 --> MOSTRAR ACEPTACIONES NO ELIMINADAS    
    GROUP BY AP.IdAceptacionPedido,
             P.IdPedido,
             RCN.PedirCarta;


    --OBTENER PORCENTAJE DE LOS PRODUCTOS ACEPTADOS
    UPDATE AP
    SET AP.PorcentajeAceptado = CASE
                                    WHEN AP.MontoAceptado > 0 THEN
        (AP.MontoAceptado * 100) / P.MontoPedido
                                    ELSE
                                        0
                                END
    FROM @AceptacionPedido AS AP
        JOIN @Pedido P
            ON AP.IdPedido = P.IdPedido;


    --OBTENER EL ESTATUS DE LA ULTIMA ACEPTACIÓN DE CNN
    INSERT INTO @Estatus
    (
        IdAceptacionPedido,
        IdAceptacionCartaPCN
    )
    SELECT AP.IdAceptacionPedido,
           MAX(ACN.IdAceptacionCartaPCN)
    FROM @AceptacionPedido AS AP
        JOIN MM_AceptacionCartaPCN AS ACN (NOLOCK)
            ON AP.IdAceptacionPedido = ACN.IdAceptacionPedido
    GROUP BY AP.IdAceptacionPedido;


    --OBTENER EL ESTATUS DE LA CNN
    INSERT INTO @CCN
    (
        IdAceptacionPedido,
        Estatus
    )
    SELECT AP.IdAceptacionPedido,
           TV.TipoValidacion
    FROM @AceptacionPedido AS AP
        JOIN @Estatus E
            ON E.IdAceptacionPedido = AP.IdAceptacionPedido
        JOIN MM_AceptacionCartaPCN AS ACN (NOLOCK)
            ON E.IdAceptacionCartaPCN = ACN.IdAceptacionCartaPCN
        JOIN S_TipoValidacionDoc AS TV (NOLOCK)
            ON ACN.IdEstatus = TV.IdTipoValidacionDoc;



    ---ACTUALIZAR ESTATUS PARA CNN APROBADAS Y SI YA SE CARGO LA CARTA DE CNN
    UPDATE AP
    SET AP.AprobacionCNN = CASE
                               WHEN CCN.Estatus = 'Aprobada' THEN
                                   1
                               ELSE
                                   0
                           END,
        AP.CargaCNN = CASE
                          WHEN CCN.Estatus = 'Aprobada'
                               OR CCN.Estatus = 'En Aprobación' THEN
                              1
                          ELSE
                              0
                      END
    FROM @AceptacionPedido AP
        JOIN @CCN CCN
            ON AP.IdAceptacionPedido = CCN.IdAceptacionPedido;


    --SIMULAR CARTA CNN DONDE NO SE SOLICITO         
    UPDATE AP
    SET AP.AprobacionCNN = 1,
        AP.CargaCNN = 1
    FROM @AceptacionPedido AS AP
    WHERE AP.PedirCarta = 0; --> CARTA NO SOLICITADA

    --OBTENER INFORMACIÓN DE ACEPTACIONES QUE YA TIENE FACTURA
    INSERT INTO @Facturas
    (
        IdAceptacionFactura,
        IdAceptacionPedido,
        IdUnicoFactura,
        EstatusPago,
        IdEstatus,
        UUID_Adinco,
        Subtotal
    )

    --OBTENER TODAS LAS APROBACIONES DE FACTURA
    SELECT AF.IdAceptacionFactura,
           AP.IdAceptacionPedido AS 'IdAceptacionPedido',
           FI.IdFactura AS 'Idunicofactura',
           'No Pagado',
           O.IdEstatusOperacion,
           FI.UUID,
           FI.SubTotal
    FROM @AceptacionPedido AS AP
        JOIN MM_AceptacionFactura AS AF (NOLOCK)
            ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
        JOIN TA_Operacion AS O (NOLOCK)
            ON AF.IdAceptacionFactura = O.IdDocumento
               AND O.IdTipoOperacion = 10 --> APROBACIÓN DE TIPO APROBACIÓN DE FACTURA     
        JOIN dbo.TA_FlujoTarea FT (NOLOCK)
            ON O.IdFlujoTarea = FT.IdFlujoTarea
        JOIN TA_Estatus AS E (NOLOCK)
            ON O.IdEstatusOperacion = E.IdEstatus
        LEFT JOIN FI_Factura AS FI (NOLOCK)
            ON AF.IdFactura = FI.IdFactura
    WHERE ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> ACEPTACIÓN DE FACTURA NO ESTE ELIMINADA  
    GROUP BY AP.IdAceptacionPedido,
             AF.IdAceptacionFactura,
             E.Nombre,
             FI.IdFactura,
             O.IdEstatusOperacion,
             FI.UUID,
             FI.SubTotal;

    --OBTENER ESTATUS DE PAGO
    --OBTENER EL ESTATUS DE PAGO SI AL MENOS TIENE UN COMPROBANTE DE PAGO SE PUEDE TOMAR QUE ESTA CON UN ESTATUS PAGADO
    --INFORMACIÓN DE TABLA DE BI_FACTURA
    UPDATE AF
    SET AF.EstatusPago = BF.EstatusPago,
        AF.MonedaFactura = BF.MonedaFactura,
        AF.MontoFacturadoUSD = BF.MontoFacturacionUSD
    FROM @Facturas AS AF
        INNER JOIN dbo.BI_Facturas AS BF (NOLOCK)
            ON AF.IdAceptacionPedido = BF.IdAceptacionPedido;

    --ACTUALIZAR ESTATUS DE CARGA DE FACTURA CUANDO LA FACTURA YA ESTA EN APROBACIÓN O ESTA APROBADA
    --ACTUALIZAR ESTATUS DE PAGO SI LA FACTURA YA TIENE UN PAGO
    --ACTUALIZAR ESTATUS DE APROBACIÓN SI LA FACTURA YA ESTA APROBADA
    UPDATE AP
    SET AP.CargaFactura = CASE
                              WHEN AF.IdEstatus IN ( 1, 2 ) THEN --> FACTURA CARGADA SI ESTA EN APROBACIÓN(1) O ESTA APROBADA(2)
                                  1
                              ELSE
                                  0
                          END,
        AP.AprobacionFactura = CASE
                                   WHEN AF.IdEstatus IN ( 2 ) THEN --> FACTURA APROBADA SI ESTA EN ESTATUS 2 = APROBADA
                                       1
                                   ELSE
                                       0
                               END,
        AP.PagoRealizado = CASE
                               WHEN AF.EstatusPago = 'Pagado' THEN
                                   1
                               ELSE
                                   0
                           END,
        AP.MontoFacturado = AF.Subtotal,
        AP.MonedaFactura = AF.MonedaFactura,
        AP.MontoFacturadoUSD = AF.MontoFacturadoUSD
    FROM @AceptacionPedido AS AP
        JOIN @Facturas AS AF
            ON AP.IdAceptacionPedido = AF.IdAceptacionPedido;


    --MARCAR COMO FLUJO REALIZADO SI LA ACEPTACIÓN YA TIENE UN PAGO
    UPDATE AP
    SET FlujoAceptacionTerminado = CASE
                                       WHEN AP.PagoRealizado = 1 THEN
                                           1
                                       ELSE
                                           0
                                   END
    FROM @AceptacionPedido AS AP;


    --OBTENER PORCENTAJES DE ACEPTACIÓN POR PEDIDO
    INSERT INTO @PedidoAceptado
    (
        IdPedido,
        PorcentajeAceptado
    )
    SELECT P.IdPedido,
           SUM(AP.PorcentajeAceptado)
    FROM @Pedido AS P
        JOIN @AceptacionPedido AS AP
            ON P.IdPedido = AP.IdPedido
    GROUP BY P.IdPedido;


    ---ACTUALIZAR PORCENTAJE ACEPTADO POR PEDIDO
    UPDATE P
    SET P.PorcentajeAceptadoPedido = PA.PorcentajeAceptado,
        P.TotalidadAceptada = (CASE
                                   WHEN ISNULL(PA.PorcentajeAceptado, 0) >= 100 THEN
                                       1
                                   ELSE
                                       0
                               END
                              )
    FROM @Pedido AS P
        JOIN @PedidoAceptado AS PA
            ON P.IdPedido = PA.IdPedido;

    --OBTENER VALOR DEL DOLAR POR PEDIDO QUE ESTE EN MXN
    INSERT INTO @PedidoPrecioDLS
    (
        IdPedido,
        PrecioDolar
    )
    SELECT P.IdPedido,
           TC.TipoCambio
    FROM @Pedido AS P
        JOIN Adinco.dbo.CO_TipoCambioDiario AS TC (NOLOCK)
            ON CAST(P.FechaRegistro AS DATE) = TC.Fecha  
    WHERE P.Moneda = 'MXN'
          AND TC.IdMoneda = 1 --> USD
    GROUP BY P.IdPedido,
             TC.TipoCambio;

    --ACTUALIZAR MONTOS PEDIDO USD DE PEDIDO

    UPDATE P
    SET P.MontoPedidoUSD = (CASE
                                WHEN P.Moneda = 'MXN' THEN
        (P.MontoPedido/PD.PrecioDolar)
                                ELSE
                                    P.MontoPedido
                            END
                           )
    FROM @Pedido AS P
        LEFT JOIN @PedidoPrecioDLS AS PD
            ON P.IdPedido = PD.IdPedido;


    --ACTUALIZAR MONTO ACEPTACION PEDIDO USD
    UPDATE AP
    SET AP.MontoAceptadoUSD = (CASE
                                   WHEN P.Moneda = 'MXN' THEN
        (AP.MontoAceptado/PD.PrecioDolar)
                                   ELSE
                                       AP.MontoAceptado --> ES USD 
                               END
                              )
    FROM @AceptacionPedido AS AP
        JOIN @Pedido AS P
            ON AP.IdPedido = P.IdPedido
        LEFT JOIN @PedidoPrecioDLS AS PD
            ON P.IdPedido = PD.IdPedido;

    --OBTENER VALOR DE QUE USUARIO(O=OPERADOR;P=PROVEEDOR) DEBE ALGUN PROCESO 
    --VALIDAR SI YA FUE APROBADO EL PEDIDO
    UPDATE P
    SET QuienDebe = 'O'
    FROM @Pedido P
    WHERE ISNULL(P.PedidoAprobado, 0) = 0
          AND P.QuienDebe IS NULL;

    --VALIDAR SI YA FUE CONFIRMADO EL PEDIDO
    UPDATE P
    SET QuienDebe = 'P'
    FROM @Pedido P
    WHERE ISNULL(P.PedidoConfirmado, 0) = 0
          AND P.QuienDebe IS NULL;

    --VALIDAR SI YA SE CARGO CNN
    UPDATE AP
    SET AP.QuienDebe = 'P'
    FROM @AceptacionPedido AP
    WHERE AP.QuienDebe IS NULL
          AND ISNULL(AP.CargaCNN, 0) = 0;

    --VALIDAR SI YA SE APROBO CNN
    UPDATE AP
    SET AP.QuienDebe = 'O'
    FROM @AceptacionPedido AP
    WHERE AP.QuienDebe IS NULL
          AND ISNULL(AP.AprobacionCNN, 0) = 0;

    --VALIDAR SI YA SE CARGO FACTURA 
    UPDATE AP
    SET AP.QuienDebe = 'P'
    FROM @AceptacionPedido AP
    WHERE AP.QuienDebe IS NULL
          AND ISNULL(AP.CargaFactura, 0) = 0;

    --VALIDAR SI YA SE APROBO FACTURA
    UPDATE AP
    SET AP.QuienDebe = 'O'
    FROM @AceptacionPedido AP
    WHERE AP.QuienDebe IS NULL
          AND ISNULL(AP.AprobacionFactura, 0) = 0;

    --VALIDAR SI YA SE CARGO UN PAGO
    UPDATE AP
    SET AP.QuienDebe = 'O'
    FROM @AceptacionPedido AP
    WHERE AP.QuienDebe IS NULL
          AND ISNULL(AP.PagoRealizado, 0) = 0;


    TRUNCATE TABLE BI_AvancePedido;
    INSERT INTO BI_AvancePedido
    (
        IdPedido,
        IdPedidoGeneral,
        IdSolicitudPedido,
        Proveedor,
        Corporativo,
        Contrato,
        EstatusAprobacion,
        EstatusConfirmacion,
        TotalidadAceptada,
        PorcentajeAceptadoPedido,
        IdAceptacionPedido,
        PorcentajeAceptado,
        PedidoAprobado,
        PedidoConfirmado,
        Recepcionado,
        CargaCNN,
        AprobacionCNN,
        CargaFactura,
        AprobacionFactura,
        PagoRealizado,
        MontoAceptado,
        MontoFacturado,
        MontoPedido,
        Moneda,
        FlujoAceptacionTerminado,
        QuienDebe,
        MontoPedidoUSD,
        MontoAceptadoUSD,
        MontoFacturadoUSD,
        MonedaFactura,
        FechaRegistro,
        Solicitante
    )
    SELECT P.IdPedido AS 'Id Pedido Interno',
           P.IdPedidoGeneral AS 'No Pedido',
           P.IdSolicitudPedido AS 'No Requisición',
           P.Proveedor AS 'Proveedor',
           P.Corporativo AS 'Corporativo',
           P.Contrato AS 'Contrato',
           P.EstatusAprobacion AS 'Estatus aprobación',
           P.EstatusConfirmacion AS 'Estatus confirmación',
           P.TotalidadAceptada AS 'Total recepcionado',
           P.PorcentajeAceptadoPedido AS 'Porcentaje pedido recepcionado',
           ISNULL(AP.IdAceptacionPedido, 0) AS 'No Aceptación pedido',
           ISNULL(AP.PorcentajeAceptado, 0) AS 'Porcentaje aceptado',
           P.PedidoAprobado AS 'Pedido aprobado',                 --O	
           P.PedidoConfirmado AS 'Pedido confirmado',             --P
           ISNULL(AP.Recepcionado, 0) AS 'Recepcionado',          --O
           ISNULL(AP.CargaCNN, 0) AS 'Carga de CNN',              --P	 
           ISNULL(AP.AprobacionCNN, 0) AS 'CNN Aprobada',         --O
           ISNULL(AP.CargaFactura, 0) AS 'Carga de factura',      --P		 
           ISNULL(AP.AprobacionFactura, 0) AS 'Factura aprobada', --O
           ISNULL(AP.PagoRealizado, 0) AS 'Pago realizado',       --O
           ISNULL(AP.MontoAceptado, 0) AS 'Monto aceptado',
           ISNULL(AP.MontoFacturado, 0) AS 'Monto facturado',
           P.MontoPedido AS 'Monto pedido',
           P.Moneda AS 'Moneda pedido',
           ISNULL(AP.FlujoAceptacionTerminado, 0) AS 'Flujo de aceptación terminado',
           CASE
               WHEN P.QuienDebe IS NOT NULL THEN
                   P.QuienDebe
               WHEN P.QuienDebe IS NULL
                    AND AP.IdAceptacionPedido IS NULL THEN
                   'O' --> El operador ya que ya esta aprobado y confirmado el pedido y no se realizado nunguna recepción
               ELSE
                   AP.QuienDebe
           END AS 'Proceso detenido por',
           P.MontoPedidoUSD AS 'Monto pedido USD',
           ISNULL(AP.MontoAceptadoUSD, 0) AS 'Monto aceptado USD',
           ISNULL(AP.MontoFacturadoUSD, 0) AS 'Monto facturado USD',
           ISNULL(AP.MonedaFactura, '') AS 'Moneda facura',
           P.FechaRegistro AS 'Fecha registro',
           P.Solicitante AS 'Solicitante'
    FROM @Pedido P
        LEFT JOIN @AceptacionPedido AP
            ON P.IdPedido = AP.IdPedido;

    -- PEDIDO CON FACTURA APROBADA
    UPDATE BP
    SET BP.EstatusAvancePedido = 'Factura Aprobada',
        BP.ValorEstatus = BP.MontoFacturado,
        BP.ValorEstatusUSD = BP.MontoFacturadoUSD
    FROM BI_AvancePedido BP
    WHERE BP.AprobacionFactura = 1;


    -- PEDIDO CON FACTURA EN APROBACIÓN
    UPDATE BP
    SET BP.EstatusAvancePedido = 'Aprobación Fact',
        BP.ValorEstatus = BP.MontoFacturado,
        BP.ValorEstatusUSD = BP.MontoFacturadoUSD
    FROM BI_AvancePedido BP
        JOIN @Facturas F
            ON BP.IdAceptacionPedido = F.IdAceptacionPedido
    WHERE F.IdEstatus = 1; --> En aprobación SELECT * FROM TA_Estatus

    --PEDIDO CON FACTURA PENDIENTE DE CARGAR POR PARTE DEL PROVEEDOR 
    UPDATE BP
    SET BP.EstatusAvancePedido = 'Ingreso Factura',
        BP.ValorEstatus = BP.MontoAceptado,
        BP.ValorEstatusUSD = BP.MontoAceptadoUSD
    FROM BI_AvancePedido BP
    WHERE BP.AprobacionCNN = 1
          AND BP.CargaCNN = 1
          AND BP.Recepcionado = 1
          AND BP.AprobacionFactura = 0;

	-- PEDIDO CON FACTURA EN APROBACIÓN
    UPDATE BP
    SET BP.EstatusAvancePedido = 'Factura Rechazada',
        BP.ValorEstatus = BP.MontoFacturado,
        BP.ValorEstatusUSD = BP.MontoFacturadoUSD
    FROM BI_AvancePedido BP
        JOIN @Facturas F
            ON BP.IdAceptacionPedido = F.IdAceptacionPedido
    WHERE F.IdEstatus = 3; --> Rechazada SELECT * FROM TA_Estatus

    -- PEDIDO CON CARTA DE CONTENIDO NACIONAL EN APROBACIÓN
    UPDATE BP
    SET BP.EstatusAvancePedido = 'Aprobación CN',
        BP.ValorEstatus = BP.MontoAceptado,
        BP.ValorEstatusUSD = BP.MontoAceptadoUSD
    FROM BI_AvancePedido BP
        JOIN @CCN CN
            ON BP.IdAceptacionPedido = CN.IdAceptacionPedido
    WHERE CN.Estatus = 'En Aprobación'
          AND BP.CargaCNN = 1;

	-- PEDIDO CON CARTA DE CONTENIDO NACIONAL RECHAZADA
    UPDATE BP
    SET BP.EstatusAvancePedido = 'Rechazo Carta de Contenido',
        BP.ValorEstatus = BP.MontoAceptado,
        BP.ValorEstatusUSD = BP.MontoAceptadoUSD
    FROM BI_AvancePedido BP
        JOIN @CCN CN
            ON BP.IdAceptacionPedido = CN.IdAceptacionPedido
    WHERE CN.Estatus = 'Rechazada'
          AND BP.CargaCNN = 1;

    --PEDIDOS RECEPCIONADOS PERO QUE AÚN NO TIENE UNA CARTA DE CONTENIDO NACIONAL
    UPDATE BP
    SET BP.EstatusAvancePedido = 'Recepcionado',
        BP.ValorEstatus = BP.MontoAceptado,
        BP.ValorEstatusUSD = BP.MontoAceptadoUSD
    FROM BI_AvancePedido BP
    WHERE BP.Recepcionado = 1
          AND BP.CargaCNN = 0;

    --CON RECEPCIÓN PERO SIN CARTA DE CONTENIDO NACIONAL
    UPDATE BP
    SET BP.EstatusAvancePedido = 'Ingreso CN',
        BP.ValorEstatus = BP.MontoAceptado,
        BP.ValorEstatusUSD = BP.MontoAceptadoUSD
    FROM BI_AvancePedido BP
    WHERE BP.Recepcionado = 1
          AND BP.CargaCNN = 0
          AND BP.EstatusAvancePedido IS NULL;

    --PEDIDOS QUE YA FUERON ACEPTADOS POR EL PROVEEDOR, PERO NO TIENE NINGUNA RECEPCIÓN
    UPDATE BP
    SET BP.EstatusAvancePedido = 'On going', --'Sin entrega/recepción',
        BP.ValorEstatus = BP.MontoPedido,
        BP.ValorEstatusUSD = BP.MontoPedidoUSD
    FROM BI_AvancePedido BP
    WHERE BP.Recepcionado = 0
          AND BP.PedidoConfirmado = 1;

    --PEDIDOS EN ACEPTACIÓN POR EL PROVEEDOR (EN CONFIRMACIÓN DE PEDIDO)
    UPDATE BP
    SET BP.EstatusAvancePedido = 'On going',
        BP.ValorEstatus = BP.MontoPedido,
        BP.ValorEstatusUSD = BP.MontoPedidoUSD
    FROM BI_AvancePedido BP
    WHERE BP.EstatusConfirmacion = 'En Confirmación'
          OR BP.EstatusConfirmacion = 'Confirmación Vencida';

    --PEDIDOS EN APROBACIÓN 
    UPDATE BP
    SET BP.EstatusAvancePedido = 'En aprobación',
        BP.ValorEstatus = BP.MontoPedido,
        BP.ValorEstatusUSD = BP.MontoPedidoUSD
    FROM BI_AvancePedido BP
    WHERE BP.EstatusAprobacion = 'En Aprobación';

	----PEDIDOS CON CONFIRMACIÓN RECHAZADA 
 --   UPDATE BP
 --   SET BP.EstatusAvancePedido = 'Confirmación Rechazada',
 --       BP.ValorEstatus = BP.MontoPedido,
 --       BP.ValorEstatusUSD = BP.MontoPedidoUSD
 --   FROM BI_AvancePedido BP
 --   WHERE BP.EstatusConfirmacion = 'Confirmación Rechazada';

	----PEDIDOS CON APROBACIÓN RECHAZADA 
 --   UPDATE BP
 --   SET BP.EstatusAvancePedido = 'Aprobación Rechazada',
 --       BP.ValorEstatus = BP.MontoPedido,
 --       BP.ValorEstatusUSD = BP.MontoPedidoUSD
 --   FROM BI_AvancePedido BP
 --   WHERE BP.EstatusAprobacion = 'Rechazada';

	--NOMBRES EN LA VISTA
	--ValorEstatus --> Valor estatus
	--ValorEstatusUSD  --> Valor estatus USD

END;


