USE Petrovendor
--> SCRIPT Script_PCM_RevisionPresupuestal_27_Jul_2020_Rpt
DECLARE @IdPresupuesto INT = 10061 -- 2018 anio CAMBIAR DE ACUERDO AL PRESUPUESTO DESEADO
DECLARE @Presupuesto NVARCHAR(MAX),
		@IdContrato INT = 10036 --> CAMBIAR DE ACUERDO AL CONTRATO DESEADO

DECLARE @IdProveedor INT;
SELECT @Presupuesto = Nombre
FROM Adinco.dbo.CO_Presupuesto (NOLOCK)
WHERE IdPresupuesto = @IdPresupuesto

DECLARE @LineasPresupuesto TABLE (IdLineaPresupuesto INT, NombreLinea NVARCHAR(MAX))
DECLARE @PedidoDetalle TABLE(IdLineaPresupuesto INT, MontoOrdenDls FLOAT, IdPedido INT, IdPedidoDetalle INT, RazonSocial NVARCHAR(MAX), IdSolicitudPedido INT, Requisitor NVARCHAR(MAX), IdSubcontratista INT)
DECLARE @PedidoDetalleConAceptacion TABLE(IdPedidoDetalle INT, IdLineaPresupuesto INT, IdSolicitudPedido INT, IdSubcontratista INT, IdAceptacionPedido INT, Cantidad FLOAT)
DECLARE @PedidosDetalleAceptacionTotales TABLE(IdPedido INT, IdPedidoDetalle INT, MontoDls FLOAT, IdAceptacionPedido INT)
DECLARE @TablaFiltro TABLE(IdSolicitudPedido INT, IdLineaSolpedOAceptacion INT, IdPedido INT, IdPedidoDetalle INT, OrdenCompra INT, IdAceptacionPedido INT,
	IdAceptacionPedidoDetalle INT,MontoOrdenDls FLOAT, MontoAceptacionDls FLOAT )
DECLARE @TablaAceptacion TABLE(IdPedidoDetalle INT, IdMaterial INT, PrecioUnitario FLOAT, IdPedido INT, OrdenCompra INT, CantidadPedido FLOAT, CantidadAceptada FLOAT, CantidadRestante FLOAT, IdAceptacionPedido INT)

-- SE OBTIENEN LAS LINEAS DE PRESUPUESTO DESDE ADINCO
-- ESTO DEBIDO A QUE ME TOPE CON EL 
-- CASO 1 DE QUE AL PRINCIPIO LAS LINEAS PERTENECIAN A UN PRESUPUESTO
-- Y SE QUEDO GRABADO EN MM_SOLICITUDPEDIDO, Y LUEGO AL PARECER CAMBIARON DE PRESUPUESTO ESAS LINEAS
-- CASO 2 LA LINEA SE MOVIO A OTRA LINEA DE OTRO PRESUPUESTO PERO NACIO EN OTRO PRESUPUESTO
INSERT INTO @LineasPresupuesto (IdLineaPresupuesto, NombreLinea)
SELECT mes.IdLineaPresupuestoMes,
       CONCAT(
       cnh.id_Actividad,
       ' - ',
       petro.[id_Sub-actividad],
       ' - ',
       tarea.[id_Tarea] ,
       ' - ',
       serv.NombreServicio)
FROM Adinco.dbo.CO_LineaPresupuestoMes mes WITH(NOLOCK)
    LEFT JOIN Adinco.dbo.CO_ActividadPetroleraCNH cnh WITH(NOLOCK)
        ON mes.IdActividadPetrolera  = cnh.IdActividadPetrolera 
    LEFT JOIN Adinco.dbo.CO_SubactividadPetrolera petro WITH(NOLOCK)
        ON mes.IdSubactividadPetrolera = petro.IdSubactividadPetrolera 
    LEFT JOIN Adinco.dbo.CO_TareaPetrolera tarea WITH(NOLOCK)
        ON mes.IdTareaPetrolera = tarea.IdTareaPetrolera 
    LEFT JOIN Adinco.dbo.CO_Servicio serv WITH(NOLOCK)
        ON  mes.IdServicio = serv.IdServicio 
    LEFT JOIN Adinco.dbo.CO_Presupuesto p WITH(NOLOCK)
        ON mes.IdPresupuesto = p.IdPresupuesto 
