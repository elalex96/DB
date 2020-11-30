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
		FROM
		 dbo.MM_AceptacionPedido AP 
		 INNER JOIN dbo.MM_Pedido P 
			ON P.IdPedido = AP.IdPedido
		 INNER JOIN MM_Pedidos AS PG
             ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = P.IdProveedorCompras
		 INNER JOIN dbo.MM_TipoPedido AS TP
                ON TP.IdTipoPedido = PG.IdTipoPedido
		 INNER JOIN dbo.S_Proveedor PR 
				ON PR.IdProveedor= P.IdProveedorCompras 
		 LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
		 LEFT JOIN dbo.FI_PedimentoComprobante PC 
			ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
		 LEFT JOIN dbo.TA_Operacion O ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 		 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA		
		 AND P.IdSubcontratista=@IdProveedor
		 AND O.IdOperacion IS NULL
		 AND ISNULL(AP.IdEstatusEliminado,0)<>1 --> NO MOSTRAR SOLICITUD DE COMPROBANTES CON ESTATUS ELIMINADO
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
		FROM
		 dbo.MM_AceptacionPedido AP 
		 INNER JOIN dbo.MM_Pedido P 
			ON P.IdPedido = AP.IdPedido
		 INNER JOIN MM_Pedidos AS PG
             ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = P.IdProveedorCompras
		 INNER JOIN dbo.MM_TipoPedido AS TP
                ON TP.IdTipoPedido = PG.IdTipoPedido
		 INNER JOIN dbo.S_Proveedor PR 
				ON PR.IdProveedor= P.IdProveedorCompras 
		 LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
		 LEFT JOIN dbo.FI_PedimentoComprobante PC 
			ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
		 LEFT JOIN dbo.TA_Operacion O ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 		 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA		
		 AND P.IdSubcontratista=@IdProveedor
		 AND O.IdOperacion IS NOT NULL
		 AND O.IdEstatusOperacion=@Estatus
		 AND ISNULL(PC.IdEstatusEliminado,0)<>1  --> NO MOSTRAR COMPROBANTES CON ESTATUS ELIMINADO
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
		FROM
		 dbo.MM_AceptacionPedido AP 
		 INNER JOIN dbo.MM_Pedido P 
			ON P.IdPedido = AP.IdPedido AND ISNULL(AP.IdEstatusEliminado,0)<>1 --> ACEPTACIÓN PEDIDO NO ESTE ELIMINADO
		 INNER JOIN MM_Pedidos AS PG
             ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = P.IdProveedorCompras
		 INNER JOIN dbo.MM_TipoPedido AS TP
                ON TP.IdTipoPedido = PG.IdTipoPedido
		 INNER JOIN dbo.S_Proveedor PR 
				ON PR.IdProveedor= P.IdProveedorCompras 
		 LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
		 LEFT JOIN dbo.FI_PedimentoComprobante PC 
			ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante AND ISNULL(PC.IdEstatusEliminado,0)<>1 --> PEDIMENTO COMPROBANTE NO ESTE ELIMINADO
		 LEFT JOIN dbo.TA_Operacion O 
			ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		 LEFT JOIN dbo.TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion		 		 
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA		
		 AND P.IdSubcontratista=@IdProveedor		 		 
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


