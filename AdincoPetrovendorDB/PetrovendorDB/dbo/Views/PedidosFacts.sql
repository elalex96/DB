CREATE VIEW dbo.PedidosFacts
AS
	  SELECT DISTINCT 
       P.IdPedido AS 'idpedido unico', 
       INS.IdInstalacion AS 'idinstalacion', 
       S.IdSolicitudPedido AS 'idunico de requisicion', 
       CAST(P.CreadoEl AS DATE) AS 'Fecha de pedido', 
       Pr.RazonSocial AS 'Proveedor', 
       U.Nombre AS 'Comprador', 
       PS.IdPedido AS 'Numero de Pedido', 
       ES.Nombre AS 'Estatus Pedido', 
       SPD.IdSolicitudPedidoDetalle AS 'Id partida', 
       M.DescripcionLarga AS 'Descripcion del producto', 
       PD.Cantidad AS 'Cantidad', 
       Un.Unidad AS 'Unidad', 
       CAST(PD.PrecioUnitario AS MONEY) AS 'Precio unitario', 
       CAST(PD.Subtotal AS MONEY) AS 'Subtotal', 
       US.Nombre AS 'Aprobador actual',
       CASE
           WHEN MAX(CAST(P.FechaEnvioPedido AS DATE)) IS NULL
           THEN ISNULL(CAST(S.FechaEntregaFinRequerida AS DATE), CAST(S.FechaEntregaRequerida AS DATE))
           ELSE MAX(CAST(P.FechaEnvioPedido AS DATE))
       END AS 'Fecha Aprobado', 
       CAST(S.FechaEntregaRequerida AS DATE) AS 'Fecha entrega inicial', 
       ISNULL(CAST(S.FechaEntregaFinRequerida AS DATE), CAST(S.FechaEntregaRequerida AS DATE)) AS 'Fecha entrega final', 
       ISNULL(PD.DiasCredito, 60) AS 'Dias de credito', --> DIAS DE CREDITO ESTAN POR DETALLE DE CADA MATERIAL DEL PEDIDO
       TM.TipoMonedaCorto AS 'Moneda', 
       Co.NumeroContrato AS 'Contrato',
	   FT.IdTipoFlujo,
	   TA.NoSecuencia
    FROM MM_Pedido AS P   
	JOIN dbo.TA_Operacion TAO ON TAO.IdDocumento = P.IdSolicitudPedido 
		AND P.Version=TAO.NoVersion  --> LA VERSION DEL PEDIDO DEBE SER IGUAL AL DE LA APROBACIÓN DE PEDIDO  
	 JOIN dbo.TA_FlujoTarea FT ON FT.IdFlujoTarea = TAO.IdFlujoTarea
     JOIN dbo.TA_Estatus ES ON TAO.IdEstatusOperacion = ES.IdEstatus
     JOIN MM_PeticionOferta AS O ON O.IdPeticionOferta = P.IdPeticionOferta
     JOIN MM_SolicitudPedido AS S ON O.IdSolicitudPedido = S.IdSolicitudPedido     
     JOIN S_Proveedor AS Pr ON P.IdSubcontratista = Pr.IdProveedor
     JOIN S_Usuario AS U ON P.CreadoPor = U.IdUsuario
     JOIN MM_PedidoDetalle AS PD ON P.IdPedido = PD.IdPedido		
     JOIN MM_Material AS M ON PD.IdMaterial = M.IdMaterial
     JOIN PV_MM_MaterialUnidad AS Un ON PD.IdUnidadProveedor = Un.IdUnidad
     JOIN PV_TipoMoneda AS TM ON PD.IdMoneda = TM.IdMoneda
	 JOIN dbo.MM_PeticionOfertaDetalle POD ON POD.IdPeticionOferta=O.IdPeticionOferta
	 AND POD.IdPeticionOfertaDetalle=PD.IdPeticionOfertaDetalle
	 JOIN MM_SolicitudPedidoDetalle AS SPD ON S.IdSolicitudPedido = SPD.IdSolicitudPedido
	 AND SPD.IdSolicitudPedidoDetalle=POD.IdSolicitudPedidoDetalle
	 JOIN MM_SolicitudPedidoDetalleLineaPresupuesto AS SPL ON SPL.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle 
     JOIN dbo.TA_Tarea TA ON TA.IdOperacion = TAO.IdOperacion
	 LEFT JOIN dbo.TA_Tarea TAA  ON TAA.IdOperacion = TA.IdOperacion AND TAA.NoSecuencia=(TA.NoSecuencia - 1)  AND TAA.Activo=1
     JOIN dbo.TA_Estatus ESTA ON ESTA.IdEstatus = TA.IdEstatus
     JOIN dbo.S_Usuario US ON US.IdUsuario = TA.IdAprobador     
     JOIN adinco.dbo.CO_Instalacion INS ON SPL.IdInstalacion = INS.IdInstalacion
     JOIN adinco.dbo.CO_Contrato AS CO ON CO.IdContrato = P.IdContrato
	 JOIN MM_Pedidos AS PS ON P.IdPedido = PS.IdIdentificador AND P.IdProveedorCompras=PS.IdProveedorCliente