WHERE mes.IdPresupuesto = @IdPresupuesto


SELECT @IdProveedor = P.IdProveedor
FROM Adinco.dbo.CO_Contrato C (NOLOCK)
    JOIN Adinco.dbo.CO_Contratista CC (NOLOCK)
        ON C.IdContratista = CC.IdContratista 
    JOIN Petrovendor.dbo.S_Proveedor P (NOLOCK)
        ON  CC.RFC = P.RFC  COLLATE DATABASE_DEFAULT
WHERE C.IdContrato = @IdContrato


    --TODOS LOS MONTOS EN PESOS SE PASAN A DOLARES  
	INSERT INTO @PedidoDetalle
	(
	    IdLineaPresupuesto,
	    MontoOrdenDls,
	    IdPedido,
	    IdPedidoDetalle,
	    RazonSocial,
	    IdSolicitudPedido,
	    Requisitor,
	    IdSubcontratista
	)
    SELECT LPM.IdLineaPresupuestoMes,
           PD.Subtotal / TCDF.TipoCambio AS MontoDLS,
           P.IdPedido,
           PD.IdPedidoDetalle,
           LTRIM(RTRIM(S.RazonSocial)) AS RazonSocial,
           SP.IdSolicitudPedido,
           LTRIM(RTRIM(REQ.Nombre)) AS Requisitor,
           P.IdSubcontratista
    FROM Petrovendor.dbo.MM_Pedido P  (NOLOCK)
        JOIN Petrovendor.dbo.TA_Operacion AS O  (NOLOCK)
            ON P.IdSolicitudPedido = O.IdDocumento 
        JOIN Petrovendor.dbo.MM_PedidoDetalle PD  (NOLOCK)
            ON  P.IdPedido  = PD.IdPedido 
        JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle POD  (NOLOCK)
            ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle  
        JOIN Petrovendor.dbo.MM_PeticionOferta PO  (NOLOCK)
            ON POD.IdPeticionOferta = PO.IdPeticionOferta 
               AND P.IdPeticionOferta = PO.IdPeticionOferta 
        JOIN Petrovendor.dbo.MM_SolicitudPedido SP  (NOLOCK)
            ON PO.IdSolicitudPedido = SP.IdSolicitudPedido 
               AND P.IdSolicitudPedido = SP.IdSolicitudPedido 
        JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle SPD  (NOLOCK)
            ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido 
               AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
        JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDLP  (NOLOCK)
            ON SPD.IdSolicitudPedidoDetalle = SPDLP.IdSolicitudPedidoDetalle 
        JOIN Adinco.dbo.CO_LineaPresupuestoMes LPM  (NOLOCK)
            ON SPDLP.IdLineaPresupuesto = LPM.IdLineaPresupuestoMes
        JOIN Petrovendor.dbo.S_Proveedor S  (NOLOCK)
            ON P.IdSubcontratista = S.IdProveedor
               AND P.IdSubcontratista IS NOT NULL
        JOIN Petrovendor.dbo.S_Usuario REQ  (NOLOCK)
            ON SP.IdUsuarioSolicitante = REQ.IdUsuario
        JOIN @LineasPresupuesto linea  
            ON  LPM.IdLineaPresupuestoMes = linea.IdLineaPresupuesto 
        LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCDF  (NOLOCK)
            ON PD.IdMoneda = TCDF.IdMoneda 
               AND CONVERT(VARCHAR, PD.CreadoEl, 112) = CONVERT(VARCHAR, TCDF.Fecha, 112) 
    WHERE O.IdTipoOperacion = 9 --> DE TIPO DE APROBACION DE PEDIDO  
          AND P.Version = O.NoVersion --> MISMA VERSION  
          AND O.IdEstatusOperacion = 2 --> PEDIDO APROBADO  
          AND P.RecepcionServicio = 1 --> CONFIRMACION  ACEPTADA  
          AND P.IdProveedorCompras = @IdProveedor ---> NUMERO DE PROVEEDOR DE LA OPERADORA ACTUAL  
          AND ISNULL(P.IdEstatusEliminado, 0) = 0
          AND ISNULL(PO.IdEstatusEliminado, 0) = 0
          AND ISNULL(SP.IdEstatusEliminado, 0) = 0
    GROUP BY LTRIM(RTRIM(S.RazonSocial)),
             LPM.IdLineaPresupuestoMes,
             P.IdPedido,
             SP.IdSolicitudPedido,
             LTRIM(RTRIM(REQ.Nombre)),
             PD.IdPedidoDetalle,
             P.IdSubcontratista,
			 PD.Subtotal,
			 TCDF.TipoCambio
    ORDER BY P.IdPedido;


    --SE OBTIENE CUALES PEDIDOS TIENEN ACEPTACION DE PEDIDO  
    --ESTO PARA OBTENER SUS LINEAS DE PRESUPUESTO YA QUE ESTAS SE PUEDEN DISPERSAR   
    -- YA QUE NO SE OCUPARIAN LAS DE LA SOLICITUD DE PEDIDO  
    INSERT INTO @PedidoDetalleConAceptacion
    (
        IdPedidoDetalle,
        IdLineaPresupuesto,
        IdSolicitudPedido,
        IdSubcontratista,
        IdAceptacionPedido,
        Cantidad
    )
    SELECT pdt.IdPedidoDetalle,
           apdi.IdLineaPresupuesto,
           pdt.IdSolicitudPedido,
           pdt.IdSubcontratista,
           ap.IdAceptacionPedido,
           apd.Cantidad
    FROM @PedidoDetalle pdt
        JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd (NOLOCK)
            ON pdt.IdPedidoDetalle = apd.IdPedidoDetalle 
        JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalleInstalacion apdi (NOLOCK)
            ON  apd.IdAceptacionPedidoDetalle = apdi.IdAceptacionPedidoDetalle
        JOIN Petrovendor.dbo.MM_AceptacionPedido ap (NOLOCK)
            ON apd.IdAceptacionPedido = ap.IdAceptacionPedido 
    WHERE ISNULL(ap.IdEstatusEliminado, 0) = 0
    GROUP BY pdt.IdPedidoDetalle,
             apdi.IdLineaPresupuesto,
             pdt.IdSolicitudPedido,
             pdt.IdSubcontratista,
             ap.IdAceptacionPedido,
             apd.Cantidad


    -- SE ELIMINAN LOS DETALLES DEL PEDIDO QUE YA TIENEN ACEPTACION DE PEDIDO  
    -- ESTO POR QUE LA LINEA DE PRESUPUESTO SE SELECCIONA EN LA ACEPTACION DE PEDIDO YA NO ES EL DE LA SOLPED  
    DELETE @PedidoDetalle
    WHERE IdPedidoDetalle IN ( SELECT pdca.IdPedidoDetalle FROM @PedidoDetalleConAceptacion pdca )

    -- SE AGREGAN LOS PEDIDO DETALLE QUE SE ELIMINARON CON LAS LINEAS QUE SE SELECCIONARON LA ACEPTACION DE PEDIDO  
    INSERT INTO @PedidoDetalle
    (
        IdLineaPresupuesto,
        MontoOrdenDls,
        IdPedido,
        IdPedidoDetalle,
        RazonSocial,
        IdSolicitudPedido,
        Requisitor,
        IdSubcontratista
    )
    SELECT pdca.IdLineaPresupuesto,
           pd.Subtotal /TCDF.TipoCambio AS MontoDLS,
           PD.IdPedido,
           PD.IdPedidoDetalle,
           LTRIM(RTRIM(S.RazonSocial)) AS RazonSocial,
           pdca.IdSolicitudPedido,
           LTRIM(RTRIM(REQ.Nombre)) AS Requisitor,
           pdca.IdSubcontratista
    FROM @PedidoDetalleConAceptacion pdca
        JOIN Petrovendor.dbo.MM_PedidoDetalle PD (NOLOCK)
            ON pdca.IdPedidoDetalle = PD.IdPedidoDetalle
        JOIN Adinco.dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
            ON pdca.IdLineaPresupuesto = LPM.IdLineaPresupuestoMes
        JOIN Petrovendor.dbo.S_Proveedor S  (NOLOCK)
            ON pdca.IdSubcontratista = S.IdProveedor
        JOIN Petrovendor.dbo.MM_SolicitudPedido sp (NOLOCK)
            ON pdca.IdSolicitudPedido = sp.IdSolicitudPedido 
        JOIN Petrovendor.dbo.S_Usuario REQ (NOLOCK)
            ON sp.IdUsuarioSolicitante = REQ.IdUsuario
        JOIN @LineasPresupuesto linea 
            ON LPM.IdLineaPresupuestoMes = linea.IdLineaPresupuesto 
		LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCDF (NOLOCK)
            ON  PD.IdMoneda = TCDF.IdMoneda 
               AND CONVERT(VARCHAR, TCDF.Fecha, 112) = CONVERT(VARCHAR, pd.CreadoEl, 112)
    GROUP BY LTRIM(RTRIM(S.RazonSocial)),
             LTRIM(RTRIM(REQ.Nombre)),
             pdca.IdLineaPresupuesto,
             PD.IdPedido,
             PD.IdPedidoDetalle,
             pdca.IdSolicitudPedido,
             pdca.IdSubcontratista,
			 pd.Subtotal,
			 TCDF.TipoCambio
    ORDER BY PD.IdPedido;

	INSERT INTO @PedidosDetalleAceptacionTotales (IdPedido, IdPedidoDetalle, MontoDls, IdAceptacionPedido)
    SELECT PD.IdPedido,
           pdca.IdPedidoDetalle,
           (ISNULL(PD.PrecioUnitario * pdca.Cantidad, 0) / TCDF.TipoCambio) AS MontoDLS,
           pdca.IdAceptacionPedido
    FROM @PedidoDetalleConAceptacion pdca
        INNER JOIN Petrovendor.dbo.MM_PedidoDetalle PD  (NOLOCK)
            ON pdca.IdPedidoDetalle = PD.IdPedidoDetalle 
		LEFT JOIN Adinco.dbo.CO_TipoCambioDiario TCDF (NOLOCK)
            ON PD.IdMoneda = TCDF.IdMoneda 
               AND CONVERT(VARCHAR, pd.CreadoEl, 112) = CONVERT(VARCHAR, TCDF.Fecha, 112) 
    GROUP BY (ISNULL(PD.PrecioUnitario * pdca.Cantidad, 0) / TCDF.TipoCambio),
             PD.IdPedido,
             pdca.IdPedidoDetalle,
             pdca.IdAceptacionPedido

	INSERT INTO @TablaFiltro
	(
	    IdSolicitudPedido,
	    IdLineaSolpedOAceptacion,
	    IdPedido,
	    IdPedidoDetalle,
	    OrdenCompra,
	    IdAceptacionPedido,
	    IdAceptacionPedidoDetalle,
	    MontoOrdenDls,
	    MontoAceptacionDls
	)
    SELECT P.IdSolicitudPedido,
			P.IdLineaPresupuesto,
			P.IdPedido,
			P.IdPedidoDetalle,
			Ps.IdPedido AS OrdenCompra,
			PDA.IdAceptacionPedido,
			apd.IdAceptacionPedidoDetalle,
           ISNULL(P.MontoOrdenDls, 0) AS MontoPedidoDetalleDLS,
           SUM(ISNULL(PDA.MontoDLS, 0)) AS MontoAceptadoDLS  
    FROM @PedidoDetalle P
        LEFT JOIN @PedidosDetalleAceptacionTotales PDA
            ON P.IdPedidoDetalle = PDA.IdPedidoDetalle  
        LEFT JOIN Petrovendor.dbo.MM_Pedido PO (NOLOCK)
            ON P.IdPedido = PO.IdPedido 
        LEFT JOIN Petrovendor.dbo.MM_Pedidos PS (NOLOCK)
            ON  PO.IdPedido = PS.IdIdentificador 
               AND PO.IdProveedorCompras = PS.IdProveedorCliente 
			   AND PS.IdTipoPedido IN (2, 4 ,6) --> CTES PEDIDO DE 2 MERCADEO, 4 ADJ DIRECTA, 6 MANO DE OBRA
        LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF (NOLOCK)
            ON  PDA.IdAceptacionPedido = AF.IdAceptacionPedido 
        LEFT JOIN Petrovendor.dbo.TA_Operacion O (NOLOCK)
            ON AF.IdAceptacionFactura = O.IdDocumento 
               AND PO.IdSubcontratista = O.IdProveedor
        LEFT JOIN Petrovendor.dbo.TA_Estatus T (NOLOCK)
            ON  O.IdEstatusOperacion = T.IdEstatus 
               AND O.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA
               AND O.IdEstatusOperacion IN ( 1 ) --> ESTATUS EN APROBACIÓN
               AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADA LA ACEPTACIÓN
		LEFT JOIN dbo.MM_AceptacionPedidoDetalle apd  (NOLOCK)
			ON  PDA.IdAceptacionPedido	 = apd.IdAceptacionPedido 
    WHERE AF.IdAceptacionFactura IS NULL
    GROUP BY ISNULL(P.MontoOrdenDls, 0),
             P.IdSolicitudPedido,
             P.IdLineaPresupuesto,
             P.IdPedido,
             P.IdPedidoDetalle,
             PS.IdPedido,
             PDA.IdAceptacionPedido,
             apd.IdAceptacionPedidoDetalle
    ORDER BY P.IdPedido DESC;
	

	INSERT INTO @TablaAceptacion
	(
	    IdPedidoDetalle,
	    IdMaterial,
	    PrecioUnitario,
	    IdPedido,
	    OrdenCompra,
	    CantidadPedido,
	    CantidadAceptada,
	    CantidadRestante,
		IdAceptacionPedido
	)
	SELECT filtro.IdPedidoDetalle, 
	pd.IdMaterial, 
	pd.PrecioUnitario,
	P.IdPedido, 
	filtro.OrdenCompra, 
	pd.Cantidad cantidadPedido, 
	ISNULL(apd.Cantidad,0) cantidadAceptada, 
	pd.Cantidad - ISNULL(apd.Cantidad,0) cantidadRestante, 
	ap.IdAceptacionPedido
	FROM dbo.MM_Pedido AS P
    INNER JOIN dbo.MM_PedidoDetalle AS pd  (NOLOCK)
	ON P.IdPedido = pd.IdPedido 
	INNER JOIN @TablaFiltro filtro 
	ON  P.IdPedido  = filtro.IdPedido
	AND  pd.IdPedidoDetalle = filtro.IdPedidoDetalle 
	LEFT JOIN dbo.MM_AceptacionPedido AP  (NOLOCK)
	ON P.IdPedido  = AP.IdPedido
	AND ISNULL(AP.IdEstatusEliminado,0) = 0 --> QUE LA ACEPTACIÓN NO ESTE ELIMINADA
	LEFT JOIN dbo.MM_AceptacionPedidoDetalle APD  (NOLOCK)
	ON PD.IdPedidoDetalle = APD.IdPedidoDetalle 
	AND AP.IdAceptacionPedido=APD.IdAceptacionPedido
	GROUP BY ISNULL(apd.Cantidad, 0),
            pd.Cantidad - ISNULL(apd.Cantidad, 0),
            filtro.IdPedidoDetalle,
            pd.IdMaterial,
            pd.PrecioUnitario,
            P.IdPedido,
            filtro.OrdenCompra,
            pd.Cantidad,
            AP.IdAceptacionPedido


	SELECT filtro.IdSolicitudPedido,  
           filtro.OrdenCompra,
           linea.NombreLinea ,
		   m.DescripcionCorta AS Material,
		   acepta.IdAceptacionPedido,
           pd.PrecioUnitario,
           acepta.CantidadPedido,
           acepta.CantidadAceptada,
           acepta.CantidadRestante,
		   (pd.Cantidad * pd.PrecioUnitario)/ cambio.TipoCambio as MontoOrdenCompraDls,
		   (acepta.CantidadAceptada * pd.PrecioUnitario)/ cambio.TipoCambio as MontoAceptacionDls, 
		   (acepta.CantidadRestante * pd.PrecioUnitario)/ cambio.TipoCambio as MontoRestanteDls,   
		   filtro.IdPedido,
		   filtro.IdPedidoDetalle
	FROM @TablaFiltro filtro 
	INNER JOIN @LineasPresupuesto linea 
		ON filtro.IdLineaSolpedOAceptacion = linea.IdLineaPresupuesto 
	INNER JOIN Petrovendor.dbo.MM_Pedido p WITH(NOLOCK) 
		ON filtro.IdPedido = p.IdPedido 
	INNER JOIN Petrovendor.dbo.MM_PedidoDetalle pd WITH(NOLOCK) 
		ON p.IdPedido  = pd.IdPedido 
		AND  filtro.IdPedidoDetalle = pd.IdPedidoDetalle 
	LEFT JOIN @TablaAceptacion acepta 
		ON  pd.IdPedidoDetalle  = acepta.IdPedidoDetalle 
		AND  pd.IdPedido  = acepta.IdPedido 
	LEFT JOIN Adinco.dbo.CO_TipoCambioDiario cambio WITH(NOLOCK)
        ON pd.IdMoneda = cambio.IdMoneda  
           AND DAY(pd.CreadoEl) = DAY(cambio.Fecha)
           AND MONTH(pd.CreadoEl) = MONTH(cambio.Fecha)
           AND YEAR(pd.CreadoEl) = YEAR(cambio.Fecha) 
	LEFT JOIN Adinco.dbo.PV_TipoMoneda mon WITH(NOLOCK) 
		ON  pd.IdMoneda = mon.IdMoneda
	LEFT JOIN Petrovendor.dbo.MM_Material m WITH(NOLOCK) 
		ON  pd.IdMaterial = m.IdMaterial 
	GROUP BY (pd.Cantidad * pd.PrecioUnitario) / cambio.TipoCambio,
             (acepta.CantidadAceptada * pd.PrecioUnitario) / cambio.TipoCambio,
             (acepta.CantidadRestante * pd.PrecioUnitario) / cambio.TipoCambio,
             filtro.IdSolicitudPedido,
             filtro.OrdenCompra,
             linea.NombreLinea,
             m.DescripcionCorta,
             acepta.IdAceptacionPedido,
             pd.PrecioUnitario,
             acepta.CantidadPedido,
             acepta.CantidadAceptada,
             acepta.CantidadRestante,
             filtro.IdPedido,
             filtro.IdPedidoDetalle
		ORDER BY filtro.IdSolicitudPedido DESC