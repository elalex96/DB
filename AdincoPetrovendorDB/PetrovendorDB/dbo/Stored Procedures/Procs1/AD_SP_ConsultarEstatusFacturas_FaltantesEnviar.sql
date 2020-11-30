-- =============================================
-- Author: DANIEL
-- Create date: 18/01/2018
-- Description:	Consultar facturas aprobadas de petrovendor, que aun no tiene un IdAdinco y un Enviado en FI_Factura 
-- =============================================
CREATE PROCEDURE [dbo].[AD_SP_ConsultarEstatusFacturas_FaltantesEnviar] ----NULL,NULL,NULL,NULL
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
		   ISNULL(PDS.IdTipoPedido,0) AS IdTipoPedido,
		   0 AS IdAceptacionFactura,
		   O.IdAsignador AS IdAsignadorPetrovendor,
		   0 AS IdAprobadorAdinco,
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
		   O.IdOperacion	
    FROM dbo.FI_Factura F       	
		INNER JOIN dbo.TA_Operacion O ON o.IdDocumento=F.IdFactura
		LEFT JOIN dbo.TA_Estatus EO ON EO.IdEstatus=O.IdEstatusOperacion
		LEFT JOIN Adinco.dbo.FI_FacturaAdincoPetrovendor AS FI_AP
            ON FI_AP.IdFacturaPetrovendor = F.IdFactura
        LEFT JOIN Adinco.dbo.FI_Factura AS FA
            ON FA.IdFactura = FI_AP.IdFacturaAdinco
		LEFT JOIN dbo.MM_TipoPedido TP
            ON TP.IdTipoPedido = F.IdTipoPedido
	    LEFT JOIN dbo.MM_Pedidos  PDS ON PDS.IdTipoPedido = TP.IdTipoPedido  
		AND pds.IdIdentificador=O.IdDocumento AND PDS.IdProveedorCliente=O.IdProveedor  
        LEFT JOIN dbo.TA_Estatus E
            ON E.IdEstatus = F.IdEstatusEnviado      
        LEFT JOIN dbo.S_Usuario AS u
            ON u.IdUsuarioADINCO = F.CreadoPor	
	WHERE o.IdTipoOperacion=14 AND O.IdEstatusOperacion=2 AND F.IdEstatusEnviado IS NULL
  
	UNION ALL 

		  SELECT 
		   F.IdFactura AS FacturaPetrovendor,
		   ISNULL(PDS.IdTipoPedido,0) AS IdTipoPedido,
		   AF.IdAceptacionFactura AS  IdAceptacionFactura,
		   O.IdAsignador AS IdAsignadorPetrovendor,
		   (SELECT TOP 1 S.IdUsuarioADINCO 
		   FROM TA_Operacion OI
		   INNER JOIN Ta_Tarea TA ON OI.IdOperacion = TA.IdOperacion 
		   INNER JOIN S_Usuario S ON S.IdUsuario =TA.IdAprobador
		   WHERE OI.IdOperacion= O.IdOperacion ORDER BY TA.FechaCambioEstatus DESC) AS IdAprobadorAdinco, -- Ultimo usuario de procura que aproba la factura mercadeo
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
		   O.IdOperacion		   
    FROM dbo.FI_Factura F       
		INNER JOIN dbo.MM_AceptacionFactura AF ON AF.IdFactura = F.IdFactura 	
		INNER JOIN dbo.MM_AceptacionPedido AP ON AP.IdAceptacionPedido= AF.IdAceptacionPedido	
		INNER JOIN dbo.MM_Pedidos  PDS ON PDS.IdIdentificador = AP.IdPedido 
		INNER JOIN dbo.TA_Operacion O ON O.IdDocumento=AF.IdAceptacionFactura 
		INNER JOIN dbo.TA_Estatus EO ON EO.IdEstatus=O.IdEstatusOperacion		
		LEFT JOIN Adinco.dbo.FI_FacturaAdincoPetrovendor AS FI_AP
            ON FI_AP.IdFacturaPetrovendor = F.IdFactura
        LEFT JOIN Adinco.dbo.FI_Factura AS FA
            ON FA.IdFactura = FI_AP.IdFacturaAdinco
		 LEFT JOIN dbo.MM_TipoPedido TP
            ON TP.IdTipoPedido = F.IdTipoPedido 
        LEFT JOIN dbo.TA_Estatus E
            ON E.IdEstatus = F.IdEstatusEnviado      
        LEFT JOIN dbo.S_Usuario AS u
            ON u.IdUsuarioADINCO = F.CreadoPor
		WHERE O.IdTipoOperacion=10 AND O.IdEstatusOperacion=2 AND F.IdEstatusEnviado IS NULL
	) PedidoFacturas
	ORDER BY PedidoFacturas.IdPedido DESC

	

END;