WHERE P.IdProveedorCompras IN(606, 676, 690, 1315, 1424)         
     AND TAO.IdTipoOperacion = 9  --> APROBACIÓN DE TIPO PEDIDO
     AND TA.IdEstatus = 1  --> SOLO ESTARIA MANDANDO LOS PEDIDOS QUE TENGAN ALGÚN APROBADOR CON EL ESTATUS EN APROBACIÓN, DESCARTANDO DE LA CONSULTA LOS PEDIDOS APROBADOS
     AND P.IdEstatusEliminado IS NULL 
	 AND  CASE WHEN FT.IdTipoFlujo=1 AND ISNULL(TAA.IdTarea,0)>0  AND TAA.IdEstatus <> 2 THEN --> SI EL FLUJO DE APROBACIÓN ES SERIAL Y EL APROBADOR ANTERIOR NO HA REALIZADO LA APROBACIÓN NO MOSTRAR ESTE APROBADOR NI SU RELACIÓN PEDIDO
		0
	 WHEN  FT.IdTipoFlujo=1 AND ISNULL(TAA.IdTarea,0)>0 AND TAA.IdEstatus =2 THEN --> SI EL FLUJO DE APROBACIÓN ES SERIAL Y EL APROBADOR ANTERIOR YA HA REALIZADO LA APROBACIÓN O FUE REASIGNADO MOSTRAR ESTE APROBADOR Y SU RELACIÓN PEDIDO
		1
	 WHEN FT.IdTipoFlujo=1 AND ISNULL(TAA.IdTarea,0)=0  THEN --> SI EL FLUJO ES SERIAL Y NO SE ENCONTRO NINGUN PROVEEDOR ANTERIOR MOSTRAR TODAS LAS RELACIONA DE APROBADORES EN APROBACIÓN
		1
	 WHEN FT.IdTipoFlujo=2 THEN --> SI EL FLUJO DE APROBACIÓN ES PARALELO MOSTRAR TODOS LOS APROBADORES RELACIONADO AL PEDIDO
	  1
	 END =1	 
GROUP BY P.IdPedido, 
		 PD.IdPedido,
         INS.IdInstalacion, 
         S.IdSolicitudPedido, 
         CAST(P.CreadoEl AS DATE), 
         Pr.RazonSocial, 
         U.Nombre, 
         PS.IdPedido, 
         ES.Nombre, 
         SPD.IdSolicitudPedidoDetalle, 
         M.DescripcionLarga, 
         PD.Cantidad, 
         Un.Unidad, 
		 PD.DiasCredito,
         CAST(PD.PrecioUnitario AS MONEY), 
         CAST(PD.Subtotal AS MONEY), 
         US.Nombre, 
         CAST(S.FechaEntregaFinRequerida AS DATE), 
         CAST(S.FechaEntregaRequerida AS DATE), 
         ISNULL(P.DiasCredito, 60), 
         TM.TipoMonedaCorto, 
		 FT.IdTipoFlujo,
         Co.NumeroContrato,
		 TA.NoSecuencia
		 --ORDER BY P.IdPedido DESC		 

--SE REPITE EL NO PEDIDO Y EL IDPEDIDOUNICO POR QUE PUEDE SER QUE EXISTAN MÁS DE UN PEDIDO DETALLE (PARTIDA) POR CABECERA DE PEDIDO
--EL PRODUCTO SE REPITE YA QUE SE ESTA BUSCANDO TODOS LOS APROBADORES DE LA APROBACIÓN DEL PEDIDO Y SI LA APROBACIÓN DEL PEDIDO ES EN PARALELO LA CONSULTA MOSTRARA N RESULTADOS POR PEDIDO SEGÚN LA CANTIDAD DE APROBADORES EN APROBACIÓN
--EL NUMERO DE REQUISICION SE REPITE YA QUE UN PEDIDO CABECERA PUEDE TENER N PEDIDOS 
--CADA MATERIAL POR PEDIDO SE VA REPETIR SEGÚN LA CANTIDAD DE APROBADORES EN APROBACIÓN SI ES PARALELO