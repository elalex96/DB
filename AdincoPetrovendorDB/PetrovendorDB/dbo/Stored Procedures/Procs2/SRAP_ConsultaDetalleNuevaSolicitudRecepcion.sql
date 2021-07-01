CREUSE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SRAP_ConsultaDetalleNuevaSolicitudRecepcion'
)
    DROP PROCEDURE SRAP_ConsultaDetalleNuevaSolicitudRecepcion;

/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaPedidoDetallesVenta]    Script Date: 11/06/2021 12:01:56 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 25-05-2021
-- Description:	Consultar detalle de solicitud de recepción de pedido
-- =============================================
CREATE PROCEDURE [dbo].[SRAP_ConsultaDetalleNuevaSolicitudRecepcion]  
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdPedido    INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')

    -- Insert statements for procedure here
	    DECLARE @tbPedidoDetalle AS TABLE 
		(Id INT IDENTITY(1,1) PRIMARY KEY,
		IdPedidoDetalle INT,
		CantidadRecepcionar float,
		CantidadPedido float,
		CantidadEnAprobacion float,
		CantidadAceptada float,
		CantidadProcesada float,
		CantidadRestante float,
		TodoProcesado bit)
	
	   DECLARE @tbPedidoDetalleEnAprobacion AS TABLE 
		(IdPedidoDetalle INT,	
		CantidadEnAprobacion float)

		DECLARE @tbPedidoDetalleAceptados AS TABLE 
		(IdPedidoDetalle INT,	
		CantidadAceptada float)


		/*1. OBTENER LAS REFERENCIAS DE LOS PRODUCTOS A ENTREGAR*/
		INSERT INTO @tbPedidoDetalle(IdPedidoDetalle,CantidadPedido,CantidadRecepcionar,CantidadAceptada,CantidadEnAprobacion,CantidadProcesada,CantidadRestante,TodoProcesado)
		SELECT 
		IdPedidoDetalle = PD.IdPedidoDetalle,		
		CantidadPedido= PD.Cantidad,
		CantidadRecepcionar= 0,
		CantidadAceptada= 0,
		CantidadEnAprobacion= 0,
		CantidadProcesada= 0,
		CantidadRestante =0,
		TodoProcesado = 0
		FROM MM_Pedido AS P
		JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido		
		WHERE 		
		P.IdPedido = @IdPedido
		AND P.IdSubcontratista = @IdProveedor 


		/*2.- OBTENER CANTIDADES EN APROBACION*/
	     INSERT INTO @tbPedidoDetalleEnAprobacion(IdPedidoDetalle,CantidadEnAprobacion)
		 SELECT 
		 PD.IdPedidoDetalle, 
		 CantidadEnAprobacion = SUM(SAPD.Cantidad)
		FROM @tbPedidoDetalle PD
		JOIN MM_SolicitudAceptacionPedidoDetalle SAPD
			ON PD.IdPedidoDetalle = SAPD.IdPedidoDetalle
		JOIN MM_SolicitudAceptacionPedido SAP
			ON SAPD.IdSolicitudAceptacionPedido = SAP.IdSolicitudAceptacionPedido
			AND SAP.Activo = 1
		JOIN TA_Operacion O 
			ON SAP.IdSolicitudAceptacionPedido = O.IdDocumento
			AND O.IdTipoOperacion = @TipoOperacionId --> Aprobación de solicitud de aceptación de pedido
			AND O.IdEstatusOperacion = 1 --> EN APROBACIÓN 
			AND ISNULL(O.IdEstatusEliminado,0)=0 
		 WHERE SAP.IdPedido = @IdPedido
		 GROUP BY PD.IdPedidoDetalle

		 /*ACTUALIZAR LAS CANTIDADES EN APROBACION*/
		 UPDATE PD
		 SET PD.CantidadEnAprobacion=PDEA.CantidadEnAprobacion
		 FROM @tbPedidoDetalle PD
		 JOIN @tbPedidoDetalleEnAprobacion PDEA
			ON PD.IdPedidoDetalle = PDEA.IdPedidoDetalle	

		 /*3.OBTENER LAS CANTIDADES QUE YA ESTAN EN UNA ACEPTACION DE PEDIDO
		 SI HUBO UNA APROBACION DE RECEPCION DE ACEPTACION DE PEDIDO Y AHORA ESTA APROBADO 
		 POR DEFAULT DEBE ESTAR COMO ACEPTACION DE PEDIDO
		 */
		 INSERT INTO @tbPedidoDetalleAceptados(IdPedidoDetalle, CantidadAceptada)
		 SELECT
		 PD.IdPedidoDetalle,
		 CantidadAceptada = SUM(APD.Cantidad)
		 FROM  @tbPedidoDetalle PD
		 JOIN MM_AceptacionPedidoDetalle APD
			ON PD.IdPedidoDetalle = APD.IdPedidoDetalle
		 JOIN MM_AceptacionPedido AP 
			ON APD.IdAceptacionPedido	= AP.IdAceptacionPedido
				AND AP.Activo= 1
				AND ISNULL(AP.IdEstatusEliminado,0) =0
		 WHERE AP.IdPedido=@IdPedido
		GROUP BY PD.IdPedidoDetalle

		UPDATE PD
		 SET PD.CantidadAceptada=APD.CantidadAceptada
		 FROM @tbPedidoDetalle PD
		 JOIN @tbPedidoDetalleAceptados APD
			ON PD.IdPedidoDetalle = APD.IdPedidoDetalle	

		/*ACTUALIZAR CANTIDADES*/
		UPDATE @tbPedidoDetalle
		SET CantidadProcesada = (CantidadAceptada + CantidadEnAprobacion),
		CantidadRestante = CASE WHEN  (CantidadPedido - (CantidadAceptada + CantidadEnAprobacion)) < 0 THEN 0 ELSE (CantidadPedido - (CantidadAceptada + CantidadEnAprobacion)) END 

		/*ACTUALIZAR LA VALIDACION EXITOSA*/
		UPDATE @tbPedidoDetalle
		SET TodoProcesado = (CASE WHEN CantidadRestante = 0  THEN 1 ELSE 0 END)
		
			
	   /*ENCABEZADO DEL PEDIDO*/	       
		 SELECT  
		 P.IdPedido,    
		 P.IdSolicitudPedido,    
		 SUM(PD.Subtotal) AS SubTotal,    
		 O.IdOperacion,     
		 O.Descripcion,     
		 ISNULL(PV.RazonSocial,'') AS Proveedor,    
		 format(ISNULL(P.FechaEnvioPedido, GETDATE()),'dd/MM/yyyy') AS FechaEnvioPedido,    
		 P.IdPeticionOferta,    
		 P.RecepcionServicio,    
		 format(ISNULL(P.FechaRecepcionServicio,GETDATE()),'dd/MM/yyyy') as FechaRecepcionServicio,    
		 format(ISNULL(H.FechaVigencia, GETDATE()),'dd/MM/yyyy') as FechaVigencia,    
		 PG.IdPedido AS PedidoGeneral,    
		 TP.TipoPedido,    
		 TP.IdTipoPedido,  
		 ISNULL(P.Cerrado, 0) AS Cerrado,
		 P.IdSubcontratista AS ProveedorVentaId		    
		 FROM MM_Pedido AS P    
		 INNER JOIN MM_Pedidos AS PG 
			ON P.IdPedido = PG.IdIdentificador 
			AND PG.IdProveedorCliente = P.IdProveedorCompras 
			AND PG.IdTipoPedido in (2,4,6)   
		 LEFT  JOIN dbo.MM_TipoPedido AS TP 
			ON TP.IdTipoPedido = PG.IdTipoPedido    
		 LEFT JOIN MM_SolicitudPedido AS SP 
			ON SP.IdSolicitudPedido = P.IdSolicitudPedido    
		 LEFT JOIN MM_PedidoDetalle AS PD 
			ON PD.IdPedido = P.IdPedido    
		 LEFT JOIN TA_Operacion AS O 
			ON O.IdDocumento = P.IdSolicitudPedido 
			AND P.Version = O.NoVersion    		 
		 LEFT JOIN TA_TipoOperacion AS TTO 
			ON TTO.IdTipoOperacion= O.IdTipoOperacion      
		 LEFT JOIN TA_Estatus AS E 
			ON E.IdEstatus = O.IdEstatusOperacion    
		 LEFT JOIN S_Usuario AS U  
			ON U.IdUsuario = O.IdAsignador    
		 LEFT JOIN S_Proveedor AS PV 
			ON PV.IdProveedor = P.IdProveedorCompras     
		 LEFT JOIN CC_CentroCosto AS CC 
			ON SP.IdCentroCosto = CC.IdCentrocosto     
		 LEFT JOIN dbo.MM_HorasVigenciaPedido AS H 
			ON H.IdPedido = P.IdPedido    
		 WHERE O.IdTipoOperacion = 9 
			AND P.IdSubcontratista = @IdProveedor 
			AND P.IdPedido = @IdPedido 
			AND O.IdEstatusOperacion=2    
		 GROUP BY     
		 P.IdPedido,     
		 P.IdSolicitudPedido,
		 O.IdOperacion,     
		 O.Descripcion,     
		 PV.RazonSocial,     
		 PV.RegimenCapital,
		 P.FechaEnvioPedido,    
		 P.IdPeticionOferta,    
		 P.RecepcionServicio,    
		 P.FechaRecepcionServicio,    
		 H.FechaVigencia,    
		 PG.IdPedido,    
		 TP.TipoPedido,    
		 TP.IdTipoPedido,    
		 P.DiasCredito,    
		 P.Cerrado,  
		 P.IdSubcontratista


	    /*PRODUCTOS A ENTREGAR*/
		SELECT 
		PD.IdPedidoDetalle,
		PD.IdMaterialVendedor,
		M.Descripcioncorta as Descripcioncorta,
		M.DescripcionLarga,
		tmPD.CantidadPedido AS CantidadPedido,
		PD.PrecioUnitario,
		PD.Subtotal, 
		tmPD.CantidadRestante AS CantidadRestante, 
		tmPD.CantidadRecepcionar AS CantidadRecepcionar, 
		tmPD.CantidadEnAprobacion AS CantidadEnAprobacion,
		tmPD.CantidadProcesada AS CantidadProcesada,
		tmPD.TodoProcesado AS TodoProcesado,
		TM.TipoMonedaCorto,		
		ISNULL(PD.RecepcionPedido,'false')  AS Recepcionservicio,		
		PD.RecepcionPedido,
		POD.UnidadProveedor AS Unidad	
		FROM @tbPedidoDetalle tmPD		
		JOIN MM_PedidoDetalle AS PD 
			ON tmPD.IdPedidoDetalle		= PD.IdPedidoDetalle
		JOIN MM_Pedido	P
			ON PD.IdPedido	= P.IdPedido
		JOIN MM_Material AS M 
			ON PD.IdMaterialVendedor	=	M.IdMaterial 
		JOIN MM_PeticionOferta AS PO 
			ON PO.IdPeticionOFerta = P.IdPeticionOferta		
		JOIN MM_PeticionOfertaDetalle AS POD 
			ON PO.IdPeticionOferta = POD.IdPeticionOferta 
			AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
		JOIN MM_SolicitudPedidoDetalle AS SPD 
			ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle		
		LEFT JOIN PV_TipoMoneda AS TM 
			ON TM.IdMoneda = PD.IdMoneda 		
		WHERE P.IdSubcontratista = @IdProveedor 		
		AND P.IdPedido = @IdPedido
		ORDER BY M.Descripcioncorta ASC
		 
 
END;

