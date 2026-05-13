
-- =============================================
-- Author:	DANIEL AC
-- Create date: 03/10/2019
-- Description: HISTORIAL DE ELIMINACIÓN DE PROCESOS PETROVENDOR 
-- Se agrego concat al las razones sociales y regimen capital
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_HistorialEliminacion_Petrovendor]  

 @IDPROVEEDOR INT,
 @IDCONTRATO INT,
 @IDUSUARIO INT,
 @ACCION NVARCHAR(MAX) = NULL,
 @IDELIMINADO INT =NULL

 ---EXEC [dbo].[SP_MM_HistorialEliminacion_Petrovendor] 427,0,2205,'COTIZACIONES'
AS
BEGIN

  SET NOCOUNT ON;
   

   IF @ACCION='COTIZACIONES'
   BEGIN 
	  SELECT PO.IdPeticionOferta,
               PO.CreadoEl,
               O.FechaFinalizacion AS FechaLimite,
               CONCAT(ISNULL(RazonSocial,''),' ', ISNULL(RegimenCapital,'')) AS RazonSocial,
               O.Descripcion AS MotivoUrgencia,
               TSP.TipoSolicitudPedido,
               CASE
                   WHEN PO.Cotizado = 1  THEN
                       'Cotizada'
                   WHEN PO.Cotizado = 0  THEN
                       'No Cotizada'
                   WHEN PO.Cotizado IS NULL AND PO.NoCotizar IS NULL
                        AND DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) < 0 THEN
                       'En cotización'
                   WHEN PO.Cotizado IS NULL AND DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) >= 0 THEN
                       'Vencida'				    
               END AS EstatusCotizacion,
			   CASE
                   WHEN COUNT(PED.IdPedido) = 0 THEN 
				   /*SE CAMBIO A COUNT YA QUE SI COOCAS EL IDPEDIDO SE DUPLICA LA COTIZACIÓN DEACUERSDO A LA CANTIDAD DE PEDIDO EXISTENTES*/
                       'Cotización Abierta'
                   WHEN COUNT(PED.IdPedido) > 0 THEN
                       'Cotización Cerrada'
               END AS Disponibilidad,
			   PO.IdEliminado,
			   RE.FechaRegistro,
			   RE.ComentarioExterno
        FROM MM_PeticionOferta AS PO
            INNER JOIN MM_SolicitudPedido AS SP
                ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
            INNER JOIN TA_Operacion AS O
                ON O.IdDocumento = PO.IdSolicitudPedido
            INNER JOIN S_Proveedor AS P
                ON P.IdProveedor = SP.IdProveedor
            INNER JOIN MM_TipoSolicitudPedido AS TSP
                ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
			LEFT JOIN dbo.MM_Pedido AS PED
				ON PED.IdSolicitudPedido = PO.IdSolicitudPedido
			LEFT JOIN dbo.MM_Pedido AS PEDD
				ON PEDD.IdPeticionOferta = PO.IdPeticionOferta
			LEFT JOIN AD_RegistroEliminacion RE ON RE.IdEliminacion= PO.IdEliminado
        WHERE PO.IdSubcontratista = @IdProveedor AND
              O.IdTipoOperacion = 6
              AND O.FechaFinalizacion IS NOT NULL 
			  AND ISNULL(PO.Visible,1)=1
			  AND ISNULL(PO.IdEstatusEliminado,0)= 1 --> QUE NO ESTE ELIMINADO
		GROUP BY 
		      PO.IdPeticionOferta,
               PO.CreadoEl,
               O.FechaFinalizacion,
               RazonSocial,
			   RegimenCapital,
               O.Descripcion,
               TSP.TipoSolicitudPedido,
			   PO.Cotizado,
			   PO.IdEstatusEliminado,			  
			   O.FechaFinalizacion,
			   PO.NoCotizar,
			   RE.FechaRegistro,
			   PO.IdEliminado,
			   RE.ComentarioExterno
        ORDER BY PO.IdPeticionOferta DESC;
   END 

   IF @ACCION='PEDIDOS'
   BEGIN 
	 SELECT P.IdPedido,
               P.FechaEnvioPedido AS FechaPedido,
               SUM(PD.Subtotal) AS TotalPedido,
               CONCAT(ISNULL(RazonSocial,''),' ', ISNULL(RegimenCapital,'')) AS Cliente,
               Version,
               [FechaVigencia],
               P.IdProveedorCompras,
               PG.IdPedido AS IdPedidoGeneral,
               TM.TipoMonedaCorto AS Moneda,
               CASE
                   WHEN P.RecepcionServicio = 1 THEN
                       'Confirmada'
                   WHEN P.RecepcionServicio = 0  THEN
                       'Rechazada'
                   WHEN (DATEDIFF(MINUTE, [FechaVigencia], GETDATE())) >= 0 
                        AND P.RecepcionServicio IS NULL THEN
                       'Vencida'
                   WHEN (DATEDIFF(MINUTE, [FechaVigencia], GETDATE())) <= 0 
                        AND P.RecepcionServicio IS NULL THEN
                       'En confirmación'				  
               END AS EstatusRecepcion,
               TP.TipoPedido,
               TP.IdTipoPedido,
			   P.IdEliminado,
			   RE.ComentarioExterno, 
			   RE.FechaRegistro
        FROM MM_Pedido AS P
            INNER JOIN MM_PedidoDetalle AS PD
                ON PD.IdPedido = P.IdPedido
            INNER JOIN MM_PeticionOferta AS PO
                ON PO.IdPeticionOferta = P.IdPeticionOferta
            INNER JOIN S_Proveedor AS PV
                ON PV.IdProveedor = P.IdProveedorCompras
            INNER JOIN TA_Operacion AS O
                ON O.IdDocumento = P.IdSolicitudPedido
                   AND P.Version = O.NoVersion
            INNER JOIN TA_Prioridad AS PR
                ON PR.IdPrioridad = O.IdPrioridad
            INNER JOIN TA_Vencimiento AS V
                ON V.IdVencimiento = O.IdVigencia
            INNER JOIN TA_TipoOperacion AS TTO
                ON TTO.IdTipoOperacion = O.IdTipoOperacion
            INNER JOIN TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion
            INNER JOIN MM_HorasVigenciaPedido AS HV
                ON HV.IdPedido = P.IdPedido
            INNER JOIN MM_Pedidos AS PG
                ON P.IdPedido = PG.IdIdentificador
                   AND PG.IdProveedorCliente = P.IdProveedorCompras
            INNER JOIN PV_TipoMoneda AS TM
                ON TM.IdMoneda = P.IdMoneda
            LEFT JOIN dbo.MM_TipoPedido AS TP
                ON TP.IdTipoPedido = PG.IdTipoPedido
			LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=P.IdEliminado
        WHERE O.IdTipoOperacion = 9
              AND P.IdSubcontratista = @IdProveedor
              AND O.IdEstatusOperacion = 2
			  AND ISNULL(P.IdEstatusEliminado,0)=1 --> QUE NO ESTE ELIMINADO
        GROUP BY P.IdPedido,
                 P.IdSolicitudPedido,
                 P.FechaEnvioPedido,
                 RazonSocial,
                 RegimenCapital,
                 E.Nombre,
                 Version,
                 [FechaVigencia],
                 P.IdProveedorCompras,
                 PG.IdPedido,
                 TM.TipoMonedaCorto,
                 O.IdEstatusOperacion,
                 P.RecepcionServicio,
                 TP.TipoPedido,
                 TP.IdTipoPedido,
				 P.IdEstatusEliminado,
				 P.IdEliminado,
			    RE.ComentarioExterno, 
			    RE.FechaRegistro
        ORDER BY PG.IdPedido DESC;
   END 

   IF @ACCION='APROBACION_CN'
   BEGIN 
		SELECT 
			A.IdAceptacionPedido,
			A.IdPedido,
			A.Creado,
			A.NombreUsuarioEntrega,
			CONCAT(ISNULL(PV.RazonSocial,''),' ', ISNULL(PV.RegimenCapital,'')) AS Cliente,
			PG.IdPedido AS IdPedidoGeneral,
			AC.IdAceptacionCartaPCN,
			ISNULL(TV.TipoValidacion,'Sin iniciar aprobación')	AS EstatusAprobacion,
			TP.IdTipoPedido	,
			RE.FechaRegistro, 
			RE.ComentarioExterno,
			RE.IdEliminacion
         FROM dbo.MM_Pedido AS P	
		 INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = P.IdProveedorCompras
		 INNER JOIN MM_AceptacionPedido AS A ON A.IdPedido=P.IdPedido		 
		 LEFT JOIN dbo.MM_AceptacionCartaPCN AS AC ON AC.IdAceptacionPedido = A.IdAceptacionPedido	
		 LEFT JOIN dbo.S_TipoValidacionDoc AS TV ON TV.IdTipoValidacionDoc=AC.IdEstatus
		 INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdProveedorCompras	
		 LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		 LEFT JOIN dbo.AD_RegistroEliminacion AS RE ON RE.IdEliminacion=AC.IdEliminado
         WHERE P.IdSubcontratista = @IdProveedor
		 AND (AC.IdAceptacionCartaPCN IN (SELECT TOP 1  A_PCN.IdAceptacionCartaPCN 
										  FROM dbo.MM_AceptacionCartaPCN A_PCN 
										  WHERE A_PCN.IdAceptacionPedido=A.IdAceptacionPedido 
										  ORDER BY A_PCN.CreadoEl DESC) 
			  OR AC.IdAceptacionCartaPCN IS NULL
		 ) 
		  AND ISNULL(A.IdEstatusEliminado,0)=1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACIÓN DE PEDIDO 
		 AND ISNULL(AC.IdEstatusEliminado,0)=1 --> OCULTAR CARTAS DE CONTENIDO NACIONAL DONDE EL ESTATUS DE ELIMINACION LOGICA =1 DE ACEPTACION CARTA CN
		 AND ISNULL(A.IdNacionalidadProveedor,0) <> 2 --> NACIONALIDAD EXTRANJERA		 
		 GROUP BY 		
		 A.IdAceptacionPedido,
		 A.IdPedido,
		 A.Creado,
		 A.NombreUsuarioEntrega,
		 PV.RazonSocial,
		 PV.RegimenCapital,
		 PG.IdPedido ,
		 AC.IdAceptacionCartaPCN,
		 TV.TipoValidacion,
		 TP.IdTipoPedido,
		 A.IdEstatusEliminado,
		 RE.FechaRegistro, 
		 RE.ComentarioExterno,
		 RE.IdEliminacion
		 ORDER BY A.IdAceptacionPedido DESC


   END

   IF @ACCION='APROBACION_FACTURA'
   BEGIN 
		SELECT 
		AP.IdAceptacionPedido,
        AP.IdPedido,
        CONCAT(PV.RazonSocial, ' ', ISNULL(PV.RegimenCapital, '')) AS Cliente,
        APC.FechaEvaluacion AS FechaAperturaCarga,        
		ISNULL(E.Nombre, 'Sin Iniciar Aprobación') AS EstatusCarga,
        O.IdOperacion,
        PG.IdPedido AS IdPedidoGeneral,
		TP.TipoPedido,
		APC.IdEliminado,
		RE.ComentarioExterno, 
		RE.FechaRegistro		
		FROM dbo.MM_Pedido P		
		 INNER JOIN MM_Pedidos AS PG
                ON P.IdPedido = PG.IdIdentificador                  
                   AND PG.IdProveedorCliente = P.IdProveedorCompras 
		INNER JOIN MM_AceptacionPedido AS AP 
				ON AP.IdPedido= P.IdPedido
		INNER JOIN MM_AceptacionCartaPCN AS APC
                ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
				AND ISNULL(APC.IdEstatusEliminado,0)=1  --> Que no esten eliminadas 
		INNER JOIN S_Proveedor AS PV
                ON PV.IdProveedor = P.IdProveedorCompras	
		INNER JOIN S_TipoValidacionDoc AS TVD
                ON TVD.IdTipoValidacionDoc = APC.IdEstatus	
		LEFT JOIN MM_AceptacionFactura AS AF
                ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
				AND ISNULL(AF.IdEstatusEliminado,0)=1  --> Que no esten eliminadas 
		LEFT JOIN TA_Operacion AS O
                ON O.IdDocumento = AF.IdAceptacionFactura     
        LEFT JOIN TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion
		LEFT  JOIN dbo.MM_TipoPedido AS TP 
				ON TP.IdTipoPedido = PG.IdTipoPedido
		LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=APC.IdEliminado
		WHERE P.IdSubcontratista=@IdProveedor AND APC.IdEstatus=2 
		AND (O.IdOperacion IS NULL OR O.IdTipoOperacion=10) 
		AND APC.FechaEvaluacion IS NOT NULL		
		GROUP BY AP.IdAceptacionPedido,
                 AP.IdPedido,
                 PV.RazonSocial,
                 PV.RegimenCapital,
                 APC.FechaEvaluacion,
                 E.Nombre,
                 O.IdOperacion,
                 PG.IdPedido,
				 TP.TipoPedido,
				 APC.IdEstatusEliminado,
				 O.IdDocumento,
				 AF.IdEstatusEliminado,
				 APC.IdEliminado,
				 RE.ComentarioExterno, 
				 RE.FechaRegistro
				 ORDER BY AP.IdAceptacionPedido DESC

   END 

     IF @ACCION='APROBACION_COMPROBANTE'
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
			END AS Estatus,
			RE.IdEliminacion,
			RE.FechaRegistro,
			RE.ComentarioExterno
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
				ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante AND ISNULL(PC.IdEstatusEliminado,0)=1--> PEDIMENTO COMPROBANTE NO ESTE ELIMINADO
			 LEFT JOIN dbo.TA_Operacion O 
				ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
			 LEFT JOIN dbo.TA_Estatus AS E
					ON E.IdEstatus = O.IdEstatusOperacion	
			LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=AP.IdEliminado			
			 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA		
			 AND P.IdSubcontratista=@IdProveedor		
			 AND ISNULL(AP.IdEstatusEliminado,0)=1 --> ACEPTACIÓN PEDIDO NO ESTE ELIMINADO 		 
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
					 AP.IdEstatusEliminado,
					 RE.IdEliminacion,
					RE.FechaRegistro,
					RE.ComentarioExterno
			ORDER BY AP.IdAceptacionPedido DESC;
	   END
END 
