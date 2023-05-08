
CREATE PROCEDURE [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasCNExtranjeros]
@Estatus		INT,  
@ProveedorId INT = 0
AS
BEGIN

    CREATE TABLE #AceptacionesPedidoExtranjeros(  
	 IdAceptacionPedido INT null,  
	 Pedido NVARCHAR(max) null,  
	 IdPedido INT null,  
	 Creado DATETIME null,  
	 NombreUsuarioEntrega NVARCHAR(max) null,  
	 Cliente NVARCHAR(max) null,  
	 IdPedidoGeneral INT null,  
	 IdAceptacionCartaPCN INT null,  
	 IdTipoPedido INT null,  
	 EstatusAprobacion NVARCHAR(100) NULL,  
	 span NVARCHAR(500) NULL  
	);  

	CREATE TABLE #AceptacionConPedimentos (IdAceptacionPedido INT)	
	
	-- OBTENER LAS ACEPTACIONES DE PEDIDO QUE SON DE PROVEEDORES EXTRANJERAS
	IF (@Estatus =0 OR @Estatus =4)
	BEGIN 
		-- OBTENER ACEPTACIONES CON PEDIMENTOS QUE YA TIENE UNA APROBACION DE PEDIMENTO
		INSERT INTO #AceptacionConPedimentos(IdAceptacionPedido)
		SELECT        
		AP.IdAceptacionPedido  
		FROM MM_AceptacionPedido AP 
		JOIN dbo.MM_Pedido P 
			ON AP.IdPedido = P.IdPedido 
		JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		JOIN dbo.FI_PedimentoComprobante PC 
			ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		JOIN dbo.TA_Operacion O 
			ON PC.IdPedimentoComprobante  = O.IdDocumento
			AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA		
		AND P.IdSubcontratista=@ProveedorId  		
		AND ISNULL(PC.IdEstatusEliminado,0)<>1  --> NO MOSTRAR COMPROBANTES CON ESTATUS ELIMINADO		
		GROUP BY  AP.IdAceptacionPedido  

		--> OBTENER ACEPTACIONES DE PEDIDO QUE SON EXTRANJERAS PERO QUE LES FALTA INICIAR CARGA DE CONTENIDO NACIONAL, EXCEPTUANDO LAS ACEPTACIONES QUE YA TIENE UNA APROBACION DE PEDIMENTO
		INSERT INTO #AceptacionesPedidoExtranjeros(
		 IdAceptacionPedido,  
		 Pedido,  
		 IdPedido,  
		 Creado,  
		 NombreUsuarioEntrega,  
		 Cliente,  
		 IdPedidoGeneral,  
		 IdAceptacionCartaPCN,  
		 IdTipoPedido,  
		 EstatusAprobacion,  
		 span)
		SELECT   
		A.IdAceptacionPedido,  
		CAST(PG.IdPedido AS NVARCHAR(50)) AS Pedido,  
		A.IdPedido,  
		A.Creado,  
		A.NombreUsuarioEntrega,  
		CONCAT(ISNULL(PV.RazonSocial,''),' ', ISNULL(PV.RegimenCapital,'')) AS Cliente,  
		PG.IdPedido AS IdPedidoGeneral,  
		AC.IdAceptacionCartaPCN,  
		TP.IdTipoPedido,  
		ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') AS EstatusAprobacion,  
		CASE  
		WHEN TV.IdTipoValidacionDoc = 2 THEN 'label label-success'  
		WHEN TV.IdTipoValidacionDoc = 1 THEN 'label label-primary'  
		WHEN TV.IdTipoValidacionDoc = 3 THEN 'label label-danger'  
		WHEN TV.IdTipoValidacionDoc IS NULL THEN 'label label-default'  
		END  
		FROM dbo.MM_Pedido AS P   
		JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND  P.IdProveedorCompras=PG.IdProveedorCliente   
			AND PG.IdTipoPedido in (2,4, 6)  --> CTES TIPOS DE PEDIDOS
		JOIN MM_AceptacionPedido AS A 
			ON P.IdPedido = A.IdPedido
		JOIN DEA_SolicitudCNProveedorExtranjero SCNP
			ON P.IdSubcontratista = SCNP.IdProveedor
			AND P.IdContrato =  SCNP.IdContrato
			AND SCNP.Activo=1  --> CTE QUE ESTE ACTIVO EL PERMISO
		JOIN S_Proveedor AS PV 
			ON P.IdProveedorCompras  = PV.IdProveedor
		JOIN RelacionCartaCNPedido rel 
			ON A.IdAceptacionPedido    = rel.IdAceptacionPedido 
			AND P.IdPedido  = rel.IdPedido 
			AND rel.PedirCarta = 1  --> CTE 
		LEFT JOIN MM_AceptacionCartaPCN AS AC 
			ON A.IdAceptacionPedido  = AC.IdAceptacionPedido
			AND ISNULL(AC.IdEstatusEliminado,0) <> 1  		
		LEFT JOIN S_TipoValidacionDoc AS TV 
			ON AC.IdEstatus  = TV.IdTipoValidacionDoc
		LEFT JOIN dbo.MM_TipoPedido AS TP 
			ON PG.IdTipoPedido = TP.IdTipoPedido 
		LEFT JOIN #AceptacionConPedimentos ACPEA
			ON A.IdAceptacionPedido = ACPEA.IdAceptacionPedido
		WHERE P.IdSubcontratista = @ProveedorId  
		AND AC.IdAceptacionCartaPCN IS NULL   
		AND ACPEA.IdAceptacionPedido IS NULL --> QUE NO ESTE EN ESTA TABLA #AceptacionConPedimentos			
		AND ISNULL(A.IdEstatusEliminado,0)<>1 -->CTE OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
		AND ISNULL(A.IdNacionalidadProveedor,0) = 2 -->CTE NACIONALIDAD EXTRANJERA     
		GROUP BY     
		A.IdAceptacionPedido,  
		A.IdPedido,  
		A.Creado,  
		A.NombreUsuarioEntrega,  
		PV.RazonSocial,  
		PV.RegimenCapital,  
		PG.IdPedido ,  
		AC.IdAceptacionCartaPCN,  
		TV.TipoValidacion,  
		TP.IdTipoPedido,  
		A.IdEstatusEliminado,  
		TV.IdTipoValidacionDoc  

	END 
	
    IF @Estatus IN (1,2,3)  
	BEGIN 

		 INSERT INTO #AceptacionesPedidoExtranjeros(
		 IdAceptacionPedido,  
		 Pedido,  
		 IdPedido,  
		 Creado,  
		 NombreUsuarioEntrega,  
		 Cliente,  
		 IdPedidoGeneral,  
		 IdAceptacionCartaPCN,  
		 IdTipoPedido,  
		 EstatusAprobacion,  
		 span)
		  SELECT   
		   A.IdAceptacionPedido,  
		   CAST(PG.IdPedido AS NVARCHAR(50)) AS Pedido,  
		   A.IdPedido,  
		   A.Creado,  
		   A.NombreUsuarioEntrega,  
		   CONCAT(ISNULL(PV.RazonSocial,''),' ', ISNULL(PV.RegimenCapital,'')) AS Cliente,  
		   PG.IdPedido AS IdPedidoGeneral,  
		   AC.IdAceptacionCartaPCN,  
		   TP.IdTipoPedido,  
		   ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') AS EstatusAprobacion,  
		   CASE  
			WHEN TV.IdTipoValidacionDoc = 2 THEN 'label label-success'  
			WHEN TV.IdTipoValidacionDoc = 1 THEN 'label label-primary'  
			WHEN TV.IdTipoValidacionDoc = 3 THEN 'label label-danger'  
			WHEN TV.IdTipoValidacionDoc IS NULL THEN 'label label-default'  
		   END   
		   FROM dbo.MM_Pedido AS P   
		   JOIN MM_Pedidos AS PG 
				ON P.IdPedido = PG.IdIdentificador 
				AND P.IdProveedorCompras  = PG.IdProveedorCliente  
				AND PG.IdTipoPedido in (2,4, 6) --> CTES TIPOS DE PEDIDOS
		   JOIN MM_AceptacionPedido AS A 
				ON P.IdPedido = A.IdPedido     
		   JOIN S_Proveedor AS PV 
				ON P.IdProveedorCompras = PV.IdProveedor    
		   JOIN MM_AceptacionCartaPCN AS AC 
				ON A.IdAceptacionPedido = AC.IdAceptacionPedido   
		   JOIN dbo.S_TipoValidacionDoc AS TV 
				ON AC.IdEstatus  = TV.IdTipoValidacionDoc    
		   JOIN dbo.MM_TipoPedido AS TP 
				ON PG.IdTipoPedido = TP.IdTipoPedido   
		   JOIN dbo.RelacionCartaCNPedido rel 
				ON A.IdAceptacionPedido = rel.IdAceptacionPedido    
				AND rel.IdPedido = P.IdPedido 
				AND rel.PedirCarta = 1  --> CTE 
				 WHERE P.IdSubcontratista = @ProveedorId  
		   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
		   AND ISNULL(AC.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACION CARTA CN  
		   AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
					FROM dbo.MM_AceptacionCartaPCN A_PCN   
					WHERE A.IdAceptacionPedido=A_PCN.IdAceptacionPedido 
					ORDER BY A_PCN.CreadoEl DESC)        
		   ) AND AC.IdEstatus =@Estatus 
		   AND ISNULL(A.IdNacionalidadProveedor,0) = 2 --> NACIONALIDAD EXTRANJERA  
		   GROUP BY     
		   A.IdAceptacionPedido,  
		   A.IdPedido,  
		   A.Creado,  
		   A.NombreUsuarioEntrega,  
		   PV.RazonSocial,  
		   PV.RegimenCapital,  
		   PG.IdPedido ,  
		   AC.IdAceptacionCartaPCN,  
		   TV.TipoValidacion,  
		   TP.IdTipoPedido,  
		   TV.IdTipoValidacionDoc  
		   ORDER BY A.IdAceptacionPedido DESC; 
	END 
			
	 IF @Estatus =4  
	 BEGIN  

	     INSERT INTO #AceptacionesPedidoExtranjeros(
		 IdAceptacionPedido,  
		 Pedido,  
		 IdPedido,  
		 Creado,  
		 NombreUsuarioEntrega,  
		 Cliente,  
		 IdPedidoGeneral,  
		 IdAceptacionCartaPCN,  
		 IdTipoPedido,  
		 EstatusAprobacion,  
		 span)
		  SELECT   
		   A.IdAceptacionPedido,  
		   CAST(PG.IdPedido AS NVARCHAR(50)) AS Pedido,  
		   A.IdPedido,  
		   A.Creado,  
		   A.NombreUsuarioEntrega,  
		   CONCAT(ISNULL(PV.RazonSocial,''),' ', ISNULL(PV.RegimenCapital,'')) AS Cliente,  
		   PG.IdPedido AS IdPedidoGeneral,  
		   AC.IdAceptacionCartaPCN,  
		   TP.IdTipoPedido,  
		   ISNULL(TV.TipoValidacion,'Sin iniciar aprobación') AS EstatusAprobacion,  
		   CASE  
			WHEN TV.IdTipoValidacionDoc = 2 THEN 'label label-success'  
			WHEN TV.IdTipoValidacionDoc = 1 THEN 'label label-primary'  
			WHEN TV.IdTipoValidacionDoc = 3 THEN 'label label-danger'  
			WHEN TV.IdTipoValidacionDoc IS NULL THEN 'label label-default'  
		   END  
			FROM dbo.MM_Pedido AS P   
		   JOIN MM_Pedidos AS PG 
				ON P.IdPedido = PG.IdIdentificador
				AND  P.IdProveedorCompras   = PG.IdProveedorCliente
				AND PG.IdTipoPedido in (2,4, 6) --> CTES TIPOS DE PEDIDOS
		   JOIN MM_AceptacionPedido AS A 
				ON P.IdPedido = A.IdPedido 
		   JOIN dbo.MM_AceptacionCartaPCN AS AC 
				ON A.IdAceptacionPedido  = AC.IdAceptacionPedido 
				AND ISNULL(AC.IdEstatusEliminado,0)<>1  
		   JOIN dbo.S_TipoValidacionDoc AS TV
				ON AC.IdEstatus   = TV.IdTipoValidacionDoc
		   JOIN S_Proveedor AS PV 
				ON  P.IdProveedorCompras  = PV.IdProveedor  
		   JOIN dbo.MM_TipoPedido AS TP 
				ON PG.IdTipoPedido  = TP.IdTipoPedido 
		   JOIN dbo.RelacionCartaCNPedido rel 
				ON A.IdAceptacionPedido = rel.IdAceptacionPedido 
				AND  P.IdPedido = rel.IdPedido
				AND rel.PedirCarta = 1  --> CTE 
		   WHERE P.IdSubcontratista = @ProveedorId  
		   AND AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN   
					FROM dbo.MM_AceptacionCartaPCN A_PCN   
					WHERE A.IdAceptacionPedido = A_PCN.IdAceptacionPedido  
					ORDER BY A_PCN.CreadoEl DESC)   
		   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
		   AND ISNULL(A.IdNacionalidadProveedor,0) = 2 --> NACIONALIDAD EXTRANJERA     
		   GROUP BY     
		   A.IdAceptacionPedido,  
		   A.IdPedido,  
		   A.Creado,  
		   A.NombreUsuarioEntrega,  
		   PV.RazonSocial,  
		   PV.RegimenCapital,  
		   PG.IdPedido ,  
		   AC.IdAceptacionCartaPCN,  
		   TV.TipoValidacion,  
		   TP.IdTipoPedido,  
		   A.IdEstatusEliminado,  
		   TV.IdTipoValidacionDoc  	

	 END 

	 SELECT IdAceptacionPedido,  
		 Pedido,  
		 IdPedido,  
		 Creado,  
		 NombreUsuarioEntrega,  
		 Cliente,  
		 IdPedidoGeneral,  
		 IdAceptacionCartaPCN,  
		 IdTipoPedido,  
		 EstatusAprobacion,  
		 span  
	FROM #AceptacionesPedidoExtranjeros
END
