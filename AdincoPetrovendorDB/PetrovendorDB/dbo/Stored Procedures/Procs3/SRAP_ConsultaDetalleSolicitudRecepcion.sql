-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Consultar detalle de solicitud de recepción de pedido
-- =============================================
-- Author:		Luis David
-- Create date: 20/07/2022
-- Description:	Se agrega el comentario de aprobación y rechazo para issue #1933(Petrovendor)
-- =============================================
-- Author:		Luis David
-- Create date: 15/12/2022
-- Description:	Se cambia el numero de cotizacion por No. Aceptación #2161(Petrovendor)
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_ConsultaDetalleSolicitudRecepcion]  
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdPedido    INT,
@IdSolicitudAceptacionPedido INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido'),
		@IdDocumentoFieldTicket INT = (SELECT IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = 'FIELD TICKET'),
		@IdDocumentoProforma INT = (SELECT IdTipoDocumento FROM S_TipoDocumento WHERE NombreTipoDocumento = 'PROFORMA'),
		@ComentariosRechazo VARCHAR(8000);
		SELECT 
		 @ComentariosRechazo = COALESCE(@ComentariosRechazo + ', ', '') + T.Comentario
		 FROM TA_Operacion O
		 JOIN TA_Tarea T 
			ON O.IdOperacion = T.IdOperacion
		 JOIN TA_Estatus E
			ON T.IdEstatus = E.IdEstatus
		WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
		AND O.IdTipoOperacion=@TipoOperacionId
		AND T.IdEstatus IN (3) --> RECHAZADO
		AND T.Activo=1

    -- Insert statements for procedure here
	    	
						
	   /*ENCABEZADO DEL PEDIDO*/	       
		 SELECT     
		 SAP.IdSolicitudAceptacionPedido,
		 SAP.Comentario,
		 P.IdPedido,    
		 P.IdSolicitudPedido,    		 
		 ISNULL(PV.RazonSocial,'') +' ' + ISNULL(PV.RegimenCapital,'') AS Proveedor,    
		 FORMAT(ISNULL(P.FechaEnvioPedido, GETDATE()),'dd/MM/yyyy') AS FechaEnvioPedido,    
		 isnull(CAST(SAP.IdAceptacionPedido AS varchar(300)),'NA') AS IdAceptacion,    
		 P.RecepcionServicio,    
		 FORMAT(ISNULL(P.FechaRecepcionServicio,GETDATE()),'dd/MM/yyyy') as FechaRecepcionServicio,  
		 PG.IdPedido AS PedidoGeneral,
		 ISNULL(P.Cerrado, 0) AS Cerrado,
		 P.IdSubcontratista AS ProveedorVentaId,
		 E.Nombre AS EstatusAprobacion,
		 O.IdEstatusOperacion AS IdEstatus,
		 FORMAT(ISNULL(SAP.CreadoEl, GETDATE()),'dd/MM/yyyy') AS SolitudCreadaEl  ,
		 UE.Nombre AS CreadoPor,
		 P.IdSubcontratista	    ,
		 ISNULL(ISNULL(WPI.PURCHASING_DOCUMENT,POW.PO),'SIN PO RELACIONADO') AS NoPO,
		 ISNULL(@ComentariosRechazo, '') AS ComentariosRechazo
		 FROM MM_SolicitudAceptacionPedido SAP
		 JOIN TA_Operacion O 
			ON SAP.IdSolicitudAceptacionPedido = O.IdDocumento
			AND O.IdTipoOperacion = @TipoOperacionId -->CTE 20
		JOIN TA_Estatus E
			ON O.IdEstatusOperacion = E.IdEstatus
		 JOIN MM_Pedido AS P    
			ON SAP.IdPedido = P.IdPedido
		 INNER JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = P.IdProveedorCompras 
			AND PG.IdTipoPedido in (2,4,6) 
		 LEFT JOIN S_Proveedor AS PV 
			ON P.IdProveedorCompras = PV.IdProveedor
		 LEFT JOIN S_Usuario UE
			ON SAP.CreadorPor = UE.IdUsuario
		LEFT JOIN WDEA_PurchasingDocumentsImportados AS WPI
			ON P.IdPedido = WPI.IdPedidoADINCO
		LEFT JOIN DEA_Relacion_PR_PO AS POW
			ON P.IdPedido = POW.IdPedido
		 WHERE 
			P.IdSubcontratista = @IdProveedor 
			AND SAP.IdPedido = @IdPedido 
			AND SAP.IdSolicitudAceptacionPedido =@IdSolicitudAceptacionPedido
		 GROUP BY     
		 P.IdPedido,     
		 P.IdSolicitudPedido,		  
		 PV.RazonSocial,     
		 PV.RegimenCapital,
		 P.FechaEnvioPedido,    
		 SAP.IdAceptacionPedido,
		 P.RecepcionServicio,    
		 P.FechaRecepcionServicio,
		 PG.IdPedido,
		 P.DiasCredito,    
		 P.Cerrado,  
		 P.IdSubcontratista,
		 E.Nombre,
		 SAP.IdSolicitudAceptacionPedido,
		 SAP.Comentario,
		 O.IdEstatusOperacion,
		 SAP.CreadoEl,
		 UE.Nombre,
		 P.IdSubcontratista	,
		 WPI.PURCHASING_DOCUMENT,
		 POW.PO  

	    /*PRODUCTOS A ENTREGAR*/
		SELECT 
		PD.IdPedidoDetalle,
		PD.IdMaterialVendedor,
		M.Descripcioncorta as Descripcioncorta,
		M.DescripcionLarga,
		PD.Cantidad AS CantidadPedido,
		PD.PrecioUnitario,
		PD.Subtotal, 
		SAPD.Cantidad AS CantidadProcesada, 		
		TM.TipoMonedaCorto,		
		ISNULL(PD.RecepcionPedido,'false')  AS Recepcionservicio,		
		PD.RecepcionPedido,
		POD.UnidadProveedor AS Unidad,
		ISNULL(ISNULL(WPI.PURCHASING_DOCUMENT,POW.PO),'SIN PO RELACIONADO') AS NoPO
		FROM MM_SolicitudAceptacionPedidoDetalle SAPD 		
		JOIN MM_PedidoDetalle AS PD 
			ON SAPD.IdPedidoDetalle		= PD.IdPedidoDetalle
		JOIN MM_Pedido	P
			ON PD.IdPedido	= P.IdPedido
		JOIN MM_Material AS M 
			ON PD.IdMaterialVendedor	=	M.IdMaterial 
		JOIN MM_PeticionOferta AS PO 
			ON P.IdPeticionOferta = PO.IdPeticionOFerta 
		JOIN MM_PeticionOfertaDetalle AS POD 
			ON PO.IdPeticionOferta = POD.IdPeticionOferta 
			AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
		JOIN MM_SolicitudPedidoDetalle AS SPD 
			ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
			JOIN PV_TipoMoneda AS TM 
			ON PD.IdMoneda = TM.IdMoneda
		LEFT JOIN WDEA_PurchasingDocumentsImportados AS WPI
			ON P.IdPedido = WPI.IdPedidoADINCO
		LEFT JOIN DEA_Relacion_PR_PO AS POW
			ON P.IdPedido = POW.IdPedido  		
		WHERE P.IdSubcontratista = @IdProveedor 		
		AND P.IdPedido = @IdPedido
		AND SAPD.IdSolicitudAceptacionPedido= @IdSolicitudAceptacionPedido
		GROUP BY PD.IdPedidoDetalle,
		PD.IdMaterialVendedor,
		M.Descripcioncorta,
		M.DescripcionLarga,
		PD.Cantidad,
		PD.PrecioUnitario,
		PD.Subtotal, 
		SAPD.Cantidad, 		
		TM.TipoMonedaCorto,		
		ISNULL(PD.RecepcionPedido,'false'),		
		PD.RecepcionPedido,
		POD.UnidadProveedor,
		ISNULL(ISNULL(WPI.PURCHASING_DOCUMENT,POW.PO),'SIN PO RELACIONADO')
		ORDER BY M.Descripcioncorta ASC

		 /*TABLA DE DOCUMENTOS*/
		 SELECT  D.IdDocumento, D.NombreDocumento, D.IdDocumentoTabla 
         FROM  S_Documento_S3 D  
         WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
		 AND D.Activo=1 
		 AND D.IdTipoDocumento = 12 --> CTE ACEPTACION DE PEDIDO --> SELECT * FROM S_TipoDocumento WHERE IdTipoDocumento=12  
 

         /*TABLA CON INFORMACIÓN DE APROBACIÓN*/
		 SELECT 
		 U.Nombre AS Usuario,
		 T.Comentario,
		 T.FechaCambioEstatus,
		 E.Nombre AS Estatus 
		 FROM TA_Operacion O
		 JOIN TA_Tarea T 
			ON O.IdOperacion = T.IdOperacion
		 JOIN S_Usuario U
			ON T.IdAprobador = U.IdUsuario
		 JOIN TA_Estatus E
			ON T.IdEstatus = E.IdEstatus
		WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
		AND O.IdTipoOperacion=@TipoOperacionId
		AND T.IdEstatus IN (2,3) --> RECHAZADO
		AND T.Activo=1

		/*TABLA DE DOCUMENTO FIELD TICKET*/
		SELECT  D.IdDocumento, D.NombreDocumento, D.IdDocumentoTabla 
        FROM  S_Documento_S3 D  
        WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
		AND D.Activo=1 
		AND D.IdTipoDocumento = @IdDocumentoFieldTicket
		/*TABLA DE DOCUMENTO PROFORMA*/
		SELECT  D.IdDocumento, D.NombreDocumento, D.IdDocumentoTabla 
        FROM  S_Documento_S3 D  
        WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
		AND D.Activo=1 
		AND D.IdTipoDocumento = @IdDocumentoProforma
END;