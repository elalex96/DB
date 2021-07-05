USE [Petrovendor]
GO

IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SRAP_ConsultaDetalleAprobacionSolicitudRecepcion'
)
    DROP PROCEDURE SRAP_ConsultaDetalleAprobacionSolicitudRecepcion;

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
CREATE PROCEDURE [dbo].[SRAP_ConsultaDetalleAprobacionSolicitudRecepcion]  
	-- Add the parameters for the stored procedure here
@IdProveedor INT,
@IdUsuario INT,
@IdPedido    INT,
@IdSolicitudAceptacionPedido INT 

AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
		DECLARE @TipoOperacionId INT = (SELECT IdTipoOperacion FROM TA_TipoOperacion WHERE NombreOperacion='Aprobación de solicitud de aceptación de pedido')
		DECLARE @NoSecuenciaUsuarioActual INT 
		DECLARE @IdEstatusUsuarioAnteriorSecuencia INT
		DECLARE @NoSecuenciaAprobadorAnterior INT 
    -- Insert statements for procedure here
	    	
						
	   /*TABLA 1 ENCABEZADO*/
	   BEGIN       
	    /*ENCABEZADO DEL PEDIDO*/	
		 SELECT     
		 SAP.IdSolicitudAceptacionPedido,
		 SAP.Comentario,
		 P.IdPedido,    
		 P.IdSolicitudPedido,    		 
		 CONCAT(ISNULL(PV.RazonSocial,''),ISNULL(' '+ PV.RegimenCapital,'')) AS Proveedor,    
		 FORMAT(ISNULL(P.FechaEnvioPedido, GETDATE()),'dd/MM/yyyy') AS FechaEnvioPedido,    
		 P.IdPeticionOferta,    
		 P.RecepcionServicio,    
		 FORMAT(ISNULL(P.FechaRecepcionServicio,GETDATE()),'dd/MM/yyyy') as FechaRecepcionServicio,  
		 PG.IdPedido AS PedidoGeneral,
		 ISNULL(P.Cerrado, 0) AS Cerrado,
		 P.IdSubcontratista AS ProveedorVentaId,
		 E.Nombre AS EstatusAprobacion,
		 O.IdEstatusOperacion AS IdEstatus,
		 FORMAT(ISNULL(SAP.CreadoEl, GETDATE()),'dd/MM/yyyy') AS SolitudCreadaEl  ,
		 UE.Nombre AS CreadoPor,
		 ISNULL(SAP.IdAceptacionPedido,0) AS IdAceptacionPedido ,
		 SR.Nombre AS  SolicitanteRequisicion,
		 PG.IdTipoPedido
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
			ON P.IdSubcontratista = PV.IdProveedor
		 LEFT JOIN S_Usuario UE
			ON SAP.CreadorPor = UE.IdUsuario
		LEFT JOIN MM_SolicitudPedido SP
			ON P.IdSolicitudPedido	= SP.IdSolicitudPedido
		LEFT JOIN S_Usuario SR 
			ON SP.Solicitante = SR.IdUsuario
		 WHERE 
			P.IdProveedorCompras = @IdProveedor 
			AND SAP.IdPedido = @IdPedido 
			AND SAP.IdSolicitudAceptacionPedido =@IdSolicitudAceptacionPedido
		 GROUP BY     
		 P.IdPedido,     
		 P.IdSolicitudPedido,		  
		 PV.RazonSocial,     		
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
		 SAP.IdAceptacionPedido,
		 SR.Nombre,
		 PG.IdTipoPedido,
		 PV.RegimenCapital
	END
	  
	  /*TABLA 2 PRODUCTOS*/
	   BEGIN     
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
		POD.UnidadProveedor AS Unidad	
		FROM MM_SolicitudAceptacionPedidoDetalle SAPD 		
		JOIN MM_PedidoDetalle AS PD 
			ON SAPD.IdPedidoDetalle		= PD.IdPedidoDetalle
		JOIN MM_Pedido	P
			ON PD.IdPedido	= P.IdPedido
		JOIN MM_Material AS M 
			ON PD.IdMaterialVendedor	=	M.IdMaterial 
		JOIN MM_PeticionOferta AS PO 
			ON PO.IdPeticionOFerta = P.IdPeticionOferta		
		JOIN MM_PeticionOfertaDetalle AS POD 
			ON PO.IdPeticionOferta = POD.IdPeticionOferta 
			AND POD.IdMaterial = PD.IdMaterial
		JOIN MM_SolicitudPedidoDetalle AS SPD 
			ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle		
		JOIN PV_TipoMoneda AS TM 
			ON TM.IdMoneda = PD.IdMoneda 		
		WHERE P.IdProveedorCompras = @IdProveedor 		
		AND P.IdPedido = @IdPedido
		AND SAPD.IdSolicitudAceptacionPedido= @IdSolicitudAceptacionPedido
		ORDER BY M.Descripcioncorta ASC
	  END 

	  /*TABLA 3 DOCUMENTOS*/
	   BEGIN     
		 /*TABLA DE DOCUMENTOS*/
		 SELECT  D.IdDocumento, D.NombreDocumento, D.IdDocumentoTabla 
         FROM  S_Documento_S3 D  
         WHERE  D.IdDocumentoTabla=@IdSolicitudAceptacionPedido
		 AND D.Activo=1 
		 AND D.IdTipoDocumento = 12 --> CTE ACEPTACION DE PEDIDO --> SELECT * FROM S_TipoDocumento WHERE IdTipoDocumento=12  
	   END

	   /*TABLA 4 APROBADORES*/
	   BEGIN     
         /*TABLA CON INFORMACIÓN DE APROBACIÓN*/
		 SELECT 
		 T.IdTarea,
		 T.IdEstatus,
		 U.Nombre AS Aprobador,
		 ISNULL(T.Comentario,'') AS Comentario,
		 ISNULL(FORMAT(T.FechaCambioEstatus,'dd/MM/yyyy HH:mm'),'') AS FechaCambioEstatus,
		 E.Nombre AS Estatus,
		 T.IdOperacion 
		 FROM TA_Operacion O
		 JOIN TA_Tarea T 
			ON O.IdOperacion = T.IdOperacion
		 JOIN S_Usuario U
			ON T.IdAprobador = U.IdUsuario
		 JOIN TA_Estatus E
			ON T.IdEstatus = E.IdEstatus
		WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
		AND O.IdTipoOperacion=@TipoOperacionId		
		AND T.Activo=1
	  END 

	  /*TABLA 5 APROBADOR ACTUAL*/
	  BEGIN
	    
		/*POR DEFAULT ESTE TIPO DE APROBACIONES NO TIENEN FLUJO DE APROBACION,  POR DEFAULT SON APROBACIONES SERIALES*/

		 ---OBTENER EL NUMERO DE SECUENCIA DEL USUARIO ACTUAL SI ES APROBADOR DEL FLUJO ACTUAL    
        SELECT @NoSecuenciaUsuarioActual = TT.NoSecuencia  
        FROM TA_Operacion O  
            JOIN TA_Tarea TT  
                ON O.IdOperacion = TT.IdOperacion  
        WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
			 AND O.IdTipoOperacion=@TipoOperacionId	
              AND TT.IdAprobador = @IdUsuario  
              AND TT.Activo = 1;  
  
        ---OBTENER EL ESTATUS DEL APROBADOR ANTERIOR     
        --- ESTO ES PARA BLOQUEAR BOTONES DE APROBACIÓN SI LA APROBACIÓN ES DE TIPO SERIAL    
        SELECT @IdEstatusUsuarioAnteriorSecuencia = TT.IdEstatus,  
               @NoSecuenciaAprobadorAnterior = TT.NoSecuencia  
        FROM TA_OPERACION O  
            JOIN TA_Tarea TT  
                ON O.IdOperacion = TT.IdOperacion  
        WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
			 AND O.IdTipoOperacion=@TipoOperacionId	 
              AND TT.NoSecuencia = (ISNULL(@NoSecuenciaUsuarioActual, 0) - 1)  
              AND TT.Activo = 1;  

		SELECT 
		 'ES_APROBADOR'  AS EsAprobador,    
		 T.NoSecuencia,
		 T.IdTarea,
		 T.IdEstatus,
		 U.Nombre AS Aprobador,
		 ISNULL(T.Comentario,'') AS Comentario,
		 ISNULL(FORMAT(T.FechaCambioEstatus,'dd/MM/yyyy HH:mm'),'') AS FechaCambioEstatus,
		 E.Nombre AS Estatus,
		 CASE WHEN ISNULL(@IdEstatusUsuarioAnteriorSecuencia, 0) = 1 THEN 
			'ESPERAR_USUARIO_ANTERIOR'
		 ELSE 
		    'HABILITAR_APROBACION'
		  END
		 AS EsperarAprobacion,  
         ISNULL(@NoSecuenciaAprobadorAnterior, 0) AS NoSecuenciaAnterior,
		 O.IdOperacion  
		 FROM TA_Operacion O
		 JOIN TA_Tarea T 
			ON O.IdOperacion = T.IdOperacion
		 JOIN S_Usuario U
			ON T.IdAprobador = U.IdUsuario
		 JOIN TA_Estatus E
			ON T.IdEstatus = E.IdEstatus
		WHERE O.IdDocumento=@IdSolicitudAceptacionPedido
		AND O.IdTipoOperacion=@TipoOperacionId	
		AND T.IdAprobador=@IdUsuario
		AND T.Activo=1


	  END 

END;

