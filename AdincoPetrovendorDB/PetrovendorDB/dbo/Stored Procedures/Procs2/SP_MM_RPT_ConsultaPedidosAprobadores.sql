-- =============================================
-- Author: DANIEL AC
-- Create date: 29-05-2018
-- Description:	Consultar Pedidos por proveedor y mostrar aprobadores estatus para reporte
-- =============================================
CREATE  PROCEDURE [dbo].[SP_MM_RPT_ConsultaPedidosAprobadores] 
	-- Add the parameters for the stored procedure here
	@IdProveedor int,		
    @IdContrato    INT = null,
    @IdUsuario     INT = null 
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--  PG.IdTipoPedido = 2 --> Pedido de Tipo Mercadeo

			 SELECT 			
			 PG.IdPedido,
			 P.IdSolicitudPedido,
			 P.CreadoEl AS CreadoEl, 						
			 ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,			 		 
			 E.Nombre,
			 P.Version,
			 TM.TipoMonedaCorto AS TipoMoneda,
			 PG.IdPedido AS IdPedidoGeneral,
			 TP.TipoPedido,					
			 O.IdOperacion,
			 Ta.IdTarea AS IdAprobador,
			 U.Nombre AS Aprobador,
			 ETA.Nombre AS EstatusAprobador,
			 TA.FechaCambioEstatus AS FechaCambioEstatusAprobador,
			 CASE
			    /*SI EXISTE UN REGISTRO DE ACEPTACIÓN DE PEDIDO YA DEBE ESTAR CONFIRMADO EL PEDIDO*/
				WHEN AP.IdAceptacionPedido IS NULL THEN 'No se ha realizado ninguna aceptación de servicio'
				ELSE CAST(AP.IdAceptacionPedido AS NVARCHAR(MAX))
			 END AS IdAceptacionPedido,
			 CASE
				WHEN EAF.IdEstatus IS NULL THEN 'No se ha realizado ninguna aprobación de factura'
				ELSE EAF.Nombre 
			 END AS EstatusFactura,	
			CASE
				WHEN  EAF.IdEstatus IS NULL AND TRANS.PDF IS NULL THEN 'No se ha realizado ningún pago'
				WHEN  EAF.IdEstatus IS NOT NULL AND TRANS.PDF IS NULL THEN 'Pendiente de pago'
				WHEN  EAF.IdEstatus IS NOT NULL AND TRANS.PDF IS NOT NULL THEN 'Pago realizado'
			ELSE 'No se ha realizado ningún pago' 
			END AS EstatusPago	,
			AFF.IdFactura,
			CASE 
				WHEN P.RecepcionServicio = 1 THEN 'Confirmación Aceptada' 
				WHEN P.RecepcionServicio  = 0 THEN 'Confirmación Rechazada' 
				WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN
						/*LA OPERACION TIENE QUE ESTAR APROBADA PARA PODER CONTAR EL TIEMPO DE CONFIRMACIÓN DE SERVICIO*/	
					 'Confirmación Vencida '  
				WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  <= 0 AND O.IdEstatusOperacion = 2 THEN							
					 'En Confirmación' 
				WHEN P.RecepcionServicio  IS NULL AND O.IdEstatusOperacion = 3 THEN	
					/*SI LA APROBACIÓN DE PEDIDO ES RECHAZADA(3) NUNCA SE ENVIA LA CONFIRMACIÓN AL PROVEEDOR*/	
					 'Aprobación de pedido rechazada, confirmación no enviada al proveedor'  
				ELSE 	  
					 'En espera de aprobación de pedido' 
			   END AS RecepcionServicio,
			   CASE
				WHEN AP.IdAceptacionPedido IS NULL THEN 'No se ha solicitado formato de carta de contenido nacional al proveedor'
				ELSE /*BUSCAR LA ULTIMA APROBACIÓN DE CARTA DE CONTENIDO NACIONAL YA QUE ESA ES LA QUE REALMENTE PROVOCA LA SOLICITUD DE APROBACIÓN DE FACTURA*/
				ISNULL((SELECT TOP 1 ECCN.Nombre 
			     FROM dbo.TA_Estatus ECCN
				 INNER JOIN dbo.MM_AceptacionCartaPCN CCN ON CCN.IdEstatus = ECCN.IdEstatus
				 WHERE CCN.IdAceptacionPedido=AP.IdAceptacionPedido ORDER BY CCN.CreadoEl DESC),'No se ha recibido solicitud de aprobación de Carta de Contenido Nacional por parte del proveedor')
			 END AS EstatusCN,
			TRFAC.CreadoEn	 AS FechaRegistroTranferencia				   
			FROM MM_Pedido AS P				
			LEFT  JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
			LEFT JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
			LEFT JOIN dbo.TA_Tarea AS TA ON TA.IdOperacion=O.IdOperacion
			LEFT JOIN dbo.S_Usuario AS U ON U.IdUsuario =TA.IdAprobador
			LEFT JOIN dbo.TA_Estatus ETA ON ETA.IdEstatus=TA.IdEstatus			
			LEFT JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
			LEFT JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion		
			LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda	
			LEFT JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido		
			LEFT JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
			LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido		
			LEFT JOIN dbo.MM_AceptacionPedido AS AP ON ap.IdPedido=P.IdPedido		
			LEFT JOIN dbo.MM_AceptacionFactura AS AFF ON AFF.IdAceptacionPedido=AP.IdAceptacionPedido		
			LEFT JOIN dbo.TA_Operacion APF ON APF.IdDocumento = AFF.IdAceptacionFactura AND APF.IdTipoOperacion=10 -->Aprobación Factura 
			LEFT JOIN dbo.TA_Estatus EAF ON EAF.IdEstatus = APF.IdEstatusOperacion 
			LEFT JOIN dbo.FI_Factura AS FP ON FP.IdFactura = AFF.IdFactura AND FP.Activa = 1	
			LEFT JOIN Adinco.dbo.FI_Factura AS FA ON FA.UUID=FP.UUID  COLLATE SQL_Latin1_General_CP1_CI_AS 
			LEFT JOIN Adinco.dbo.FI_TransferFactura TRFAC  ON TRFAC.IdFactura = FA.IdFactura
			LEFT JOIN Adinco.dbo.FI_Transfer TRANS ON TRANS.IdTransferencia = TRFAC.IdTransfer
			WHERE O.IdTipoOperacion = 9 
			AND O.IdProveedor = @IdProveedor						 
			AND P.Version=O.NoVersion
			AND P.IdSubcontratista IS NOT NULL 
			AND PV.IdProveedor IS NOT NULL
			AND O.IdDocumento IS NOT NULL
			AND TA.IdOperacion IS NOT NULL 
			AND TTO.IdTipoOperacion IS NOT NULL
			AND  P.IdPedido IS NOT NULL
			AND  P.IdMoneda IS NOT NULL
			GROUP BY 				
				P.IdPedido, 
				P.IdSolicitudPedido, 				
				RazonSocial,
				RegimenCapital, 
				P.RecepcionServicio,  
				E.Nombre,
				P.Version,
				TM.TipoMonedaCorto,				
				O.IdEstatusOperacion,
				P.CreadoEl,
				PG.IdPedido,
				TP.TipoPedido,						
				P.IdPedido,
				O.IdOperacion,
				ETA.Nombre,
				U.Nombre,
				TA.FechaCambioEstatus,
				AP.IdAceptacionPedido,
				EAF.Nombre,
				TRANS.PDF ,
				AFF.IdFactura,
				Ta.IdTarea,
				HV.FechaVigencia,
				EAF.IdEstatus,
				TRFAC.CreadoEn
			ORDER BY PG.IdPedido DESC		
						

		/*PUEDE HABER MUCHAS APROBACIONES DE CARTA DE CONTENIDO NACIONAL PERO SIEMPRE UNA ES LA QUE DEBE ESTAR APROBADA QUE ES LA ULTIMA EN CREARSE*/

END


