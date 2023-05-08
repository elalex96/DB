CREATE PROCEDURE dbo.sp_BI_LlenaTabla_BI_Facturas
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AprobadoresF TABLE
    (
        IdAceptacionFactura INT,
        AprobadorActual VARCHAR(6000),
        NoSecuenciaInicial INT
    );

    DECLARE @Aprobadores TABLE
    (
        IdAceptacionFactura INT,
        AprobadorActual VARCHAR(6000),
        NoSecuencia INT,
        IdTipoFlujo INT
    );

    DECLARE @PedidoPrecioDLS AS TABLE
    (
        IdPedido INT,
        PrecioDolar FLOAT
    );

    DECLARE @FacturaPrecioDLS AS TABLE
    (
        IdFactura INT,
        PrecioDolar FLOAT
    );

    DECLARE @Facturas TABLE
    (
        IdAceptacionFactura INT,
        IdSolicitudPedido INT,
        IdAceptacionPedido INT,
        IdUnicoFactura INT,
        FechaCarga DATE,
        FechaAprobacion DATE,
        EstatusPedido VARCHAR(MAX),
        EstatusPago VARCHAR(MAX),
        IdEstatus INT,
        UUID_Adinco VARCHAR(500),
        IdOperacion INT,
        IdTipoFlujoAprobacion INT,
        IdPedido INT,
        FechaRechazo DATETIME,
        MontoAceptado FLOAT,
        MontoFacturacion FLOAT,
        IdFacturaAdinco INT,
        Contrato VARCHAR(MAX),
        IdPedidoInterno INT,
        RazonSocial VARCHAR(MAX),
        FolioFactura VARCHAR(1000),
        DiasCredito INT,
        CondicionPago VARCHAR(1000),
        MonedaFactura VARCHAR(100),
        MonedaPedido VARCHAR(100),
        RegistroPedido DATETIME,
        FechaTimbrado DATETIME,
        IdMonedaFactura INT
    );

    DECLARE @MontoAceptacion TABLE
    (
        IdAceptacionPedido INT,
        MontoAceptacion FLOAT
    );

    DECLARE @PedidoCondicionPago TABLE
    (
        IdPedido INT,
        CondicionPago VARCHAR(1000),
        DiasCredito INT
    );

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

    INSERT INTO @Facturas
    (
        IdAceptacionFactura,
        IdSolicitudPedido,
        IdAceptacionPedido,
        IdUnicoFactura,
        FechaCarga,
        FechaAprobacion,
        EstatusPedido,
        EstatusPago,
        IdEstatus,
        UUID_Adinco,
        IdOperacion,
        IdTipoFlujoAprobacion,
        IdPedido,
        MontoFacturacion,
        FechaRechazo,
        Contrato,
        IdPedidoInterno,
        RazonSocial,
        FolioFactura,
        CondicionPago,
        DiasCredito,
        MonedaFactura,
        MonedaPedido,
        RegistroPedido,
        FechaTimbrado,
        IdMonedaFactura
    )
    --OBTENER TODAS LAS APROBACIONES DE FACTURA
    SELECT AF.IdAceptacionFactura,
           PE.IdSolicitudPedido AS 'id de requisicion',
           AP.IdAceptacionPedido AS 'IdAceptacionPedido',
           fi.IdFactura AS 'Idunicofactura',
           CAST(O.FechaRegistro AS DATE) AS 'Fecha de carga',
           CASE
               WHEN O.IdEstatusOperacion = 1 THEN --> SI ESTA EN APROBACIÓN NO MOSTRAR FECHA DE MODIFICACIÓN
                   NULL
               ELSE
                   CAST(O.FechaModificacion AS DATE)
           END AS 'Fecha de aprobacion',
           E.Nombre AS 'Estatus factura',
           '',
           O.IdEstatusOperacion,
           fi.UUID,
           O.IdOperacion,
           FT.IdTipoFlujo,
           PG.IdPedido,
           fi.SubTotal,
           CASE
               WHEN O.IdEstatusOperacion = 3 THEN --> SI ESTA RECHAZADA MOSTRAR FECHA DE MODIFICACIÓN
                   O.FechaModificacion
               ELSE
                   NULL
           END AS 'Fecha de rechazo',
           CO.NumeroContrato,
           PE.IdPedido,
           PR.RazonSocial AS RazonSocial,
           fi.Folio,
           CASE
               WHEN PE.UnicaCondicionPago = 1 THEN
                   ''
               ELSE
                   'Condiciones diferidas por partida'
           END,
           0,
           fi.Moneda,
           TM.TipoMonedaCorto,
           PE.CreadoEl,
           fi.FechaTimbrado,
           fi.IdMoneda
    FROM MM_AceptacionFactura AS AF (NOLOCK)
        JOIN TA_Operacion AS O (NOLOCK)
            ON AF.IdAceptacionFactura = O.IdDocumento
               AND O.IdTipoOperacion = 10 --> APROBACIÓN DE TIPO APROBACIÓN DE FACTURA 
        JOIN dbo.TA_FlujoTarea FT (NOLOCK)
            ON O.IdFlujoTarea = FT.IdFlujoTarea
        JOIN TA_Estatus AS E (NOLOCK)
            ON O.IdEstatusOperacion = E.IdEstatus
        JOIN MM_AceptacionPedido AS AP (NOLOCK)
            ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
        JOIN MM_Pedido AS PE (NOLOCK)
            ON AP.IdPedido = PE.IdPedido
               AND O.IdProveedor = PE.IdSubcontratista
        JOIN dbo.PV_TipoMoneda AS TM (NOLOCK)
            ON PE.IdMoneda = TM.IdMoneda
        JOIN Adinco..CO_Contrato CO
            ON PE.IdContrato = CO.IdContrato
        JOIN @Proveedores PC
            ON PE.IdProveedorCompras = PC.IdProveedor
        JOIN MM_Pedidos AS PG (NOLOCK)
            ON PE.IdPedido = PG.IdIdentificador
               AND PE.IdProveedorCompras = PG.IdProveedorCliente
        JOIN S_Proveedor AS PR (NOLOCK)
            ON PE.IdSubcontratista = PR.IdProveedor
        LEFT JOIN dbo.FI_Factura AS fi (NOLOCK)
            ON AF.IdFactura = fi.IdFactura
    WHERE ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> ACEPTACIÓN DE FACTURA NO ESTE ELIMINADA 
    GROUP BY AF.IdAceptacionPedido,
             AP.IdAceptacionPedido,
             AF.IdAceptacionFactura,
             O.FechaRegistro,
             E.Nombre,
             PE.IdSolicitudPedido,
             fi.IdFactura,
             O.FechaModificacion,
             O.IdEstatusOperacion,
             fi.UUID,
             O.IdOperacion,
             FT.IdTipoFlujo,
             PG.IdPedido,
             fi.SubTotal,
             CO.NumeroContrato,
             PE.IdPedido,
             PR.RazonSocial,
             fi.Folio,
             PE.UnicaCondicionPago,
             fi.Moneda,
             TM.TipoMonedaCorto,
             PE.CreadoEl,
             fi.FechaTimbrado,
             fi.IdMoneda;

    --OBTENER CONDICIONES DE PAGO DE LA ACEPTACIÓN MEDIANTE LA RELACIÓN CON EL PEDIDO 
    INSERT INTO @PedidoCondicionPago
    (
        IdPedido,
        CondicionPago,
        DiasCredito
    )
    SELECT FP.IdPedidoInterno,
           CP.CondicionPago,
           CASE
               WHEN PD.IdCondicionPago = 1 THEN --> CREDITO
                   PD.DiasCredito
               ELSE
                   0
           END
    FROM @Facturas FP
        JOIN dbo.MM_PedidoDetalle PD (NOLOCK)
            ON FP.IdPedidoInterno = PD.IdPedido
        JOIN dbo.MM_CondicionPago CP (NOLOCK)
            ON PD.IdCondicionPago = CP.IdCondicionPago
    WHERE FP.CondicionPago = '' --> DONDE LA CONDICIÓN NO SEA Condiciones diferidas por partida
    GROUP BY FP.IdPedidoInterno,
             PD.DiasCredito,
             CP.CondicionPago,
             PD.IdCondicionPago;

    --ACTUALIZAR CONDICIONES DE PAGO
    UPDATE FP
    SET FP.CondicionPago = PCP.CondicionPago,
        FP.DiasCredito = PCP.DiasCredito
    FROM @Facturas FP
        INNER JOIN @PedidoCondicionPago PCP
            ON FP.IdPedidoInterno = PCP.IdPedido;

    --OBTENER MONTOS DE ACEPTACIÓN
    INSERT INTO @MontoAceptacion
    (
        IdAceptacionPedido,
        MontoAceptacion
    )
    SELECT F.IdAceptacionPedido,
           SUM(APD.Cantidad * PD.PrecioUnitario)
    FROM @Facturas F
        JOIN dbo.MM_AceptacionPedidoDetalle APD (NOLOCK)
            ON F.IdAceptacionPedido = APD.IdAceptacionPedido
               AND ISNULL(APD.IdEstatusEliminado, 0) = 0
        JOIN dbo.MM_PedidoDetalle PD (NOLOCK)
            ON APD.IdPedidoDetalle = PD.IdPedidoDetalle
    GROUP BY F.IdAceptacionPedido;

    UPDATE F
    SET F.MontoAceptado = MAP.MontoAceptacion
    FROM @Facturas F
        JOIN @MontoAceptacion MAP
            ON F.IdAceptacionPedido = MAP.IdAceptacionPedido;

    -- OBTENER EL APROBADOR ACTUAL DE LA FACTURA 
    INSERT INTO @Aprobadores
    (
        IdAceptacionFactura,
        AprobadorActual,
        NoSecuencia,
        IdTipoFlujo
    )
    SELECT AF.IdAceptacionFactura,
           U.Nombre,
           TA.NoSecuencia,
           AF.IdTipoFlujoAprobacion
    FROM @Facturas AF
        JOIN dbo.TA_Tarea TA (NOLOCK)
            ON AF.IdOperacion = TA.IdOperacion
               AND TA.IdEstatus = 1 --> ESTATUS DE APROBADORES EN APROBACIÓN
               AND TA.Activo = 1 --> APROBADOR ACTIVO        
        JOIN dbo.S_Usuario U (NOLOCK)
            ON TA.IdAprobador = U.IdUsuario
    WHERE AF.IdEstatus = 1; --> APROBACIÓNES DE FACTURA EN APROBACIÓN 

    --AGREGAR APROBADORES SERIALES --> OBTENER EL DE MENOR SECUENCIA 
    INSERT INTO @AprobadoresF
    (
        IdAceptacionFactura,
        AprobadorActual,
        NoSecuenciaInicial
    )
    SELECT A.IdAceptacionFactura,
           '',
           MIN(A.NoSecuencia)
    FROM @Aprobadores A
    WHERE A.IdTipoFlujo = 1 -->  FLUJO SERIAL 
    GROUP BY A.IdAceptacionFactura;

    UPDATE AR
    SET AR.AprobadorActual = A.AprobadorActual
    FROM @AprobadoresF AR
        JOIN @Aprobadores A
            ON AR.IdAceptacionFactura = A.IdAceptacionFactura
               AND AR.NoSecuenciaInicial = A.NoSecuencia;

    --OBTENER LOS APROBADORES PARALELOS CONCATENADOS 
    INSERT INTO @AprobadoresF
    (
        IdAceptacionFactura,
        AprobadorActual,
        NoSecuenciaInicial
    )
    SELECT A.IdAceptacionFactura,
           (
               SELECT STUFF(
                      (
                          SELECT ', ' + AI.AprobadorActual
                          FROM @Aprobadores AI
                          WHERE A.IdAceptacionFactura = AI.IdAceptacionFactura
                          ORDER BY AI.NoSecuencia ASC
                          FOR XML PATH('')
                      ),
                      1,
                      2,
                      ''
                           )
           ),
           0
    FROM @Aprobadores A
    WHERE A.IdTipoFlujo = 2 --> FLUJO PARALELO
    GROUP BY A.IdAceptacionFactura;

    UPDATE AF
    SET AF.IdFacturaAdinco = FA.IdFactura
    FROM @Facturas AF
        JOIN Adinco.dbo.FI_Factura (NOLOCK) AS FA
            ON AF.UUID_Adinco = FA.UUID COLLATE Modern_Spanish_CI_AS
    WHERE AF.IdEstatus = 2; -->  QUE LA FACTURA ESTE APROBADA 

    --OBTENER EL ESTATUS DE PAGO SI AL MENOS TIENE UNA FACTURA SE PUEDE TOMAR QUE ESTA CON UN ESTATUS PAGADO
    UPDATE AF
    SET AF.EstatusPago = (CASE
                              WHEN (TR.AWSPDFId IS NULL) THEN
                                  'No Pagado'
                              WHEN (TR.AWSPDFId IS NOT NULL) THEN
                                  'Pagado'
                          END
                         )
    FROM @Facturas AF
        LEFT JOIN Adinco.dbo.FI_TransferFactura (NOLOCK) AS TRF
            ON AF.IdFacturaAdinco = TRF.IdFactura
        LEFT JOIN Adinco.dbo.FI_Transfer (NOLOCK) AS TR
            ON TRF.IdTransfer = TR.IdTransferencia
    WHERE AF.IdEstatus = 2; -->  QUE LA FACTURA ESTE APROBADA 


    --OBTENER EL ESTATUS DE PAGO SI AL MENOS TIENE UN COMPROABNTE DE PAGO SE PUEDE TOMAR QUE ESTA CON UN ESTATUS PAGADO
    --ESTA APLICA SOLO PARA LAS FACTURAS PDD POR SI TIENE RELACIONADO A UN COMPLEMENTO DE PAGO
    UPDATE AF
    SET AF.EstatusPago = (CASE
                              WHEN (TR.AWSPDFId IS NOT NULL) THEN
                                  'Pagado'
                          END
                         )
    FROM @Facturas AF
        JOIN Adinco.dbo.FI_CPDocRelacionado dr (NOLOCK)
            ON AF.UUID_Adinco = dr.IdDocumento COLLATE Modern_Spanish_CI_AS
        JOIN Adinco.dbo.FI_ComplementoDePago cp (NOLOCK)
            ON dr.IdComplementoDePago = cp.IdComplementoDePago
        JOIN Adinco.dbo.FI_TransferFactura AS TRF (NOLOCK)
            ON cp.IdFactura = TRF.IdFactura
        JOIN Adinco.dbo.FI_Transfer AS TR (NOLOCK)
            ON TRF.IdTransfer = TR.IdTransferencia
    WHERE AF.IdEstatus = 2; -->  QUE LA FACTURA ESTE APROBADA 

    --OBTENER PRECIO DEL DOLAR PARA LOS PEDIDOS EN MXN
    INSERT INTO @PedidoPrecioDLS
    (
        IdPedido,
        PrecioDolar
    )
    SELECT F.IdPedidoInterno,
           TC.TipoCambio
    FROM @Facturas F
        JOIN Adinco.dbo.CO_TipoCambioDiario AS TC (NOLOCK)
            ON CAST(F.RegistroPedido AS DATE)= TC.Fecha
    WHERE F.MonedaPedido = 'MXN'
          AND TC.IdMoneda = 1 --> USD
    GROUP BY F.IdPedidoInterno,
             TC.TipoCambio;
    --OBTENER PRECIO DEL DOLAR PARA LAS FACTURAS EN MXN 

    INSERT INTO @FacturaPrecioDLS
    (
        IdFactura,
        PrecioDolar
    )
    SELECT F.IdUnicoFactura,
           TC.TipoCambio
    FROM @Facturas F
        JOIN Adinco.dbo.CO_TipoCambioDiario AS TC (NOLOCK)
            ON CAST(F.FechaTimbrado AS DATE)=TC.Fecha
    WHERE F.IdMonedaFactura = 1 --> MXN'S 	 
          AND TC.IdMoneda = 1 --> USD		  
    GROUP BY F.IdUnicoFactura,
             TC.TipoCambio;	

    TRUNCATE TABLE BI_Facturas;
    INSERT INTO BI_Facturas
    (
        IdSolicitudPedido,
        IdAceptacionPedido,
        IdUnicoFactura,
        FechaCarga,
        FechaAprobacion,
        EstatusPedido,
        EstatusPago,
        AprobadorActual,
        IdPedido,
        FechaRechazo,
        MontoAceptado,
        MontoFacturacion,
        Contrato,
        IdPedidoInterno,
        RazonSocial,
        FacturaFolio,
        UUID,
        CondicionPago,
        DiasCredito,
        MonedaFactura,
        MonedaPedido,
        MontoAceptadoUSD,
        MontoFacturacionUSD		
    )
    SELECT F.IdSolicitudPedido AS 'idunico de requisicion',
           F.IdAceptacionPedido AS 'IdAceptaciónPedido',
           F.IdUnicoFactura AS 'Idunicofactura',
           F.FechaCarga AS 'Fecha de Carga',
           F.FechaAprobacion AS 'Fecha de Aprobacion',
           F.EstatusPedido 'Estatus de factura',
           F.EstatusPago AS 'Estatus Pago',
           A.AprobadorActual AS 'Aprobador Actual',
           F.IdPedido AS 'No Pedido',
           F.FechaRechazo AS 'Fecha Rechazo',
           F.MontoAceptado AS 'Monto Aceptado',
           F.MontoFacturacion AS 'Monto Facturado',
           F.Contrato,
           F.IdPedidoInterno,
           F.RazonSocial AS 'Razon social',
           F.FolioFactura AS 'Numero Factura',
           F.UUID_Adinco AS 'UUID',
           F.CondicionPago AS 'Condicion pago',
           F.DiasCredito AS 'DiasCredito',
           F.MonedaFactura AS 'Moneda factura',
           F.MonedaPedido AS 'Moneda pedido',
           CASE
               WHEN F.MonedaPedido = 'MXN' THEN
           (F.MontoAceptado/PDP.PrecioDolar)
               ELSE
                   F.MontoAceptado
           END AS 'Monto Aceptado USD',
           CASE
               WHEN F.IdMonedaFactura = 1 THEN --> MXN'S 	 
           (F.MontoFacturacion / PDF.PrecioDolar)
               WHEN F.IdMonedaFactura = 2 THEN
                   F.MontoFacturacion
               ELSE
                   NULL
           END AS 'Monto Facturado USD'	 
    FROM @Facturas F
        LEFT JOIN @Aprobadores A
            ON F.IdAceptacionFactura = A.IdAceptacionFactura
        LEFT JOIN @PedidoPrecioDLS PDP
            ON F.IdPedidoInterno = PDP.IdPedido
        LEFT JOIN @FacturaPrecioDLS PDF
            ON F.IdUnicoFactura = PDF.IdFactura;
	
	--ACTUALIZAR LOS MONTOS DE FACTURACIÓN QUE SE PAGAN EN EL MES ACTUAL 
	DECLARE @InicioMes DATE=CAST(DATEADD(d,1,EOMONTH(GETDATE(),-1)) AS DATE)
    DECLARE @FinMes DATE= CAST(EOMONTH(GETDATE()) AS DATE)
	
	UPDATE dbo.BI_Facturas
	SET MontoMes =  (CASE WHEN  CAST(DATEADD(DAY,DiasCredito,FechaCarga) AS DATE)>=@InicioMes
    AND CAST(DATEADD(DAY,DiasCredito,FechaCarga) AS DATE) <=@FinMes THEN 
    MontoFacturacionUSD
    ELSE 
    0
    END 
    ),
	EstatusPedido = (CASE WHEN UUID IS NULL THEN 
						CONCAT(EstatusPedido,'-','Eliminada')
					ELSE 
						EstatusPedido
				     END)
	
--SP´s de ayuda SP_ConsultaSeguimientosPagosV2
END;
