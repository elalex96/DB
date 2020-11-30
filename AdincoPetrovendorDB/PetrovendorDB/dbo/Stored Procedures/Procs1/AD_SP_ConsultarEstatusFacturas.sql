-- =============================================
-- Author: DANIEL
-- Create date: 02/12/2019
-- Description:	Consultar estatus de factura --revisión de consulta 
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ConsultarEstatusFacturas]
    -- Add the parameters for the stored procedure here
    @IdUsuario INT,
    @FechaRegistro DATETIME,
    @IdProveedor INT,
    @IdContrato INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    SELECT * FROM (
		 SELECT 
		   F.IdFactura AS FacturaPetrovendor,
		   FA.IdFactura AS IdFacturaAdinco,
           F.UUID,
           F.CreadoPor,
           u.Nombre AS Usuario,
           F.IdSubcontratista,           
           TP.TipoPedido,
           F.ResponseAdinco,
           F.FechaEnvio,         
           E.Nombre AS Estatus,
		   PDS.IdPedido,
		   PDS.IdProveedorCliente,
		   EO.Nombre AS EstatusFlujo,
		   O.FechaModificacion FinalizacionFlujo,
		   0 AS IdAceptacionFactura,
		   0 AS BitCartaCN,
		   F.IdLectorXMLSAT,
		   F.ErroSAT,
		   FA.Activa AS ActivoAdinco,
		   0 AS IdSolicitudPedido,
		   0 AS IdPedidoInterno,
		   P.RazonSocial,
		   F.Emisor,
		   F.Receptor
    FROM dbo.FI_Factura F       	
		INNER JOIN dbo.TA_Operacion O ON o.IdDocumento=F.IdFactura
		INNER JOIN dbo.TA_Estatus EO ON EO.IdEstatus=O.IdEstatusOperacion
		INNER JOIN dbo.MM_TipoPedido TP
            ON TP.IdTipoPedido = F.IdTipoPedido
	    INNER JOIN dbo.MM_Pedidos  PDS ON PDS.IdTipoPedido = TP.IdTipoPedido---COMPRA DIRECTA
		AND PDS.IdIdentificador=F.IdFactura AND PDS.IdProveedorCliente=O.IdProveedor  
		--LEFT JOIN Adinco.dbo.FI_FacturaAdincoPetrovendor AS FI_AP
  --          ON FI_AP.IdFacturaPetrovendor = F.IdFactura
        LEFT JOIN Adinco.dbo.FI_Factura AS FA
            ON FA.UUID COLLATE DATABASE_DEFAULT= F.UUID		
        LEFT JOIN dbo.TA_Estatus E
            ON E.IdEstatus = F.IdEstatusEnviado      
        LEFT JOIN dbo.S_Usuario AS u
            ON u.IdUsuario = F.CreadoPor	
		LEFT JOIN dbo.S_Proveedor P ON PDS.IdProveedorCliente=P.IdProveedor
	WHERE o.IdTipoOperacion=14 ---> COMPRAS DIRECTAS 
  
	UNION ALL 

	SELECT 
		   F.IdFactura AS FacturaPetrovendor,
		   FA.IdFactura AS IdFacturaAdinco,
           F.UUID,
           F.CreadoPor,
           u.Nombre AS Usuario,
           F.IdSubcontratista,           
           TP.TipoPedido,
           F.ResponseAdinco,
           F.FechaEnvio,         
           E.Nombre AS Estatus,
		   PDS.IdPedido,
		   PDS.IdProveedorCliente,
		   EO.Nombre AS EstatusFlujo,
		   O.FechaModificacion FinalizacionFlujo,
		   AF.IdAceptacionFactura AS  IdAceptacionFactura,
		   ISNULL(RCN.PedirCarta,0) AS BitCartaCN,
		   F.IdLectorXMLSAT,
		   F.ErroSAT,
		   FA.Activa AS ActivoAdinco,
		   POC.IdSolicitudPedido,
		   POC.IdPedido AS IdPedidoInterno,
		   P.RazonSocial,
		   F.Emisor,
		   F.Receptor
    FROM dbo.FI_Factura F       
		INNER JOIN dbo.MM_AceptacionFactura AF ON AF.IdFactura = F.IdFactura 	
		INNER   JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido= AF.IdAceptacionPedido	
		LEFT JOIN dbo.RelacionCartaCNPedido RCN ON RCN.IdAceptacionPedido = AP.IdAceptacionPedido		
		INNER JOIN dbo.TA_Operacion O ON O.IdDocumento=AF.IdAceptacionFactura 
		INNER JOIN dbo.TA_Estatus EO ON EO.IdEstatus=O.IdEstatusOperacion
		--LEFT JOIN Adinco.dbo.FI_FacturaAdincoPetrovendor AS FI_AP
  --          ON FI_AP.IdFacturaPetrovendor = F.IdFactura
        LEFT JOIN Adinco.dbo.FI_Factura AS FA
            ON FA.UUID COLLATE DATABASE_DEFAULT = F.UUID
		 LEFT JOIN dbo.MM_TipoPedido TP
            ON TP.IdTipoPedido = F.IdTipoPedido 
        LEFT JOIN dbo.TA_Estatus E
            ON E.IdEstatus = F.IdEstatusEnviado      
        LEFT JOIN dbo.S_Usuario AS u
            ON u.IdUsuario = F.CreadoPor
		LEFT JOIN dbo.MM_Pedido POC ON POC.IdPedido=AP.IdPedido
		INNER JOIN dbo.MM_Pedidos  PDS ON PDS.IdIdentificador = POC.IdPedido AND PDS.IdProveedorCliente=POC.IdProveedorCompras
		LEFT JOIN dbo.S_Proveedor P ON POC.IdProveedorCompras=P.IdProveedor
		WHERE O.IdTipoOperacion=10 ---> MERCADEO ETC  		
	) PedidoFacturas
	ORDER BY PedidoFacturas.IdPedido DESC

END;


