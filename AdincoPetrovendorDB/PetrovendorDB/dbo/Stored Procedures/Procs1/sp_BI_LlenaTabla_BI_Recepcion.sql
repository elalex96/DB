USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[sp_BI_LlenaTabla_BI_Recepcion]    Script Date: 30/03/2021 10:59:08 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_BI_LlenaTabla_BI_Recepcion]
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

    DECLARE @MaterialesRestantes TABLE
    (
        IdPedido INT,
        IdPedidoDetalle INT,
        CantidadRestante FLOAT
    );

	DECLARE @PedidosCantidadRestante AS TABLE (
	IdPedido INT,
	CantidadMaterialesRestantes FLOAT  
	)

    DECLARE @Pedidos TABLE
    (
        IdPedido INT,
        IdPeticionOferta INT,
        IdPedidoGeneral INT,
        IdSolicitudPedido INT,
        IdProveedor INT,
        Contrato VARCHAR(3000),
        Comprador VARCHAR(3000),
        Requisitor VARCHAR(3000),
        JustificacionRequisicion VARCHAR(8000),
        FechaAprobacionPedido DATETIME,
        RegistroPedido DATETIME,
        Moneda VARCHAR(100),
        PrecioDolar FLOAT,
        Proveedor VARCHAR(5000),
        PedidoCerrado VARCHAR(100),
        IdProveedorPetrovendor INT,
        EstatusRecepcion VARCHAR(3000),
		Presupuesto VARCHAR(3000)
    );

    DECLARE @Aceptaciones TABLE
    (
        IdPedido INT,
        IdAceptacionPedido INT,
        LugarEntrega VARCHAR(3000),
        NombreRecibidoPor VARCHAR(3000),
        Creado DATETIME,
        SolicitudCN BIT,
        IdProveedorPetrovendor INT
    );

    DECLARE @PedidoDetalle TABLE
    (
        IdPedido INT,
        IdPedidoDetalle INT,
        Partida VARCHAR(3000),
        PartidaDetalle VARCHAR(3000),
        Cantidad FLOAT,
        PrecioUnitario FLOAT,
        IdSolicitudPedidoDetalle INT,
        PartidaReq NVARCHAR(3000),
        PartidaDetalleReq VARCHAR(3000),
        Instalacion VARCHAR(1000),
        NoPartidaDetalle INT,
        SubTotal MONEY,
        SubTotalUSD MONEY,
		Tarea VARCHAR(3000),
		Modelo VARCHAR(MAX),
		Marca VARCHAR(MAX),
		NumeroParte VARCHAR(MAX),
		CentroCosto VARCHAR(300),
		ADN VARCHAR(3000), 
		IdMaterial INT
    );

    DECLARE @PedidoDetalleOrden TABLE
    (
        IdPedido INT,
        IdPedidoDetalle INT,
        NoPartidaDetalle INT
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
        IdAceptacionPedido INT,
        UUID VARCHAR(500),
        EstatusPago VARCHAR(MAX),
        IdEstatus INT,
        IdFacturaAdinco INT
    );

    --OBTENER PEDIDOS    
    INSERT INTO @Pedidos
    (
        IdPedido,
        IdPeticionOferta,
        IdPedidoGeneral,
        IdSolicitudPedido,
        IdProveedor,
        Contrato,
        Requisitor,
        Comprador,
        JustificacionRequisicion,
        FechaAprobacionPedido,
        RegistroPedido,
        Moneda,
        Proveedor,
        PedidoCerrado,
        IdProveedorPetrovendor,
        EstatusRecepcion,
		Presupuesto
    )
    SELECT P.IdPedido,
           P.IdPeticionOferta,
           PS.IdPedido,
           P.IdSolicitudPedido,
           P.IdProveedorCompras,
           C.NumeroContrato,
           UR.Nombre,
           UC.Nombre,
           S.MotivoUrgencia,
           P.FechaEnvioPedido,
           P.CreadoEl,
           TM.TipoMonedaCorto,
           PVD.RazonSocial,
           CASE
               WHEN ISNULL(P.Cerrado, 0) = 0 THEN
                   'No'
               ELSE
                   'Si'
           END,
           P.IdSubcontratista,
           CASE
               WHEN P.RecepcionServicio = 1 THEN
                   'Confirmación Aceptada'
               WHEN P.RecepcionServicio = 0 THEN
                   'Confirmación Rechazada'
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) >= 0
                   AND TAO.IdEstatusOperacion = 2 THEN
                   'Confirmación Vencida '
               WHEN P.RecepcionServicio IS NULL
                    AND (DATEDIFF(MINUTE, HV.FechaVigencia, GETDATE())) <= 0
                    AND TAO.IdEstatusOperacion = 2 THEN
                   'En Confirmación'
               ELSE
                   'Confirmación No Iniciada '
           END, --> COLUMNA ESTATUS CONFIRMACIÓN
		   PR.Nombre  -->COLUMNA PRESUPUESTO
    FROM @Proveedores AS PV
        JOIN dbo.MM_Pedido AS P (NOLOCK)
            ON PV.IdProveedor = P.IdProveedorCompras
        JOIN dbo.TA_Operacion TAO (NOLOCK)
            ON P.IdSolicitudPedido = TAO.IdDocumento
               AND P.Version = TAO.NoVersion --> LA VERSION DEL PEDIDO DEBE SER IGUAL AL DE LA APROBACIÓN DE PEDIDO  
               AND TAO.IdTipoOperacion = 9 --> APROBACIÓN DE TIPO PEDIDO 
               AND TAO.IdEstatusOperacion = 2 --> PEDIDOS APROBADOS  
        JOIN MM_HorasVigenciaPedido AS HV (NOLOCK)
            ON P.IdPedido = HV.IdPedido
        JOIN S_Proveedor AS PVD (NOLOCK)
            ON P.IdSubcontratista = PVD.IdProveedor
        JOIN dbo.PV_TipoMoneda AS TM (NOLOCK)
            ON P.IdMoneda = TM.IdMoneda
        JOIN dbo.S_Usuario AS UC (NOLOCK)
            ON P.CreadoPor = UC.IdUsuario
        JOIN MM_SolicitudPedido AS S (NOLOCK)
            ON P.IdSolicitudPedido = S.IdSolicitudPedido
        JOIN S_Usuario AS UR (NOLOCK)
            ON S.IdUsuarioSolicitante = UR.IdUsuario
        JOIN MM_Pedidos AS PS (NOLOCK)
            ON P.IdPedido = PS.IdIdentificador
               AND P.IdProveedorCompras = PS.IdProveedorCliente
               AND PS.IdTipoPedido NOT IN ( 1, 7 ) --> EXCLUIR COMPRAS DIRECTAS 1 Y COMPROBANTE EXTRANJERO 7
        JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
            ON S.IdContrato = C.IdContrato
		LEFT JOIN Adinco.dbo.CO_Presupuesto AS PR (NOLOCK)
            ON S.IdPresupuesto = PR.IdPresupuesto
    WHERE ISNULL(P.IdEstatusEliminado, 0) <> 1; --> MOSTRAR PEDIDO NO ELIMINADOS
    --AND P.RecepcionServicio=1

    --OBTENER PEDIDOS DETALLES 
    INSERT INTO @PedidoDetalle
    (
        IdPedido,
        IdPedidoDetalle,
        Partida,
        PartidaDetalle,
        Cantidad,
        PrecioUnitario,
        IdSolicitudPedidoDetalle,
        PartidaReq,
        PartidaDetalleReq,
        Instalacion,
        SubTotal,
		Tarea,
		Modelo,
		Marca,
		NumeroParte,
		CentroCosto,
		ADN,
		IdMaterial
    )
    SELECT P.IdPedido,
           PD.IdPedidoDetalle,
           POD.MaterialCotizadoTextoC, --> DESCRIPCIÓN CORTA DEL PEDIDO
           POD.MaterialCotizadoTextoL, --> DESCRIPCIÓN LARGA DEL PEDIDO           
           PD.Cantidad,
           PD.PrecioUnitario,
           SPD.IdSolicitudPedidoDetalle,
           MM.DescripcionCorta,        --> DESCRIPCIÓN CORTA DE LA REQUISICIÓN
           MM.DescripcionLarga,        --> DESCRIPCIÓN LARGA DE LA REQUISICIÓN
           INS.NombreInstalacion,
           PD.Subtotal,
		   TP.id_Tarea, --> TAREA
		   MM.Modelo,
		   MM.Marca,
		   MM.NumeroParte,
		   CC.CentroCosto,
		   SPD.observaciones,
		   PD.IdMaterial
    FROM @Pedidos AS P
        JOIN MM_PedidoDetalle AS PD (NOLOCK)
            ON P.IdPedido = PD.IdPedido
        JOIN dbo.MM_PeticionOfertaDetalle POD (NOLOCK)
            ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
               AND P.IdPeticionOferta = POD.IdPeticionOferta
        JOIN dbo.MM_PeticionOferta PO (NOLOCK)
            ON POD.IdPeticionOferta = PO.IdPeticionOferta
        JOIN dbo.MM_SolicitudPedidoDetalle SPD (NOLOCK)
            ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
               AND PO.IdSolicitudPedido = SPD.IdSolicitudPedido
        JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDL (NOLOCK)
            ON SPD.IdSolicitudPedidoDetalle = SPDL.IdSolicitudPedidoDetalle
		JOIN dbo.CC_CentroCosto AS CC (NOLOCK)
		ON SPDL.IdCentroCosto=CC.IdCentroCosto		            
        JOIN Adinco.dbo.CO_Instalacion AS INS (NOLOCK)
            ON SPDL.IdInstalacion = INS.IdInstalacion
        LEFT JOIN dbo.MM_Material MM (NOLOCK)
            ON SPD.IdMaterial = MM.IdMaterial
		LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes LP (NOLOCK)
			ON SPDL.IdLineaPresupuesto=LP.IdLineaPresupuestoMes
		LEFT JOIN Adinco.dbo.CO_TareaPetrolera AS TP (NOLOCK)
            ON LP.IdTareaPetrolera = TP.IdTareaPetrolera


    --OBTENER NUMERO CONSECUTIVOS DE PEDIDO DETALLE 
    INSERT INTO @PedidoDetalleOrden
    (
        IdPedido,
        IdPedidoDetalle,
        NoPartidaDetalle
    )
    SELECT IdPedido,
           IdPedidoDetalle,
           ROW_NUMBER() OVER (PARTITION BY IdPedido ORDER BY IdPedidoDetalle)
    FROM @PedidoDetalle
    GROUP BY IdPedido,
             IdPedidoDetalle
    ORDER BY IdPedido;

    --ACTUALIZAR EL NUMERO PARTIDA DETALLE CONSECUTIVO
    UPDATE PD
    SET PD.NoPartidaDetalle = PDO.NoPartidaDetalle
    FROM @PedidoDetalle AS PD
        JOIN @PedidoDetalleOrden AS PDO
            ON PD.IdPedido = PDO.IdPedido
               AND PD.IdPedidoDetalle = PDO.IdPedidoDetalle;

    --OBTENER EL PRECIO DEL DOLAR PARA LOS PEDIDOS EN PESOS 
    UPDATE P
    SET P.PrecioDolar = TC.TipoCambio
    FROM @Pedidos AS P
        JOIN Adinco.dbo.CO_TipoCambioDiario AS TC (NOLOCK)
            ON CAST(P.RegistroPedido AS DATE) = TC.Fecha
    WHERE P.Moneda = 'MXN'
          AND TC.IdMoneda = 1; --> DLS

    --CONVERTIR DE PESOS A DOLARES SUBTOTAL POR PEDIDO DETALLE SEGUN EL TIPO DE MONEDA DEL PEDIDO

    UPDATE PD
    SET PD.SubTotalUSD = (CASE
                              WHEN P.Moneda = 'MXN' THEN
                                  PD.SubTotal / P.PrecioDolar
                              ELSE
                                  SubTotal
                          END
                         )
    FROM @PedidoDetalle PD
        LEFT JOIN @Pedidos P
            ON PD.IdPedido = P.IdPedido;

    --OBTENER MATERIALES FALTANTES DE RECIBIR POR PEDIDO DETALLE	
    INSERT INTO @MaterialesRestantes
    (
        IdPedido,
        IdPedidoDetalle,
        CantidadRestante
    )
    SELECT P.IdPedido,
           PD.IdPedidoDetalle,
           PD.Cantidad - SUM(ISNULL(APD.Cantidad, 0))
    FROM @Pedidos P
        JOIN dbo.MM_PedidoDetalle AS PD (NOLOCK)
            ON P.IdPedido = PD.IdPedido
        LEFT JOIN dbo.MM_AceptacionPedido AS AP (NOLOCK)
            ON P.IdPedido = AP.IdPedido
               AND ISNULL(AP.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADO        
        LEFT JOIN dbo.MM_AceptacionPedidoDetalle AS APD (NOLOCK)
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
               AND PD.IdPedidoDetalle = APD.IdPedidoDetalle
    GROUP BY P.IdPedido,
             PD.IdPedidoDetalle,
             PD.Cantidad;

    --OBTENER ENCABEZADADO ACEPTACIONES REALIZADAS
    INSERT INTO @Aceptaciones
    (
        IdPedido,
        IdAceptacionPedido,
        LugarEntrega,
        NombreRecibidoPor,
        Creado,
        SolicitudCN,
        IdProveedorPetrovendor
    )
    SELECT AP.IdPedido,
           AP.IdAceptacionPedido,
           CONCAT(
                     ISNULL(LE.Calle + ' ', ''),
                     ISNULL(LE.NoExterior + ' ', ''),
                     ISNULL(LE.NoInterior + ' ', ''),
                     ISNULL(LE.Colonia + ' ', ''),
                     ISNULL(LE.Municipio + ' ', ''),
                     ISNULL(LE.Estado + ' ', ''),
                     PAIS.pais
                 ),
           AP.NombreRecibidoPor,
           AP.Creado,
           RCN.PedirCarta,
           P.IdProveedorPetrovendor
    FROM @Pedidos AS P
        JOIN MM_AceptacionPedido AS AP (NOLOCK)
            ON P.IdPedido = AP.IdPedido
        JOIN dbo.RelacionCartaCNPedido AS RCN (NOLOCK)
            ON AP.IdAceptacionPedido = RCN.IdAceptacionPedido
        JOIN DG_Domicilio AS LE (NOLOCK)
           ON AP.IdDomicilioEntrega = LE.IdDomicilio
        LEFT JOIN PV_PaisRepublica AS PAIS (NOLOCK)
            ON LE.IdPais = PAIS.id
    WHERE ISNULL(AP.IdEstatusEliminado, 0) <> 1; --> MOSTRAR ACEPTACIONES NO ELIMINADAS    

    -- OBTENER ESTATUS DE LA ULTIMA CARTA DE CN DE LAS ACEPTACIONES REALIZADAS
    INSERT INTO @Estatus
    (
        IdAceptacionPedido,
        IdAceptacionCartaPCN
    )
    SELECT AP.IdAceptacionPedido,
           MAX(IdAceptacionCartaPCN)
    FROM @Aceptaciones AP
        JOIN MM_AceptacionCartaPCN ACN (NOLOCK)
            ON AP.IdAceptacionPedido = ACN.IdAceptacionPedido
    GROUP BY AP.IdAceptacionPedido;

    --OBTENER NOMBRE DEL ESTATUS DE LA CNN
    INSERT INTO @CCN
    (
        IdAceptacionPedido,
        Estatus
    )
    SELECT AP.IdAceptacionPedido,
           TV.TipoValidacion
    FROM @Aceptaciones AP
        JOIN @Estatus E
            ON AP.IdAceptacionPedido = E.IdAceptacionPedido
        JOIN MM_AceptacionCartaPCN ACN (NOLOCK)
            ON E.IdAceptacionCartaPCN = ACN.IdAceptacionCartaPCN
        JOIN S_TipoValidacionDoc TV (NOLOCK)
            ON ACN.IdEstatus = TV.IdTipoValidacionDoc;

    --OBTENER FACTURAS RELACIONADAS A LA ACEPTACIÓN DE PEDIDO (NO IMPORTA EL ESTATUS)
    INSERT INTO @Facturas
    (
        IdAceptacionPedido,
        UUID,
        IdEstatus
    )
    SELECT A.IdAceptacionPedido,
           FI.UUID,
           O.IdEstatusOperacion
    FROM @Aceptaciones AS A
        JOIN dbo.MM_AceptacionFactura AS AF (NOLOCK)
            ON A.IdAceptacionPedido = AF.IdAceptacionPedido
               AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
        JOIN dbo.TA_Operacion AS O (NOLOCK)
            ON AF.IdAceptacionFactura = O.IdDocumento
               AND O.IdTipoOperacion = 10 --> APROBACIÓN DE TIPO APROBACIÓN DE FACTURA
               AND A.IdProveedorPetrovendor = O.IdProveedor --> EL PROVEEDOR DE PETROVENDOR ES EL QUE CREA LA OPERACIÓN CUANDO CARGA UNA FACTURA 
               AND ISNULL(O.IdFlujoTarea, 0) <> 0 --> PARA EVITAR SE DUPLIQUEN LOS DATOS (YA QUE EXITEN OPERACIONES LIGADAS A LA ACEPTACIÓN FACTURA SIN FLUJO)
        JOIN dbo.FI_Factura AS FI (NOLOCK)
            ON AF.IdFactura = FI.IdFactura
    GROUP BY A.IdAceptacionPedido,
             FI.UUID,
             O.IdEstatusOperacion;


    --OBTENER ID FACTURA DE ADINCO MEDIANTE EL UUID 

    UPDATE AF
    SET AF.IdFacturaAdinco = FA.IdFactura
    FROM @Facturas AF
        JOIN Adinco.dbo.FI_Factura (NOLOCK) AS FA
            ON AF.UUID = FA.UUID COLLATE Modern_Spanish_CI_AS
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
    --ESTA APLICA SOLO PARA LAS FACTURAS PDD POR SI TIENE RELACIONADO UN COMPLEMENTO DE PAGO
    UPDATE AF
    SET AF.EstatusPago = (CASE
                              WHEN TR.AWSPDFId IS NULL THEN
                                  'No Pagado'
                              WHEN TR.AWSPDFId IS NOT NULL THEN
                                  'Pagado'
                          END
                         )
    FROM @Facturas AF
        JOIN Adinco.dbo.FI_CPDocRelacionado dr (NOLOCK)
            ON AF.UUID = dr.IdDocumento COLLATE Modern_Spanish_CI_AS
        JOIN Adinco.dbo.FI_ComplementoDePago cp (NOLOCK)
            ON dr.IdComplementoDePago = cp.IdComplementoDePago
        JOIN Adinco.dbo.FI_TransferFactura AS TRF (NOLOCK)
            ON cp.IdFactura = TRF.IdFactura
        JOIN Adinco.dbo.FI_Transfer AS TR (NOLOCK)
            ON TRF.IdTransfer = TR.IdTransferencia
    WHERE AF.IdEstatus = 2; -->  QUE LA FACTURA ESTE APROBADA

    UPDATE @Facturas
    SET EstatusPago = 'No pagado'
    WHERE IdEstatus = 2
          AND EstatusPago = '';

	
	/*ACTUALIZAR COLUMNA PedidoCerrado DE @PEDIDOS CUANDO EL PEDIDO ESTE RECEPCIONADO AL 100% */
	/*PARA ESO HAY QUE AGRUPAR LAS CANTIDADES RESTANTES POR PEDIDO Y EL PEDIDO QUE TENGA UNA CANTIDAD RESTANTE IGUAL A 0 
	QUIERE DECIR QUE TODOS SUS PRODUCTOS YA HAN SIDO RECEPCIONADOS POR LO TANTO PASAN A ESTAR CERRADOS
	SI POR ALGO SALE UN NUMERO NEGATIVO PASARLO A 0, SOLO TOMAR EN CUENTA LOS PEDIDOS NO CERRADOS*/
	INSERT INTO @PedidosCantidadRestante
	(
	    IdPedido,
	    CantidadMaterialesRestantes
	)
	SELECT P.IdPedido, SUM(CASE WHEN MR.CantidadRestante<0 THEN 0 ELSE MR.CantidadRestante END) 
	FROM @Pedidos P
	JOIN @MaterialesRestantes MR 
	ON P.IdPedido=MR.IdPedido
	WHERE P.PedidoCerrado='No'	
	GROUP BY P.IdPedido
		
	/*ACTUALIZAR LA COLUMNA PedidoCerrado DE @Pedidos SI LA CANTIDAD RESTANTE DEL PEDIDO ES IGUAL A 0*/	
	UPDATE P
	SET P.PedidoCerrado='Si'
	FROM @Pedidos P
	JOIN @PedidosCantidadRestante PCR
	ON P.IdPedido=PCR.IdPedido
	WHERE PCR.CantidadMaterialesRestantes=0


    --AGREGAR ACEPTACIONES PEDIDO DETALLE 
    TRUNCATE TABLE BI_Recepcion;
    INSERT INTO BI_Recepcion
    (
        IdPedidoUnico,
        IdSolicitudPedido,
        IdAceptacionPedido,
        NumeroAceptacion,
        NumeroContrato,
        IdPedido,
        MaterialCotizadoTextoC,
        MaterialCotizadoTextoL,
        NombreRecibidoPor,
        CantidadPedido,
        CantidadAcceptada,
        CantidadRestante,
        MontoAceptado,
        FechaRecepcion,
        EstatusCN,
        LugarEntrega,
        PrecioUnitario,
        Partida,
        Instalacion,
        PartidaReq,
        PartidaDetalleReq,
        DescripcionGralReq,
        Solicitante,
        Comprador,
        FechaPedido,
        Moneda,
        MontoAceptadoUSD,
        Proveedor,
        NoPartidaDetalle,
        UUID,
        PedidoCerrado,
        SubtotalPedidoUSD,
        EstatusPago,
        EstatusConfirmacion,
		Presupuesto,
		Tarea,
		Modelo,
		Marca,
		NumeroParte,
		CentroCosto,
		ADN,
		IdMaterial
    )
    SELECT AP.IdPedido AS 'idunico pedido',
           P.IdSolicitudPedido AS 'idunico de requisición',
           AP.IdAceptacionPedido AS 'IdAceptacionPedido',
           AP.IdAceptacionPedido AS 'N° de Aceptación',
           P.Contrato AS 'Contrato',
           P.IdPedidoGeneral AS 'N° Pedido',
           PD.Partida AS 'Partida(Pedido)',                       --> DESCRIPCIÓN CORTA DEL PEDIDO
           PD.PartidaDetalle AS 'Descripción',                    --> DESCRIPCIÓN LARGA DEL PEDIDO
           AP.NombreRecibidoPor AS 'Recibido Por',
           PD.Cantidad AS 'Cantidad Pedido',
           APD.Cantidad AS 'Cantidad Aceptada',
           CASE
               WHEN ISNULL(MR.CantidadRestante, 0) < 0 THEN
                   0
               ELSE
                   MR.CantidadRestante
           END AS 'Cantidad Restante',
           CAST(PD.PrecioUnitario * APD.Cantidad AS MONEY) AS 'Monto Aceptado',
           CAST(AP.Creado AS DATE) AS 'Fecha de Recepción',
           CASE
               WHEN AP.SolicitudCN = 0 THEN
                   'No se solicitó CCN'
               ELSE
                   CASE
                       WHEN CNN.Estatus IS NOT NULL THEN
                           CNN.Estatus
                       ELSE
                           'Proveedor no ha cargado CNN'
                   END
           END AS 'Estatus CN',
           AP.LugarEntrega,
           PD.PrecioUnitario,
           PD.IdSolicitudPedidoDetalle AS 'Partida',
           PD.Instalacion AS 'Nombre Instalación',
           PD.PartidaReq AS 'Partida requisicion',                --> DESCRIPCIÓN CORTA DE LA REQUISICIÓN
           PD.PartidaDetalleReq AS 'Partida requisicion detalle', --> DESCRIPCIÓN LARGA DE LA REQUISICIÓN
           P.JustificacionRequisicion AS 'Descripcion pedido',
           P.Requisitor AS 'Solicitante',
           P.Comprador AS 'Comprador',
           P.FechaAprobacionPedido AS 'Fecha pedido',             --> FECHA APROBACIÓN DE PEDIDO
           P.Moneda AS 'Moneda pedido',
           CASE
               WHEN P.Moneda = 'MXN' THEN
                   CAST(((PD.PrecioUnitario * APD.Cantidad) / P.PrecioDolar) AS MONEY)
               ELSE
                   CAST(PD.PrecioUnitario * APD.Cantidad AS MONEY)
           END AS MontoAceptadoUSD,
           P.Proveedor,
           PD.NoPartidaDetalle,
           ISNULL(FI.UUID, '') AS UUID,
           P.PedidoCerrado,
           PD.SubTotalUSD AS 'Subtotal Pedido USD',               --> SUBTOTAL POR PARTIDA DETALLE DEL PEDIDO 
           ISNULL(FI.EstatusPago, '') AS 'Estatus pago',
           P.EstatusRecepcion,
		   P.Presupuesto,
		   PD.Tarea,
		   PD.Modelo,
		   PD.Marca,
		   PD.NumeroParte,
		   PD.CentroCosto,
		   PD.ADN,
		   PD.IdMaterial
    FROM @Aceptaciones AS AP
        JOIN @Pedidos AS P
            ON AP.IdPedido = P.IdPedido
        JOIN MM_AceptacionPedidoDetalle AS APD (NOLOCK)
            ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
        JOIN @PedidoDetalle AS PD
            ON AP.IdPedido = PD.IdPedido
               AND APD.IdPedidoDetalle = PD.IdPedidoDetalle
        JOIN @MaterialesRestantes MR
            ON APD.IdPedidoDetalle = MR.IdPedidoDetalle
        LEFT JOIN @CCN AS CNN
            ON AP.IdAceptacionPedido = CNN.IdAceptacionPedido
        LEFT JOIN @Facturas AS FI
            ON AP.IdAceptacionPedido = FI.IdAceptacionPedido;

    --AGREGAR PEDIDO DETALLE QUE NO TIENEN NINGUNA ACEPTACION PEDIDO DETALLE 
    INSERT INTO BI_Recepcion
    (
        IdPedidoUnico,
        IdSolicitudPedido,
        IdAceptacionPedido,
        NumeroAceptacion,
        NumeroContrato,
        IdPedido,
        MaterialCotizadoTextoC,
        MaterialCotizadoTextoL,
        NombreRecibidoPor,
        CantidadPedido,
        CantidadAcceptada,
        CantidadRestante,
        MontoAceptado,
        FechaRecepcion,
        EstatusCN,
        LugarEntrega,
        PrecioUnitario,
        Partida,
        Instalacion,
        PartidaReq,
        PartidaDetalleReq,
        DescripcionGralReq,
        Solicitante,
        Comprador,
        FechaPedido,
        Moneda,
        MontoAceptadoUSD,
        Proveedor,
        NoPartidaDetalle,
        UUID,
        PedidoCerrado,
        SubtotalPedidoUSD,
        EstatusPago,
        EstatusConfirmacion,
		Presupuesto,
		Tarea,
		Modelo,
		Marca,
		NumeroParte,
		CentroCosto,
		ADN,
		IdMaterial
    )
    SELECT P.IdPedido AS 'idunico pedido',
           P.IdSolicitudPedido AS 'idunico de requisición',
           0 AS 'IdAceptacionPedido',                                 --> POR DEFAULT 0 POR QUE NO TIENEN ACEPTACIÓN DE PEDIDO 
           0 AS 'N° de Aceptación',                                   --> POR DEFAULT 0 POR QUE NO TIENEN ACEPTACIÓN DE PEDIDO 
           P.Contrato AS 'Contrato',
           P.IdPedidoGeneral AS 'N° Pedido',
           PD.Partida AS 'Partida(Pedido)',                           --> DESCRIPCIÓN CORTA DEL PEDIDO
           PD.PartidaDetalle AS 'Descripción',                        --> DESCRIPCIÓN LARGA DEL PEDIDO
           '' AS 'Recibido Por',                                      --> POR DEFAULT '' POR QUE NO TIENEN ACEPTACIÓN DE PEDIDO 
           PD.Cantidad AS 'Cantidad Pedido',
           0 AS 'Cantidad Aceptada',                        --> POR DEFAULT 0 POR QUE NO TIENEN ACEPTACIÓN DE PEDIDO 
           PDR.CantidadRestante AS 'Cantidad Restante',
           0 AS 'Monto Aceptado',                                     --> POR DEFAULT 0 POR QUE NO TIENEN ACEPTACIÓN DE PEDIDO 
           NULL AS 'Fecha de Recepción',                              --> POR DEFAULT NULL POR QUE NO TIENEN ACEPTACIÓN DE PEDIDO 
           'Sin recepción' AS 'Estatus CN',
           '',                                                        --> POR DEFAULT '' POR QUE NO TIENEN ACEPTACIÓN DE PEDIDO 
           PD.PrecioUnitario,
           PD.IdSolicitudPedidoDetalle AS 'Partida',
           PD.Instalacion AS 'Nombre Instalación',
           PD.PartidaReq AS 'Partida requisicion',                    --> DESCRIPCIÓN CORTA DE LA REQUISICIÓN
           PD.PartidaDetalleReq AS 'Partida descripcion requisicion', --> DESCRIPCIÓN LARGA DE LA REQUISICIÓN
           P.JustificacionRequisicion AS 'Descripcion gral requisicion',
           P.Requisitor AS 'Solicitante',
           P.Comprador AS 'Comprador',
           P.FechaAprobacionPedido AS 'Fecha pedido',                 --> Fecha aprobación de pedido
           P.Moneda,
           0,                                                         --> POR DEFAULT 0 POR QUE NO TIENEN ACEPTACIÓN DE PEDIDO 
           P.Proveedor,
           PD.NoPartidaDetalle,
           '' AS 'UUID',                                              -->POR DEFAULT NO TIENEN UUID POR QUE NO TIENE ACEPTACIÓND DE PEDIDO
           P.PedidoCerrado,
           PD.SubTotalUSD AS 'Subtotal Pedido USD',                   --> SUBTOTAL POR PARTIDA DETALLE DEL PEDIDO 
           '' AS 'Estatus pago',                                      --> POR DEFAULT NO TIENE PAGO POR QUE NO TIENE ACEPTACIÓN DE PEDIDO
           P.EstatusRecepcion,
		   P.Presupuesto,
		   PD.Tarea,
		   PD.Modelo,
		   PD.Marca,
		   PD.NumeroParte,
		   PD.CentroCosto,
		   PD.ADN,
		   PD.IdMaterial
    FROM @PedidoDetalle AS PD
        JOIN @MaterialesRestantes AS PDR
            ON PD.IdPedidoDetalle = PDR.IdPedidoDetalle
               AND PDR.CantidadRestante = PD.Cantidad
        JOIN @Pedidos AS P
            ON PD.IdPedido = P.IdPedido;

END;