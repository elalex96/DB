-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Consultar solicitudes de recepción por pedido 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 19/04/2022
-- Description:	Se agrega a la consulta el dato del No.PO
-- =============================================
-- Author:		Luis David
-- Create date: 15/12/2022
-- Description:	Se cambia el numero de cotizacion por No. Aceptación #2161(Petrovendor)
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_ConsultarSolicitudesAceptacionPedidoPorPedido]  
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario   INT,
@IdPedido    INT 
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')

    -- Insert statements for procedure here
	    	
						
	   /*ENCABEZADO DEL PEDIDO*/	       
		 SELECT     
		 SAP.IdSolicitudAceptacionPedido,
		 SAP.Comentario,
		 P.IdPedido,    
		 P.IdSolicitudPedido,    		 
		 ISNULL(PV.RazonSocial,'') AS Proveedor,    
		 FORMAT(ISNULL(P.FechaEnvioPedido, GETDATE()),'dd/MM/yyyy') AS FechaEnvioPedido,    
		 P.IdPeticionOferta,    
		 P.RecepcionServicio,    
		 FORMAT(ISNULL(P.FechaRecepcionServicio,GETDATE()),'dd/MM/yyyy') as FechaRecepcionServicio,  
		 PG.IdPedido AS IdPedidoGeneral,
		 ISNULL(P.Cerrado, 0) AS Cerrado,
		 P.IdSubcontratista AS ProveedorVentaId,
		 E.Nombre AS EstatusAprobacion,
		 O.IdEstatusOperacion AS IdEstatus,
		 FORMAT(ISNULL(SAP.CreadoEl, GETDATE()),'dd/MM/yyyy') AS SolitudCreadaEl,
		 UE.Nombre AS CreadoPor,
		 C.NumeroContrato AS Contrato,
		 US.Nombre AS SolitanteRequisicion,
		 P.IdPeticionOferta AS IdPeticionOferta,
		 ISNULL(ISNULL(WPI.PURCHASING_DOCUMENT,POW.PO),'N/A') AS NoPO,
		 isnull(CAST(SAP.IdAceptacionPedido AS varchar(300)),'NA') AS IdAceptacion
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
			ON P.IdProveedorCompras =PV.IdProveedor
		 LEFT JOIN S_Usuario UE
			ON SAP.CreadorPor = UE.IdUsuario
		 LEFT JOIN Adinco..CO_Contrato C
			ON P.IdContrato = C.IdContrato
		 LEFT JOIN Adinco..CO_AreaContractual AC
			ON C.IdAreaContractual	= AC.IdAreaContractual
	     LEFT JOIN MM_SolicitudPedido SP
			ON P.IdSolicitudPedido = SP.IdSolicitudPedido
		 LEFT JOIN S_Usuario US
			ON SP.Solicitante = US.IdUsuario
		LEFT JOIN WDEA_PurchasingDocumentsImportados AS WPI
			ON P.IdPedido = WPI.IdPedidoADINCO
		LEFT JOIN DEA_Relacion_PR_PO AS POW
			ON P.IdPedido = POW.IdPedido
		 WHERE 
			P.IdSubcontratista = @IdProveedor 
			AND P.IdPedido   = @IdPedido
		 GROUP BY     
		 P.IdPedido,     
		 P.IdSolicitudPedido,		  
		 PV.RazonSocial,     
		 PV.RegimenCapital,
		 P.FechaEnvioPedido,    
		 P.IdPeticionOferta,    
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
		 C.NumeroContrato,
		 US.Nombre,
		 P.IdPeticionOferta,
		 WPI.PURCHASING_DOCUMENT,
		 POW.PO,
		 SAP.IdAceptacionPedido;

END;