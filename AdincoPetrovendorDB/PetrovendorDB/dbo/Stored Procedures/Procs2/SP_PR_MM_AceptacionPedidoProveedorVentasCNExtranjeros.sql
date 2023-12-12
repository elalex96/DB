USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PR_MM_AceptacionPedidoProveedorVentasCNExtranjeros'
)
    DROP PROCEDURE SP_PR_MM_AceptacionPedidoProveedorVentasCNExtranjeros;
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasCNExtranjeros]    Script Date: 06/11/2023 06:36:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Cruz
-- Update date:	11-12-2023
-- Description:	Se agrego mejoras en consulta sql
-- =============================================
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
	CREATE TABLE #AceptacionCartaVersiones (IdAceptacionCartaPCN INT, Creado DATETIME,IdAceptacionPedido INT)	
	CREATE TABLE #AceptacionCartaUltimaVersion (IdAceptacionCartaPCN INT,IdAceptacionPedido INT)	
	
	-- OBTENER LAS ACEPTACIONES DE PEDIDO QUE SON DE PROVEEDORES EXTRANJERAS
	IF (@Estatus =0 OR @Estatus =4)
	BEGIN 
		-- OBTENER ACEPTACIONES CON PEDIMENTOS QUE YA TIENE UNA APROBACION DE PEDIMENTO
		INSERT INTO #AceptacionConPedimentos(IdAceptacionPedido)
		SELECT        
		AP.IdAceptacionPedido
		FROM MM_AceptacionPedido AP (NOLOCK)
		JOIN dbo.MM_Pedido P (NOLOCK)
			ON AP.IdPedido = P.IdPedido 
		JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK)
			ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
			ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		JOIN dbo.TA_Operacion O (NOLOCK)
			ON PC.IdPedimentoComprobante  = O.IdDocumento
			AND O.IdTipoOperacion = 16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
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
		FROM dbo.MM_Pedido AS P (NOLOCK)  
		JOIN MM_Pedidos AS PG (NOLOCK)
			ON P.IdPedido = PG.IdIdentificador 
			AND  P.IdProveedorCompras=PG.IdProveedorCliente   
			AND PG.IdTipoPedido in (2,4, 6)  --> CTES TIPOS DE PEDIDOS
		JOIN MM_AceptacionPedido AS A (NOLOCK)
			ON P.IdPedido = A.IdPedido
		JOIN DEA_SolicitudCNProveedorExtranjero SCNP (NOLOCK)
			ON P.IdSubcontratista = SCNP.IdProveedor
			AND P.IdContrato =  SCNP.IdContrato
			AND SCNP.Activo=1  --> CTE QUE ESTE ACTIVO EL PERMISO
		JOIN S_Proveedor AS PV (NOLOCK)
			ON P.IdProveedorCompras  = PV.IdProveedor
		JOIN RelacionCartaCNPedido rel (NOLOCK) 
			ON A.IdAceptacionPedido    = rel.IdAceptacionPedido 
			AND P.IdPedido  = rel.IdPedido 
			AND rel.PedirCarta = 1  --> CTE 
		LEFT JOIN MM_AceptacionCartaPCN AS AC (NOLOCK)
			ON A.IdAceptacionPedido  = AC.IdAceptacionPedido
			AND ISNULL(AC.IdEstatusEliminado,0) <> 1  		
		LEFT JOIN S_TipoValidacionDoc AS TV (NOLOCK)
			ON AC.IdEstatus  = TV.IdTipoValidacionDoc
		LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
			ON PG.IdTipoPedido = TP.IdTipoPedido 
		LEFT JOIN #AceptacionConPedimentos ACPEA (NOLOCK)
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
		   FROM dbo.MM_Pedido AS P (NOLOCK)
		   JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador 
				AND P.IdProveedorCompras  = PG.IdProveedorCliente  
				AND PG.IdTipoPedido in (2,4, 6) --> CTES TIPOS DE PEDIDOS
		   JOIN MM_AceptacionPedido AS A (NOLOCK)
				ON P.IdPedido = A.IdPedido     
		   JOIN S_Proveedor AS PV (NOLOCK)
				ON P.IdProveedorCompras = PV.IdProveedor    
		   JOIN MM_AceptacionCartaPCN AS AC (NOLOCK)
				ON A.IdAceptacionPedido = AC.IdAceptacionPedido   
		   JOIN dbo.S_TipoValidacionDoc AS TV (NOLOCK)
				ON AC.IdEstatus  = TV.IdTipoValidacionDoc    
		   JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
				ON PG.IdTipoPedido = TP.IdTipoPedido   
		   JOIN dbo.RelacionCartaCNPedido rel (NOLOCK)
				ON A.IdAceptacionPedido = rel.IdAceptacionPedido    
				AND P.IdPedido = rel.IdPedido
				AND rel.PedirCarta = 1  --> CTE 
				 WHERE P.IdSubcontratista = @ProveedorId  
		   AND ISNULL(A.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO   
		   AND ISNULL(AC.IdEstatusEliminado,0)<>1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACION CARTA CN  
		   AND AC.IdEstatus =@Estatus 
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

		   --OBTENER TODAS LA VERSIONES Y FECHAS DE LAS CARTAS DE CONTENIDO NACIONAL
		   INSERT INTO #AceptacionCartaVersiones(IdAceptacionCartaPCN,Creado,IdAceptacionPedido)
		   SELECT ACN.IdAceptacionCartaPCN, ACN.CreadoEl, ACN.IdAceptacionPedido
		   FROM #AceptacionesPedidoExtranjeros APE  (NOLOCK)
		   JOIN MM_AceptacionCartaPCN ACN
				ON APE.IdAceptacionCartaPCN = ACN.IdAceptacionCartaPCN
			GROUP BY ACN.IdAceptacionCartaPCN, ACN.CreadoEl, ACN.IdAceptacionPedido
		   
		   -- OBTENER LA ULTIMA VERSIÓN
		   INSERT INTO #AceptacionCartaUltimaVersion(IdAceptacionPedido,IdAceptacionCartaPCN)
		   SELECT  IdAceptacionPedido, MAX(IdAceptacionCartaPCN)
		   FROM #AceptacionCartaVersiones ACV  (NOLOCK)
		   GROUP BY IdAceptacionPedido
		 

		   -- ELIMINAR LAS VERSIONES MAS ANTGUAS Y DEJAR LA MAS RECIENTE 
		   DELETE APE
		   FROM #AceptacionesPedidoExtranjeros APE  (NOLOCK)
		   LEFT JOIN #AceptacionCartaUltimaVersion ACUV (NOLOCK)
				ON APE.IdAceptacionCartaPCN = APE.IdAceptacionCartaPCN
		   WHERE APE.IdAceptacionCartaPCN IS NULL

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
			FROM dbo.MM_Pedido AS P (NOLOCK)  
		   JOIN MM_Pedidos AS PG (NOLOCK)
				ON P.IdPedido = PG.IdIdentificador
				AND  P.IdProveedorCompras   = PG.IdProveedorCliente
				AND PG.IdTipoPedido in (2,4, 6) --> CTES TIPOS DE PEDIDOS
		   JOIN MM_AceptacionPedido AS A (NOLOCK)
				ON P.IdPedido = A.IdPedido 
		   JOIN dbo.MM_AceptacionCartaPCN AS AC (NOLOCK)
				ON A.IdAceptacionPedido  = AC.IdAceptacionPedido 
				AND ISNULL(AC.IdEstatusEliminado,0)<>1  
		   JOIN dbo.S_TipoValidacionDoc AS TV (NOLOCK)
				ON AC.IdEstatus   = TV.IdTipoValidacionDoc
		   JOIN S_Proveedor AS PV (NOLOCK)
				ON  P.IdProveedorCompras  = PV.IdProveedor  
		   JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
				ON PG.IdTipoPedido  = TP.IdTipoPedido 
		   JOIN dbo.RelacionCartaCNPedido rel (NOLOCK)
				ON A.IdAceptacionPedido = rel.IdAceptacionPedido 
				AND  P.IdPedido = rel.IdPedido
				AND rel.PedirCarta = 1  --> CTE 
		   WHERE P.IdSubcontratista = @ProveedorId  
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

	       --OBTENER TODAS LA VERSIONES Y FECHAS DE LAS CARTAS DE CONTENIDO NACIONAL
		   INSERT INTO #AceptacionCartaVersiones(IdAceptacionCartaPCN,Creado,IdAceptacionPedido)
		   SELECT ACN.IdAceptacionCartaPCN, ACN.CreadoEl, ACN.IdAceptacionPedido
		   FROM #AceptacionesPedidoExtranjeros APE  (NOLOCK)
		   JOIN MM_AceptacionCartaPCN ACN (NOLOCK)
				ON APE.IdAceptacionCartaPCN = ACN.IdAceptacionCartaPCN
				AND APE.IdAceptacionPedido = ACN.IdAceptacionPedido
			GROUP BY ACN.IdAceptacionCartaPCN, ACN.CreadoEl, ACN.IdAceptacionPedido
		   
		   -- OBTENER LA ULTIMA VERSIÓN
		   INSERT INTO #AceptacionCartaUltimaVersion(IdAceptacionPedido,IdAceptacionCartaPCN)
		   SELECT  IdAceptacionPedido, MAX(IdAceptacionCartaPCN)
		   FROM #AceptacionCartaVersiones ACV (NOLOCK)
		   GROUP BY IdAceptacionPedido		 

		   -- ELIMINAR LAS VERSIONES MAS ANTGUAS Y DEJAR LA MAS RECIENTE Y LAS QUE AUN ESTAN EN SIN INICIAR APROBACIÓN
		   DELETE APE
		   FROM #AceptacionesPedidoExtranjeros APE  (NOLOCK)
		   LEFT JOIN #AceptacionCartaUltimaVersion ACUV  (NOLOCK)
				ON APE.IdAceptacionCartaPCN = APE.IdAceptacionCartaPCN
				AND APE.IdAceptacionPedido = ACUV.IdAceptacionPedido
		   WHERE APE.IdAceptacionCartaPCN IS NULL 
		   AND APE.EstatusAprobacion <> 'Sin iniciar aprobación'
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
	GROUP BY 
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
		 span  
END