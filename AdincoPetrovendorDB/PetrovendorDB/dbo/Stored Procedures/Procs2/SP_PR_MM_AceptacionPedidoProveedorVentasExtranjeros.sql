USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros'
)
    DROP PROCEDURE SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros;
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros]    Script Date: 06/11/2023 06:36:43 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros]    Script Date: 07/11/2023 02:25:12 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 23-03-18
-- Description:	Consulta Aceptaciones de pedido de extranjeros proveedor de ventas para pedimento o comprobante
-- =============================================
-- =============================================
-- Author:		Daniel Cruz
-- Update date: 01-06-18
-- Description:	Se agrego filtro para no mostrar aquellos comprobantes extranjeros con estatus eliminado = 1
-- =============================================
-- =============================================
-- Author:		Daniel Cruz
-- Update date:	15-11-2023
-- Description:	Se agrego mejoras en consulta nolocks y evitar subconsultas
-- =============================================
CREATE  PROCEDURE [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasExtranjeros]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @Estatus INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here

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

   
   -- OBTENER LAS ACEPTACIONES DE PEDIDO QUE SON DE PROVEEDORES EXTRANJERAS Y QUE SE LES ESTA SOLICITANDO CARTA Y AUN NO ESTAN APROBADAS
	IF (@Estatus =0 OR @Estatus =4)
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
		 EXEC [dbo].[SP_PR_MM_AceptacionPedidoProveedorVentasCNExtranjeros] 4,@IdProveedor
	END 

    IF @Estatus = 0
    BEGIN

		SELECT 
		AP.IdAceptacionPedido,
        AP.IdPedido,
        AP.Creado,
        AP.NombreUsuarioEntrega,
        CONCAT(ISNULL(PR.RazonSocial, ''), ' ', ISNULL(PR.RegimenCapital, '')) AS Cliente,
        PG.IdPedido AS IdPedidoGeneral,
        TP.IdTipoPedido,
        PC.IdPedimentoComprobante,
        TP.TipoPedido  
		FROM dbo.MM_AceptacionPedido AP (NOLOCK)
		 JOIN dbo.MM_Pedido P  (NOLOCK)
			ON AP.IdPedido = P.IdPedido 
		 JOIN MM_Pedidos AS PG (NOLOCK)
             ON P.IdPedido = PG.IdIdentificador
             AND P.IdProveedorCompras = PG.IdProveedorCliente 		
			 AND PG.IdTipoPedido in (2,4,6) --> CTE PEDIDOS
		 JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
             ON  PG.IdTipoPedido = TP.IdTipoPedido
		 JOIN dbo.S_Proveedor PR (NOLOCK)
			ON P.IdProveedorCompras  = PR.IdProveedor
		 LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC  (NOLOCK)
			ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		 LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
			ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		 LEFT JOIN dbo.TA_Operacion O (NOLOCK)
			ON PC.IdPedimentoComprobante = O.IdDocumento
			AND O.IdTipoOperacion=16 		 -->CTE APROBACIÓN DE COMPROBANTE EXTRANJERO
		  LEFT JOIN #AceptacionesPedidoExtranjeros APE
				ON APE.EstatusAprobacion <> 'Aprobada'	
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> CTE NACIONALIDAD EXTRANJERA		
		 AND P.IdSubcontratista=@IdProveedor
		 AND O.IdOperacion IS NULL
		 AND ISNULL(AP.IdEstatusEliminado,0)<>1 --> NO MOSTRAR SOLICITUD DE COMPROBANTES CON ESTATUS ELIMINADO
		 AND AP.IdAceptacionPedido  <> APE.IdAceptacionPedido
		 GROUP BY AP.IdAceptacionPedido,
                 AP.IdPedido,
                 AP.Creado,
                 AP.NombreUsuarioEntrega,
                 PR.RazonSocial,
                 PR.RegimenCapital,
                 PG.IdPedido,
                 TP.IdTipoPedido,
                 PC.IdPedimentoComprobante,
                 TP.TipoPedido 
        ORDER BY AP.IdAceptacionPedido DESC;	

		/*CUANDO EN PROCURA SE REALIZA UNA ACEPTACIÓN DE PEDIDO, DEL LADO DEL PETROVEENDOR SE INICIA LA SOLICITUD DE COMPROBANTE EXTRANJERO 
		QUE ES PARA LOS PROVEEDORES CON NACIONALIDAD EXTRANJERA
		EL ESTATUS SIN INICIAR APROBACIÓN SON TODAS AQUELLAS ACEPTACIONES DE PEDIDO DONDE TODAVIA NO SE TIENE NiNGUNA RELACIÓN 
		CON UN COMPROBANTE EXTRANJERO (FI_PedimentoComprobante) EN LA TABLA FI_AceptacionPedido_PedimentoComprobante y tampoco se tiene relación con la 
		Tabla TA_Operacion*/
		/*Si una aceptación de pedido es eliminada por consecuencia todos los comprobantes con referencia a este son eliminados (Cambio de estatus IdEstatusEliminado=1)*/
    END;


    IF @Estatus IN ( 1, 2, 3 )
    BEGIN

		SELECT 
		AP.IdAceptacionPedido,
        AP.IdPedido,
        AP.Creado,
        AP.NombreUsuarioEntrega,
        CONCAT(ISNULL(PR.RazonSocial, ''), ' ', ISNULL(PR.RegimenCapital, '')) AS Cliente,
        PG.IdPedido AS IdPedidoGeneral,
        TP.IdTipoPedido,
        PC.IdPedimentoComprobante,
        TP.TipoPedido  
		FROM dbo.MM_AceptacionPedido AP (NOLOCK)
		 JOIN dbo.MM_Pedido P (NOLOCK)
			ON AP.IdPedido = P.IdPedido 
		 JOIN MM_Pedidos AS PG (NOLOCK)
             ON P.IdPedido = PG.IdIdentificador
                AND P.IdProveedorCompras = PG.IdProveedorCliente
				AND PG.IdTipoPedido in (2,4,6) --> CTE PEDIDOS
		 JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON  PG.IdTipoPedido = TP.IdTipoPedido
		 JOIN dbo.S_Proveedor PR (NOLOCK)
				ON  P.IdProveedorCompras  = PR.IdProveedor
		 LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK) 
			ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		 LEFT JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
			ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
		 LEFT JOIN dbo.TA_Operacion O (NOLOCK)
			ON PC.IdPedimentoComprobante = O.IdDocumento
			AND O.IdTipoOperacion=16 		 -->CTE APROBACIÓN DE COMPROBANTE EXTRANJERO
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> CTE NACIONALIDAD EXTRANJERA		
		 AND P.IdSubcontratista=@IdProveedor
		 AND O.IdOperacion IS NOT NULL
		 AND O.IdEstatusOperacion=@Estatus
		 AND ISNULL(PC.IdEstatusEliminado,0)<>1  --> CTE NO MOSTRAR COMPROBANTES CON ESTATUS ELIMINADO
		 GROUP BY AP.IdAceptacionPedido,
                 AP.IdPedido,
                 AP.Creado,
                 AP.NombreUsuarioEntrega,
                 PR.RazonSocial,
                 PR.RegimenCapital,
                 PG.IdPedido,
                 TP.IdTipoPedido,
                 PC.IdPedimentoComprobante,
                 TP.TipoPedido 
        ORDER BY AP.IdAceptacionPedido DESC;	
		

    END;

    IF @Estatus = 4
    BEGIN

        -- MOSTRAR TODOS LOS ULTIMOS ESTATUS DE LA ACEPTACIÓN DE CARTA DE CONTENIDO NACIONAL	
		SELECT 
		AP.IdAceptacionPedido,
        AP.IdPedido,
        AP.Creado,
        AP.NombreUsuarioEntrega,
        CONCAT(ISNULL(PR.RazonSocial, ''), ' ', ISNULL(PR.RegimenCapital, '')) AS Cliente,
        PG.IdPedido AS IdPedidoGeneral,
        TP.IdTipoPedido,
        PC.IdPedimentoComprobante,
        TP.TipoPedido ,
		CASE
            WHEN O.IdEstatusOperacion IS NOT NULL THEN
                E.Nombre			
            ELSE
                'Sin iniciar aprobación'
        END AS Estatus
		FROM dbo.MM_AceptacionPedido AP (NOLOCK)
		 JOIN dbo.MM_Pedido P (NOLOCK)
			ON AP.IdPedido  = P.IdPedido 
			AND ISNULL(AP.IdEstatusEliminado,0)<>1 --> CTE ACEPTACIÓN PEDIDO NO ESTE ELIMINADO
		 JOIN MM_Pedidos AS PG (NOLOCK)
             ON P.IdPedido = PG.IdIdentificador
             AND P.IdProveedorCompras = PG.IdProveedorCliente
			  AND PG.IdTipoPedido in (2,4,6) --> CTE PEDIDOS
		 JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
                ON PG.IdTipoPedido = TP.IdTipoPedido 
		 JOIN dbo.S_Proveedor PR  (NOLOCK)
				ON  P.IdProveedorCompras = PR.IdProveedor 
		 LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC  (NOLOCK)
			ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
		 LEFT JOIN dbo.FI_PedimentoComprobante PC  (NOLOCK)
			ON APC.IdPedimentoComprobante  = PC.IdPedimentoComprobante
			AND ISNULL(PC.IdEstatusEliminado,0)<>1 --> PEDIMENTO COMPROBANTE NO ESTE ELIMINADO
		 LEFT JOIN dbo.TA_Operacion O  (NOLOCK)
			ON PC.IdPedimentoComprobante  = O.IdDocumento
			AND O.IdTipoOperacion=16 -->CTE APROBACIÓN DE COMPROBANTE EXTRANJERO
		 LEFT JOIN dbo.TA_Estatus AS E (NOLOCK)
                ON O.IdEstatusOperacion = E.IdEstatus 	
		 LEFT JOIN #AceptacionesPedidoExtranjeros APE
				ON APE.EstatusAprobacion <> 'Aprobada'				
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA		
		 AND P.IdSubcontratista=@IdProveedor	
		 AND AP.IdAceptacionPedido  <> APE.IdAceptacionPedido
		 GROUP BY AP.IdAceptacionPedido,
                 AP.IdPedido,
                 AP.Creado,
                 AP.NombreUsuarioEntrega,
                 PR.RazonSocial,
                 PR.RegimenCapital,
                 PG.IdPedido,
                 TP.IdTipoPedido,
                 PC.IdPedimentoComprobante,
                 TP.TipoPedido,
				 O.IdEstatusOperacion,
				 E.Nombre,
				 PC.IdEstatusEliminado,
				 AP.IdEstatusEliminado
        ORDER BY AP.IdAceptacionPedido DESC;
			      
    END;

END;