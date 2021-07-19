USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SRAP_ConsultarSolicitudesAceptacionPedido'
)
    DROP PROCEDURE SRAP_ConsultarSolicitudesAceptacionPedido;
/****** Object:  StoredProcedure [dbo].[SRAP_ConsultarSolicitudesAceptacionPedido]    Script Date: 18/07/2021 11:32:37 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Consultar solicitudes de recepción de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_ConsultarSolicitudesAceptacionPedido]  
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario   INT,
@Filtro		 VARCHAR(200)
AS
 BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')

    -- Insert statements for procedure here
	    						
	    IF @Filtro ='TODAS'
		BEGIN 
		 
		 SELECT     
		 SAP.IdSolicitudAceptacionPedido,
		 SAP.Comentario,
		 P.IdPedido,    
		 P.IdSolicitudPedido,    		 
		 CONCAT(ISNULL(PC.RazonSocial,''),ISNULL(' '+PC.RegimenCapital,'')) AS Proveedor,    
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
		 SAP.IdAceptacionPedido   
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
		 LEFT JOIN S_Proveedor AS PC 
			ON P.IdSubcontratista =PC.IdProveedor
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
		 WHERE 
			P.IdProveedorCompras = @IdProveedor 
		 GROUP BY     
		 P.IdPedido,     
		 P.IdSolicitudPedido,		  
		 PC.RazonSocial,     
		 PC.RegimenCapital,
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
		 SAP.IdAceptacionPedido 
		 ORDER BY SAP.IdSolicitudAceptacionPedido DESC	    	    
		 END 

		IF @Filtro ='EN-APROBACION'
	 BEGIN 

		 SELECT     
		 SAP.IdSolicitudAceptacionPedido,
		 SAP.Comentario,
		 P.IdPedido,    
		 P.IdSolicitudPedido,    		 
		 CONCAT(ISNULL(PC.RazonSocial,''),ISNULL(' '+PC.RegimenCapital,'')) AS Proveedor,    
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
		 SAP.IdAceptacionPedido   
		 FROM MM_SolicitudAceptacionPedido SAP
		 JOIN TA_Operacion O 
			ON SAP.IdSolicitudAceptacionPedido = O.IdDocumento
			AND O.IdTipoOperacion = @TipoOperacionId -->CTE 20
			AND O.IdEstatusOperacion= 1 --> EN APROBACION CTE TA_Estatus
		JOIN TA_Estatus E
			ON O.IdEstatusOperacion = E.IdEstatus
		 JOIN MM_Pedido AS P    
			ON SAP.IdPedido = P.IdPedido
		 INNER JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = P.IdProveedorCompras 
			AND PG.IdTipoPedido in (2,4,6) 
		 LEFT JOIN S_Proveedor AS PC 
			ON P.IdSubcontratista =PC.IdProveedor
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
		 WHERE 
			P.IdProveedorCompras = @IdProveedor 			
		 GROUP BY     
		 P.IdPedido,     
		 P.IdSolicitudPedido,		  
		 PC.RazonSocial,     
		 PC.RegimenCapital,
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
		 SAP.IdAceptacionPedido    
		 ORDER BY SAP.IdSolicitudAceptacionPedido DESC	    
		 END 
END 



