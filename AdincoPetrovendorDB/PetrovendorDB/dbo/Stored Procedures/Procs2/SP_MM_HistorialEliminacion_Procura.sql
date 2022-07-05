USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_HistorialEliminacion_Procura]    Script Date: 04/07/2022 08:10:19 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:	DANIEL AC
-- Create date: 08/03/2018
-- Description: ELIMINACIÓN DE PEDIDO HISTORIAL DE PROCURA
-- =============================================
-- Author:	Alexander Gomez
-- Create date: 05/07/2022
-- Description: correccion al eliminar factura
-- =============================================

ALTER  PROCEDURE [dbo].[SP_MM_HistorialEliminacion_Procura]  

 @IDPROVEEDOR INT,
 @IDCONTRATO INT,
 @IDUSUARIO INT,
 @ACCION NVARCHAR(MAX) = NULL,
 @IDELIMINADO INT =NULL

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	
	IF @ACCION IS NULL
	BEGIN 
		SELECT 
		RE.IdEliminacion,
		RE.FechaRegistro AS FechaEliminacion,
		te.DetalleEliminacion,
		CASE WHEN TE.TipoEliminacion = 'P' THEN 
			PG.IdPedido /*CUNADO SEA UN PEDIO SE DEBE MOSTRAR EL ID PEDIDO GENERAL */
		ELSE 
			RE.IdProceso 
		END AS NoProceso,
		RE.ComentarioExterno,
		RE.ComentarioInterno,
		U.Nombre AS Usuario
		FROM dbo.AD_RegistroEliminacion RE
		INNER  JOIN dbo.AD_TipoEliminacion TE ON TE.TipoEliminacion = RE.TipoEliminacion
		LEFT JOIN dbo.S_Usuario U ON U.IdUsuario = RE.IdUsuario
		LEFT JOIN dbo.MM_Pedidos PG ON RE.IdProceso = PG.IdIdentificador AND PG.IdProveedorCliente=@IDPROVEEDOR
		WHERE RE.IdProveedor=@IDPROVEEDOR AND RE.Activo=1
		ORDER BY RE.FechaRegistro DESC 
	END 

	IF @ACCION = 'HISTORIAL_DETALLE'
	BEGIN
		DECLARE @TIPO_ELIMINACION NVARCHAR(50) 
		DECLARE @ID_PROCESO INT 
		 

		SELECT @ID_PROCESO=IdProceso FROM  AD_RegistroEliminacion WHERE @IDELIMINADO=IdEliminacion
		SELECT @TIPO_ELIMINACION=TipoEliminacion FROM  AD_RegistroEliminacion WHERE @IDELIMINADO=IdEliminacion
	    /*drop table #PROCESO*/
		CREATE TABLE #PROCESO(ID INT IDENTITY(1,1),ID_PADRE INT, PROCESO NVARCHAR(500),ESTATUS NVARCHAR(500),IDESTATUS INT, CLASS NVARCHAR(300), CLAVE_PROCESO NVARCHAR(200), ACCION_EJECUTAR NVARCHAR(300), ID_PROCESO INT, ID_PROCESO_PUBLICO INT )
	
		/*HISTORIAL DE ELIMINACIÓN DE UNA ACEPTACIÓN DE PEDIDO*/
		IF @TIPO_ELIMINACION='AP' AND @ID_PROCESO IS NOT NULL
		BEGIN 
						 
			/*RECUPERAR ACEPTACIONES DE PEDIDO ELIMINADOAS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT
			0,
			CONCAT('Aceptación de pedido No.',AP.IdAceptacionPedido),
			'',
			0,
			'',
			'aceptacionpedido',
			'',
			AP.IdAceptacionPedido
			FROM dbo.MM_AceptacionPedido AP
			WHERE IdAceptacionPedido=@ID_PROCESO  AND AP.IdEliminado= @IDELIMINADO


			/*RECUPERAR CARTA DE CONTENIDO NACIONAL ELIMINADAS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			PAP.ID,
			CONCAT('Aceptación de Carta Contenido Nacional No.',AP.IdAceptacionPedido),
			CASE WHEN AC.IdEstatus IS NULL THEN 
				'<i class="fa fa-tag text-warning"></i> Solicitada al proveedor'
				ELSE 
				'<i class="fa fa-tag text-warning"></i>' +' '+TD.TipoValidacion
			END,
			AC.IdEstatus,
			'',
			'aceptacioncn',
			'',	
			AC.IdAceptacionCartaPCN
			FROM MM_AceptacionPedido AS AP
			INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
			LEFT JOIN MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			LEFT JOIN S_Documento_S3 AS D ON D.IdDocumento = AC.IdDocumento
			LEFT JOIN S_TipoValidacionDoc AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR	
			INNER JOIN #PROCESO PAP ON PAP.ID_PROCESO=AP.IdAceptacionPedido
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE 
			 AC.IdEliminado = @IDELIMINADO  
			 AND PAP.CLAVE_PROCESO='aceptacionpedido'			
			GROUP BY 
			AC.IdAceptacionCartaPCN	,
			TD.TipoValidacion,
			AP.IdAceptacionPedido,
			AC.IdEstatus,
			PAP.ID


			/*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS CON */

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			TEM_AP.ID,
			CONCAT('Recepción de factura No.',AF.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
			O.IdEstatusOperacion,
			'',
			'aceptacionfactura',
			'',
			AF.IdAceptacionFactura
			FROM MM_AceptacionFactura AS AF
			INNER JOIN  TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura AND O.	
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion			
			INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
			INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
			LEFT JOIN MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			LEFT JOIN S_Documento_S3 AS D ON D.IdDocumento = AC.IdDocumento
			LEFT JOIN S_TipoValidacionDoc AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR	
			LEFT JOIN #PROCESO AS TEM_CN ON TEM_CN.ID_PROCESO=ac.IdAceptacionCartaPCN
			LEFT JOIN #PROCESO AS TEM_AP ON TEM_AP.ID_PROCESO=AF.IdAceptacionPedido
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE AF.IdEliminado=@IDELIMINADO
			GROUP BY AP.IdAceptacionPedido,
			E.Nombre,
			O.IdEstatusOperacion,
			AF.IdAceptacionFactura,
			AF.IdAceptacionPedido,
			TEM_AP.ID;
		  --AND TEM_CN.CLAVE_PROCESO='aceptacioncn'
		  --AND TEM_CN.IdEstatus=2 --> CN APROBADA

		  /*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS CON */

		 INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			PAP.ID,
			CONCAT('Recepción de comprobante extranjero No.',AP.IdAceptacionPedido),
			CASE WHEN O.IdOperacion IS NULL THEN 
				'<i class="fa fa-tag text-warning"></i> Solicitado al proveedor'
				ELSE
				'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre
				END,
			O.IdEstatusOperacion,
			'',
			'aprobacionextranjera',
			'',
			PC.IdPedimentoComprobante	
			FROM MM_AceptacionPedido AS AP
			INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR	 
			INNER JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
					ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
			INNER JOIN dbo.FI_PedimentoComprobante PC 
					ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
			INNER JOIN dbo.TA_Operacion O 
					ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
			INNER JOIN #PROCESO PAP ON PAP.ID_PROCESO=AP.IdAceptacionPedido
			INNER JOIN dbo.TA_Estatus AS E
						ON E.IdEstatus = O.IdEstatusOperacion	
			AND PC.IdEliminado=@IDELIMINADO
			AND PAP.CLAVE_PROCESO='aceptacionpedido'

			SELECT * FROM #PROCESO 

		END 

		IF @TIPO_ELIMINACION='P' AND @ID_PROCESO IS NOT NULL
		BEGIN 
			
			/*RECUPERAR ACEPTACIONES DE PEDIDO ELIMINADOAS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT
			0,
			CONCAT('Pedido No.',PG.IdPedido),
			CONCAT('<i class="fa fa-info-circle text-warning" title="Este pedido pertenece a la siguiente aprobación"></i>',' Aprobación de pedido No. Operación ',O.IdOperacion,' <i class="fa fa-tag text-warning"></i> ',E.Nombre),
			0,
			'',
			'pedido',
			'',
			P.IdPedido
			FROM dbo.MM_Pedido P
			INNER JOIN dbo.MM_Pedidos PG ON PG.IdIdentificador = P.IdPedido 
			INNER JOIN dbo.TA_Operacion O ON O.IdDocumento=P.IdSolicitudPedido
			INNER JOIN dbo.TA_Estatus E ON E.IdEstatus=O.IdEstatusOperacion 
			AND O.NoVersion=P.Version
			WHERE 
			P.IdPedido=@ID_PROCESO   
			AND P.IdEliminado= @IDELIMINADO 
			AND PG.IdProveedorCliente=@IDPROVEEDOR

			/*RECUPERAR CONFIRMACIONES DE SERVICIO*/

				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			    SELECT 	
				TEM_PED.ID,
				'Confirmación de pedido',
				CASE 
				WHEN P.RecepcionServicio = 1 THEN '<i class="fa fa-tag text-warning"></i> Aceptada' 
				WHEN P.RecepcionServicio  = 0 THEN '<i class="fa fa-tag text-warning"></i> Rechazada' 
				WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN	
						'<i class="fa fa-tag text-warning"></i> Vencida'  
				ELSE 	  
						'<i class="fa fa-tag text-warning"></i> En confirmación' 
				END AS RecepcionServicio,
				'',
				'confirmacionpedido',
				'', 
				P.IdPedido,
				PG.IdPedido	
				FROM TA_Operacion AS O
				INNER JOIN MM_Pedido AS P ON O.IdDocumento = P.IdSolicitudPedido
				INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
				INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista		
				INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
				LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda
				INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR				
				INNER JOIN #PROCESO AS TEM_PED ON TEM_PED.ID_PROCESO=P.IdPedido 
				LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
				WHERE O.IdTipoOperacion = 9  --> APROBACIÓN DE PEDIDO
				 AND O.IdEstatusOperacion=2 --> APROBADA
				 AND O.IdProveedor = @IDPROVEEDOR 				  
				 AND O.NoVersion=P.Version							
				 AND TEM_PED.CLAVE_PROCESO='pedido'		
				 AND P.IdEliminado=@IDELIMINADO		 
				GROUP BY 
				P.IdPedido,
				PV.Razonsocial,
				PV.RegimenCapital,
				PG.IdPedido,				
				TEM_PED.ID,
				P.RecepcionServicio,
				HV.FechaVigencia,
				O.IdEstatusOperacion 

			
			/*RECUPERAR ACEPTACIONES DE PEDIDO ELIMINADOAS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT
			P.ID,
			CONCAT('Aceptación de Servicio No.',AP.IdAceptacionPedido),
			'',
			0,
			'',
			'aceptacionpedido',
			'',
			AP.IdAceptacionPedido
			FROM dbo.MM_AceptacionPedido AP
			INNER JOIN #PROCESO P ON P.ID_PROCESO=AP.IdPedido
			INNER JOIN #PROCESO PC ON PC.ID_PROCESO = AP.IdPedido
			WHERE AP.IdEliminado= @IDELIMINADO
			AND P.CLAVE_PROCESO='pedido'
			AND PC.CLAVE_PROCESO='confirmacionpedido'



			/*RECUPERAR CARTA DE CONTENIDO NACIONAL ELIMINADAS CON EL IDELIMINADO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			PAP.ID,
			CONCAT('Aceptación de Carta Contenido Nacional No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+TD.TipoValidacion,
			AC.IdEstatus,
			'',
			'aceptacioncn',
			'',	
			AC.IdAceptacionCartaPCN
			FROM MM_AceptacionPedido AS AP
			INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
			INNER JOIN MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			INNER JOIN S_Documento_S3 AS D ON D.IdDocumento = AC.IdDocumento
			INNER JOIN S_TipoValidacionDoc AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR	
			INNER JOIN #PROCESO PAP ON PAP.ID_PROCESO=AP.IdAceptacionPedido
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE 
			 AC.IdEliminado = @IDELIMINADO  
			GROUP BY 
			AC.IdAceptacionCartaPCN	,
			TD.TipoValidacion,
			AP.IdAceptacionPedido,
			AC.IdEstatus,
			PAP.ID


			/*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS CON */

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			TEM_CN.ID,
			CONCAT('Recepción de factura No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
			O.IdEstatusOperacion,
			'',
			'aceptacionfactura',
			'',
			AF.IdAceptacionFactura
			FROM MM_AceptacionFactura AS AF
			INNER JOIN  TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura 	
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion			
			INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
			INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
			INNER JOIN MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			INNER JOIN S_Documento_S3 AS D ON D.IdDocumento = AC.IdDocumento
			INNER JOIN S_TipoValidacionDoc AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR	
			INNER JOIN #PROCESO AS TEM_CN ON TEM_CN.ID_PROCESO=ac.IdAceptacionCartaPCN
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE 	
		  TEM_CN.CLAVE_PROCESO='aceptacioncn'
		  AND AF.IdEliminado=@IDELIMINADO
		  AND TEM_CN.IdEstatus=2 --> CN APROBADA

		  /*RECUPERAR APROBACIONES DE FACTURA ELIMINADAS CON */

		 INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,IDESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 	
			PAP.ID,
			CONCAT('Recepción de comprobante extranjero No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
			O.IdEstatusOperacion,
			'',
			'aprobacionextranjera',
			'',
			PC.IdPedimentoComprobante	
			FROM MM_AceptacionPedido AS AP
			INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR	 
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
					ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
			INNER JOIN dbo.FI_PedimentoComprobante PC 
					ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
			INNER JOIN dbo.TA_Operacion O 
					ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
			INNER JOIN #PROCESO PAP ON PAP.ID_PROCESO=AP.IdAceptacionPedido
			LEFT JOIN dbo.TA_Estatus AS E
						ON E.IdEstatus = O.IdEstatusOperacion				
			WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
			AND PC.IdEliminado=@IDELIMINADO
			AND PAP.CLAVE_PROCESO='aceptacionpedido'

			SELECT * FROM #PROCESO 

		END 

		IF @TIPO_ELIMINACION='SP' AND @ID_PROCESO IS NOT NULL
		BEGIN 
			
			/*RECUPERAR SOLICITUD DE PEDIDO CON EL IDELIMINADO*/

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO, ID_PROCESO_PUBLICO)	
			SELECT 
			0,
			CONCAT('Solicitud de pedido No.', IdSolicitudPedido),
			'',
			'',
			'solicitudpedido',
			'', 
			IdSolicitudPedido,
			IdSolicitudPedido 
			FROM dbo.MM_SolicitudPedido 
			WHERE IdSolicitudPedido=@ID_PROCESO
			AND ISNULL(IdEstatusEliminado,0) = 1
	
			/*BUSQUEDA DE APROBACIÓN DE SOLICITUD DE PEDIDO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)	
			SELECT 1,
			CONCAT('Aprobación de solicitud de pedido No. Operación ',O.IdOperacion),
			CONCAT('<i class="fa fa-tag text-warning"></i> ',E.Nombre),
			'',
			'aprobacionsp',
			'',
			O.IdOperacion,
			O.IdDocumento  
			FROM dbo.MM_SolicitudPedido AS SP
			INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento= SP.IdSolicitudPedido
			INNER JOIN dbo.TA_Estatus AS E ON E.IdEstatus=o.IdEstatusOperacion
			WHERE IdSolicitudPedido=@ID_PROCESO  AND O.IdEliminado=@IDELIMINADO AND O.IdTipoOperacion=2 -->APROBACIÓN DE SOLICITUD DE PEDIDO
			AND ISNULL(SP.IdEstatusEliminado,0)=1

			/*BUSQUEDA DE SOLICITUD DE OFERTA*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO, ID_PROCESO_PUBLICO)	
			SELECT 2,
			CONCAT('Solicitud de oferta No.',SP.IdSolicitudPedido),
			CASE WHEN SP.PeticionEnviada = 1 THEN 
				'<i class="fa fa-tag text-warning"></i> Enviada a cotización'
			ELSE 
				'<i class="fa fa-tag text-warning"></i> Sin enviar a cotización'
			END AS Estatus,
			'',
			'solicitudoferta',
			'', 
			SP.IdSolicitudPedido,
			SP.IdSolicitudPedido
			FROM dbo.MM_SolicitudPedido AS SP
			INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento= SP.IdSolicitudPedido
			WHERE IdSolicitudPedido=@ID_PROCESO 
			AND O.IdTipoOperacion=2 --> APROBACIÓN DE SOLICITUD DE PEDIDO
			AND O.IdEstatusOperacion=2 --> APROBADA
			AND ISNULL(SP.IdEstatusEliminado,0)=1

			/*BUSQUEDA DE OFERTA*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO, ID_PROCESO_PUBLICO)	
			SELECT 3,CONCAT('Oferta No.',SP.IdSolicitudPedido),
			(CASE WHEN (DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0) THEN
				'<i class="fa fa-tag text-warning"></i> Fecha límite de cotización finalizada'
			ELSE
				'<i class="fa fa-tag text-warning"></i> En cotización'
			END) AS ESTATUS
			,'', 'oferta','', SP.IdSolicitudPedido,SP.IdSolicitudPedido
			FROM dbo.MM_SolicitudPedido AS SP
			INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento= SP.IdSolicitudPedido
			WHERE IdSolicitudPedido=@ID_PROCESO 
			AND O.IdTipoOperacion=6 -->ENVIO PROCESO DE COTIZACIÓN
			AND ISNULL(SP.IdEstatusEliminado,0)=1


			/*BUSQUEDA DE APROBACIONES DE PEDIDO*/
			/*CONTAR CANTIDAD DE APROBACIONES DE PEDIDO*/
			DECLARE @CANTIDAD_APROBACIONES INT = 0 
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
			SELECT 4, CONCAT('Aprobación de pedido No. Operación ', o.IdOperacion),CONCAT('<i class="fa fa-tag text-warning"></i> ',E.Nombre),'','aprobacionpedido','', o.IdOperacion FROM dbo.MM_SolicitudPedido AS SP
			INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento= SP.IdSolicitudPedido
			INNER JOIN dbo.TA_Estatus AS E ON E.IdEstatus=o.IdEstatusOperacion
			WHERE IdSolicitudPedido=@ID_PROCESO
			AND O.IdTipoOperacion=9 --> APROBACIÓN DE PEDIDO
			ORDER BY O.IdOperacion ASC
								
			/*CONSULTA DE PEDIDO DE LAS APROBACIONES CORRESPONDIENTES*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			SELECT 	
			TEM.ID,
			CONCAT('Pedido ', PG.IdPedido),
			'<span class="text-black">' +(PV.Razonsocial + ' '+ISNULL(PV.RegimenCapital,''))+'</span>',
			'',
			'pedido',
			'', 
			P.IdPedido,
			PG.IdPedido
			FROM TA_Operacion AS O
			INNER JOIN MM_Pedido AS P ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista		
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			LEFT  JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
			INNER JOIN #PROCESO AS TEM ON TEM.ID_PROCESO=O.IdOperacion 
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
			 AND O.IdProveedor = @IdProveedor 
			 AND P.IdSolicitudPedido = @ID_PROCESO  
			 AND O.NoVersion=P.Version
			 AND O.IdOperacion=TEM.ID_PROCESO
			 AND TEM.CLAVE_PROCESO='aprobacionpedido'
			 AND ISNULL(P.IdEstatusEliminado,0)=1
			GROUP BY 
			P.IdPedido,
			PV.Razonsocial,
			PV.RegimenCapital,
			PG.IdPedido,
			TEM.ID

			/*CONFIRMACIÓN DE SERVICIO*/
			/*CONSULTA DE PEDIDO DE APROBADAS Y CON ACEPTACIÓN DE SERVICIO CORRESPONDIENTES AL PEDIDO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
		   SELECT 	
			TEM_PED.ID,
			'Confirmación de pedido',
			CASE 
			WHEN P.RecepcionServicio = 1 THEN '<i class="fa fa-tag text-warning"></i> Aceptada' 
			WHEN P.RecepcionServicio  = 0 THEN '<i class="fa fa-tag text-warning"></i> Rechazada' 
			WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN	
					'<i class="fa fa-tag text-warning"></i> Vencida'  
			ELSE 	  
					'<i class="fa fa-tag text-warning"></i> En confirmación' 
			END AS RecepcionServicio,
			'',
			'confirmacionpedido',
			'', 
			P.IdPedido,
			PG.IdPedido	
			FROM TA_Operacion AS O
			INNER JOIN MM_Pedido AS P ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista		
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
			INNER JOIN #PROCESO AS TEM ON TEM.ID_PROCESO=O.IdOperacion 
			INNER JOIN #PROCESO AS TEM_PED ON TEM_PED.ID_PROCESO=P.IdPedido 
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE O.IdTipoOperacion = 9  --> APROBACIÓN DE PEDIDO
			 AND O.IdEstatusOperacion=2 --> APROBADA
			 AND O.IdProveedor = @IdProveedor 
			 AND P.IdSolicitudPedido = @ID_PROCESO  
			 AND O.NoVersion=P.Version
			 AND O.IdOperacion=TEM.ID_PROCESO
			 AND TEM.CLAVE_PROCESO='aprobacionpedido'
			 AND TEM_PED.CLAVE_PROCESO='pedido'
			 AND ISNULL(P.IdEstatusEliminado,0) = 1
			GROUP BY 
			P.IdPedido,
			PV.Razonsocial,
			PV.RegimenCapital,
			PG.IdPedido,
			TEM.ID,
			TEM_PED.ID,
			P.RecepcionServicio,
			HV.FechaVigencia,
			O.IdEstatusOperacion 
	  
			/*ACEPTACIONES DE PEDIDO*/ 
			/*CONSULTA DE ACEPTACIONES DE PEDIDO DE LAS CONFIRMACIONES DE PEDIDO ACEPTADAS*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
	 
			SELECT 	
			TEM_CS.ID,
			CONCAT('Aceptación de servicio No.',AP.IdAceptacionPedido),
			'',
			'',
			'aceptacionpedido',
			'',
			AP.IdAceptacionPedido,
			AP.IdAceptacionPedido	
			FROM TA_Operacion AS O
			INNER JOIN MM_Pedido AS P ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN MM_AceptacionPedido AS AP ON P.IdPedido = AP.IdPedido
			INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista		
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
			INNER JOIN #PROCESO AS TEM ON TEM.ID_PROCESO=O.IdOperacion 
			INNER JOIN #PROCESO AS TEM_PED ON TEM_PED.ID_PROCESO=P.IdPedido 
			INNER JOIN #PROCESO AS TEM_CS ON TEM_CS.ID_PROCESO=P.IdPedido 
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO APROBADA
			 AND O.IdEstatusOperacion=2 --> APROBADA
			 AND O.IdProveedor = @IdProveedor 
			 AND P.IdSolicitudPedido = @ID_PROCESO  
			 AND O.NoVersion=P.Version
			 AND O.IdOperacion=TEM.ID_PROCESO
			 AND TEM.CLAVE_PROCESO='aprobacionpedido'
			 AND TEM_PED.CLAVE_PROCESO='pedido'
			 AND TEM_CS.CLAVE_PROCESO='confirmacionpedido'
			 AND ISNULL(AP.IdEstatusEliminado,0) = 1
			GROUP BY 
			P.IdPedido,
			PV.Razonsocial,
			PV.RegimenCapital,
			PG.IdPedido,
			TEM.ID,
			TEM_PED.ID,
			P.RecepcionServicio,
			HV.FechaVigencia,
			O.IdEstatusOperacion,
			AP.IdAceptacionPedido,
			TEM_CS.ID	

			/*ACEPTACIONES DE CARTA CONTENIDO NACIONAL*/
			/*CONSULTA DE ACEPTACIONES DE PEDIDO DE LAS CONFIRMACIONES DE PEDIDO ACEPTADAS Y CARTA DE CONTENIDO NACIONAL SI EL PROVEEDOR ES NACIONAL*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			SELECT 	
			TEM_AP.ID,
			CONCAT('Aceptación de Carta Contenido Nacional No.',AP.IdAceptacionPedido),
			CASE WHEN AC.IdEstatus IS NULL THEN 
			'<i class="fa fa-tag text-warning"></i> Solicitada al proveedor'
			ELSE 
			'<i class="fa fa-tag text-warning"></i>' +' '+TD.TipoValidacion
			END,
			'',
			'aceptacioncn',
			'',
			AC.IdAceptacionCartaPCN,
			AP.IdAceptacionPedido	
			FROM MM_AceptacionPedido AS AP
			INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
			LEFT JOIN MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			LEFT JOIN S_Documento_S3 AS D ON D.IdDocumento = AC.IdDocumento
			LEFT JOIN S_TipoValidacionDoc AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
			INNER JOIN #PROCESO AS TEM_AP ON TEM_AP.ID_PROCESO=AP.IdAceptacionPedido 
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE 
			 P.IdSolicitudPedido = @ID_PROCESO  	
			 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
			 AND ISNULL(AC.IdEstatusEliminado,0)=1
			GROUP BY 
			AC.IdAceptacionCartaPCN	,
			TD.TipoValidacion,
			AP.IdAceptacionPedido,
			AC.IdEstatus,
			TEM_AP.ID
		    /*RECEPCIÓN DE FACTURA*/

			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			SELECT 	
			TEM_CN.ID,
			CONCAT('Recepción de factura No.',AP.IdAceptacionPedido),
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre,
			'',
			'aceptacionfactura',
			'',
			AF.IdAceptacionFactura,
			AP.IdAceptacionPedido
			FROM MM_AceptacionFactura AS AF
			INNER JOIN  TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura 	
			INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion			
			INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
			INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
			INNER JOIN MM_AceptacionCartaPCN AS AC ON AP.IdAceptacionPedido = AC.IdAceptacionPedido	
			INNER JOIN S_Documento_S3 AS D ON D.IdDocumento = AC.IdDocumento
			INNER JOIN S_TipoValidacionDoc AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
			INNER JOIN #PROCESO AS TEM_AP ON TEM_AP.ID_PROCESO=AP.IdAceptacionPedido 
			INNER JOIN #PROCESO AS TEM_CN ON TEM_CN.ID_PROCESO=ac.IdAceptacionCartaPCN
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			WHERE 
			 P.IdSolicitudPedido = @ID_PROCESO  	
			 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
			 AND TEM_CN.CLAVE_PROCESO='aceptacioncn'
			 AND AC.IdEstatus=2 --> QUE LA APROBACIÓN DE CARTA CONTENIDO NACIONAL ESTE APROBADA

			/*COMPROBANTE EXTRANJERO*/
			INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
			SELECT 	
			TEM_AP.ID,
			CONCAT('Recepción de comprobante extranjero No.',AP.IdAceptacionPedido),
			CASE WHEN O.IdOperacion IS NULL THEN 
			'<i class="fa fa-tag text-warning"></i> Solicitado al proveedor'
			ELSE
			'<i class="fa fa-tag text-warning"></i>' +' '+E.Nombre
			END,
			'',
			'aprobacionextranjera',
			'',
			PC.IdPedimentoComprobante,
			AP.IdAceptacionPedido	
			FROM MM_AceptacionPedido AS AP
			INNER JOIN MM_Pedido AS P ON  P.IdPedido = AP.IdPedido	
			INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista	
			INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
			INNER JOIN #PROCESO AS TEM_AP ON TEM_AP.ID_PROCESO=AP.IdAceptacionPedido 
			LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
			LEFT JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
					ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
			LEFT JOIN dbo.FI_PedimentoComprobante PC 
					ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
			 
			LEFT JOIN dbo.TA_Operacion O 
					ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
			LEFT JOIN dbo.TA_Estatus AS E
						ON E.IdEstatus = O.IdEstatusOperacion	
			WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
			 AND P.IdSolicitudPedido=	@ID_PROCESO		 
			 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
			 AND ISNULL(PC.IdEstatusEliminado,0) = 1

			 SELECT * FROM #PROCESO
	    END	
	END 

	/*BUSCAR TOLAS LAS SOLICITUDES DE PEDIDO CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'SOLICITUD_PEDIDO'  
	BEGIN 
			
		SELECT 
		SP.IdSolicitudPedido, 
		SP.MotivoUrgencia,
		TSP.TipoSolicitudPedido, 
		SP.FechaAlta,			
		TE.Nombre,
		CC.CentroCosto,
		U.Nombre AS NombreUsuario,
		SP.MotivoUrgencia,
		AC.NombreAreaContractual AS AreaContractual,
		SP.IdEliminado,
		RH.FechaRegistro AS FechaEliminacion				 
		FROM MM_SolicitudPedido AS SP 
		INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido =SP.IdTipoSolicitudPedido 
		INNER JOIN TA_Operacion AS TAO ON TAO.IdDocumento= SP.IdSolicitudPedido  
		INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion  
		LEFT JOIN CC_CentroCosto AS CC ON SP.IdCentroCosto = CC.IdCentroCosto
		INNER JOIN S_Usuario AS U ON SP.IdUsuarioSolicitante = U.IdUsuario
		LEFT JOIN Adinco.dbo.CO_Contrato AS C ON SP.IdContrato = C.IdContrato    
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN dbo.AD_RegistroEliminacion RH ON RH.IdEliminacion=SP.IdEliminado 
		WHERE			
		TAO.IdTipoOperacion=2  --> APROBACIÓN DE SOLICITUD DE PEDIDO
		AND ISNULL(SP.Visible,1)=1
		AND ISNULL(SP.IdEstatusEliminado,0)=1--> TIPO DE ESTATUS ELIMINADO		
		AND SP.IdProveedor = @IDPROVEEDOR 	
		ORDER BY SP.FechaAlta DESC

	END 

	/*BUSCAR TOLAS LAS SOLICITUDES DE OFERTA CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'SOLICITUD_OFERTA'  
	BEGIN 
		SELECT  SP.IdSolicitudPedido,
					SP.MotivoUrgencia,
					TSP.TipoSolicitudPedido,
					PSP.Prioridad,
					SP.FechaAlta,
					(CASE SP.UnaSolaEntregaRequerida
						 WHEN 1
						 THEN CONVERT(NVARCHAR, SP.FechaEntregaRequerida, 103)
						 WHEN 0
						 THEN CONCAT(CONVERT(NVARCHAR, SP.FechaEntregaRequerida, 103), ' -- ', CONVERT(NVARCHAR, SP.FechaEntregaFinRequerida, 103))
					 END) AS FechaEntrega,
					  U.Nombre,
					  CASE 
					  WHEN SP.PeticionEnviada = 1 THEN 
						'Enviada'
					  ELSE 
						'Pendiente de enviar'
					  END AS EstatusOferta,
					  ISNULL(SP.IdTipoProceso,0) AS IdTipoProceso,
					  ISNULL(TP.TipoPedido, 'Sin clasificación') AS NombreTipo,
					  SP.IdEliminado,
					  RE.FechaRegistro
			 FROM MM_SolicitudPedido AS SP
				  INNER JOIN MM_TipoSolicitudPedido AS TSP ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
				  INNER JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
				  INNER JOIN TA_Operacion AS OT ON OT.IdDocumento = SP.IdSolicitudPedido
				  INNER JOIN S_Usuario AS U ON U.IdUsuario = OT.IdAsignador
				  LEFT JOIN dbo.MM_TipoPedido TP ON TP.IdTipoPedido = SP.IdTipoProceso	
				  LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=SP.IdEliminado	
			 WHERE 
				   OT.IdEstatusOperacion = 2
				   AND OT.IdTipoOperacion= 2 
				   AND SP.Activo = 1  
				   AND ISNULL(SP.Visible,1)=1	
				   AND ISNULL(SP.IdEstatusEliminado,0)= 1 -->CON ESTATUS ELIMINADO		  
				   AND SP.IdProveedor = @IdProveedor
			 GROUP BY SP.IdSolicitudPedido,
					SP.MotivoUrgencia,
					TSP.TipoSolicitudPedido,
					PSP.Prioridad,
					SP.FechaAlta,
					SP.UnaSolaEntregaRequerida,
					SP.FechaEntregaRequerida,
					SP.FechaEntregaFinRequerida,
					U.Nombre,
					SP.PeticionEnviada,
					SP.IdTipoProceso,
					TP.TipoPedido,
					SP.IdEstatusEliminado,
					SP.IdEliminado,
					RE.FechaRegistro
			 ORDER BY SP.IdSolicitudPedido DESC 

	END 

	/*BUSCAR TOLAS LAS OFERTAS CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'OFERTA'  
	BEGIN 

		 SELECT SP.IdSolicitudPedido,
               TSP.TipoSolicitudPedido,
               O.Descripcion,
               O.FechaRegistro,
               O.FechaFinalizacion AS FechaFinOferta,
               CAST(SUM(   CASE
                               WHEN PO.NoCotizar = 1 THEN
                                   1
                               ELSE
                                   CASE
                                       WHEN PO.Cotizado = 1 THEN
                                           1
                                       ELSE
                                           0
                                   END
                           END
                       ) AS NVARCHAR(MAX)) + '/' + CAST(COUNT(PO.IdPeticionOferta) AS NVARCHAR(MAX)) AS Nombre,
               CASE                  
				   WHEN (DATEDIFF(MINUTE, O.FechaFinalizacion, GETDATE()) > 0) THEN
                       'FINALIZADA'				  
                   ELSE
                       'EN COTIZACIÓN'
               END AS EstatusCotizacion,
			   O.IdEliminado,
			   RE.FechaRegistro,
			   TP.TipoPedido,
			   TP.IdTipoPedido
        FROM MM_SolicitudPedido AS SP
            INNER JOIN MM_TipoSolicitudPedido AS TSP
                ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
            INNER JOIN TA_Operacion AS O
                ON O.IdDocumento = SP.IdSolicitudPedido                  
            LEFT JOIN TA_Vencimiento AS V
                ON V.IdVencimiento = O.IdVigencia
            LEFT JOIN TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion
            LEFT JOIN MM_PeticionOferta AS PO
                ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=O.IdEliminado
			LEFT JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido=SP.IdTipoProceso
        WHERE O.FechaFinalizacion IS NOT NULL               
			  AND SP.IdProveedor = @IDPROVEEDOR 
			  AND ISNULL(O.IdEstatusEliminado,0)=1   
			  AND O.IdTipoOperacion =6          
        GROUP BY SP.IdSolicitudPedido,
                 TSP.TipoSolicitudPedido,
                 O.Descripcion,
                 O.FechaRegistro,
                 O.FechaFinalizacion,
				 O.IdEstatusEliminado,
				 O.IdEliminado,
			     RE.FechaRegistro,
				 TP.TipoPedido,
				 TP.IdTipoPedido
        ORDER BY SP.IdSolicitudPedido DESC

 
	END 

	/*BUSCAR TOLAS LOS PEDIDOS CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'PEDIDO'  
	BEGIN 
		SELECT P.IdPedido,
			P.IdSolicitudPedido,
			P.CreadoEl AS CreadoEl, 
			P.FechaEnvioPedido AS FechaEnvioPedido,
			SUM(PD.Subtotal) AS TotalPedido,
			ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'') AS Proveedor,
			CASE 
			WHEN P.RecepcionServicio = 1 THEN 'Confirmación Aceptada' 
			WHEN P.RecepcionServicio  = 0 THEN 'Confirmación Rechazada' 
			WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  >= 0 AND O.IdEstatusOperacion = 2 THEN	
					'Confirmación Vencida '  
			WHEN P.RecepcionServicio  IS NULL AND (DATEDIFF(MINUTE,HV.FechaVigencia, GETDATE()))  <= 0 AND O.IdEstatusOperacion = 2 THEN	
					'En Confirmación'  
			ELSE 	  
					'Confirmación No Iniciada ' 
			END AS RecepcionServicio,
			E.Nombre,			 
			CAST(P.Version as NVARCHAR(200)) AS Version ,
			TM.TipoMonedaCorto AS TipoMoneda,
			PG.IdPedido AS IdPedidoGeneral,
			TP.TipoPedido,
			TP.IdTipoPedido,
			P.IdEliminado,
			RE.FechaRegistro
		FROM MM_Pedido AS P
		INNER JOIN MM_PedidoDetalle AS PD ON PD.IdPedido = P.IdPedido
		INNER JOIN MM_PeticionOferta AS PO ON PO.IdPeticionOFerta = P.IdPeticionOferta
		INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista
		INNER JOIN TA_Operacion AS O ON O.IdDocumento = P.IdSolicitudPedido
		INNER JOIN TA_Prioridad AS PR ON PR.IdPrioridad = O.IdPrioridad
		INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = O.IdVigencia
		INNER JOIN TA_TipoOperacion AS TTO ON TTO.IdTipoOperacion= O.IdTipoOperacion
		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN MM_HorasVigenciaPedido AS HV ON P.IdPedido = HV.IdPedido
		LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda = P.IdMoneda			
		INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IDPROVEEDOR
		LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=P.IdEliminado
		WHERE O.IdTipoOperacion = 9 
		AND O.IdProveedor = @IDPROVEEDOR					 
		AND P.Version=O.NoVersion
		AND ISNULL(P.IdEstatusEliminado,0)=1
		GROUP BY P.IdPedido, P.IdSolicitudPedido, P.FechaEnvioPedido, RazonSocial,RegimenCapital, P.RecepcionServicio,  E.Nombre,P.Version,TM.TipoMonedaCorto,HV.FechaVigencia, O.IdEstatusOperacion,P.CreadoEl,PG.IdPedido,TP.TipoPedido,TP.IdTipoPedido,P.IdEstatusEliminado, P.IdEliminado,RE.FechaRegistro
		ORDER BY PG.IdPedido DESC
	END 


	/*BUSCAR TOLAS LAS ACEPTACIONES PEDIDO CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'ACEPTACION_PEDIDO'  
	BEGIN 
		
         SELECT 
                AP.IdAceptacionPedido,
                AP.IdPedido,				
				AP.Comentario,
                AP.Creado,
				CONCAT(LE.[Calle],' ',LE.[NoExterior],' ',LE.[NoInterior],' ',LE.[Colonia],' ',LE.[Municipio],' ',LE.[Estado], ' ', PAIS.Pais) AS LugarEntrega,
               	TD.TipoDomicilio ,
				CONCAT(P.RazonSocial,' ', P.RegimenCapital) As Proveedor,
				PG.IdPedido AS IdPedidoGeneral,
				TP.TipoPedido,
				MP.IdSolicitudPedido,
				AP.IdEliminado,
				RE.FechaRegistro
         FROM MM_AceptacionPedido AS AP
		 INNER JOIN MM_Pedido AS MP ON MP.IdPedido = AP.IdPedido
		 INNER JOIN DG_Domicilio AS LE ON LE.IdDomicilio = AP.IdDomicilioEntrega
		 INNER JOIN DG_TipoDomicilio AS  TD ON TD.IdTipoDomicilio = LE.IdTipoDomicilio
		 INNER JOIN PV_PaisRepublica AS PAIS ON PAIS.id = LE.IdPais
		 INNER JOIN S_Proveedor AS P ON P.IdProveedor =  MP.IdSubcontratista
		 INNER JOIN MM_Pedidos AS PG ON MP.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
		 LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		 LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=AP.IdEliminado
         WHERE AP.IdProveedor = @IdProveedor	
		 AND ISNULL(AP.IdEstatusEliminado,0) = 1 --> MOSTRAR ACEPTACIONES ELIMINADAS	 
		 ORDER BY IdAceptacionPedido DESC
	END 

	/*BUSCAR TOLAS LAS CARTA CN CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'CARTA_CONTENIDO'  
	BEGIN 
		
		SELECT AC.IdAceptacionCartaPCN, Ac.IdAceptacionPedido, AP.IdPedido, AC.IdDocumento, Ac.CreadoEl,
		CONCAT(PR.RazonSocial ,' ', ISNULL(PR.RegimenCapital,'')) AS Proveedor,
		TD.TipoValidacion,
		PG.IdPedido AS IdPedidoGeneral,
		TP.TipoPedido,
		P.IdSolicitudPedido,
		AC.IdEliminado,
		RE.FechaRegistro
		FROM [dbo].[MM_AceptacionCartaPCN] AS AC
		INNER JOIN [dbo].[S_Documento_S3] AS D ON D.IdDocumento = AC.IdDocumento
		INNER JOIN [dbo].[MM_AceptacionPedido] AS AP ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
		INNER JOIN [dbo].[MM_Pedido] AS P ON P.IdPedido = AP.IdPedido
		INNER JOIN [dbo].[S_Proveedor] AS PR ON PR.IdProveedor = P.IdSubcontratista
		INNER JOIN [dbo].[S_TipoValidacionDoc] AS TD ON TD.IdTipoValidacionDoc = AC.IdEstatus
		INNER JOIN [dbo].[MM_Pedidos] AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
	    LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=AC.IdEliminado
		WHERE  P.IdProveedorCompras = @IdProveedor
		AND ISNULL(AC.IdEstatusEliminado,0) = 1  --> QUE ESTEN ELIMINADOS
		ORDER BY  Ac.IdAceptacionPedido desc

	END 

	/*BUSCAR TOLAS APROBACION_FACTURA CON UN ESTATUS DE ELIMINACIÓN = 1*/
	IF @ACCION = 'APROBACION_FACTURA'  
	BEGIN 
		SELECT AF.IdAceptacionPedido,
		Pe.IdPedido,
		O.FechaRegistro, 
		PR.RazonSocial+' '+ISNULL(Pr.RegimenCapital,'') As Proveedor, 
		E.Nombre,
		PG.IdPedido AS IdPedidoGeneral, 
		TP.TipoPedido, 
		SUM((APD.Cantidad+APD.Excedente) * PED.PrecioUnitario) AS TotalPedido,
		TM.TipoMonedaCorto AS Moneda, 
		PR.RFC,
		PE.IdSolicitudPedido,
		AF.IdEliminado,
		RE.FechaRegistro
		FROM MM_AceptacionFactura AS AF
		INNER JOIN  TA_Operacion AS O ON O.IdDocumento = AF.IdAceptacionFactura 	
		INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion 
		INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		INNER JOIN dbo.MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido=AP.IdAceptacionPedido
		INNER JOIN MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido
		INNER JOIN MM_PedidoDetalle AS PED ON PED.IdPedido = PE.IdPedido AND APD.IdPedidoDetalle=PED.IdPedidoDetalle 		 
		INNER JOIN MM_Pedidos AS PG ON PE.IdPedido = PG.IdIdentificador  AND PG.IdProveedorCliente = @IDPROVEEDOR
		INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = PE.IdSubcontratista
		INNER JOIN dbo.PV_TipoMoneda AS TM ON TM.IdMoneda=PE.IdMoneda
		LEFT  JOIN dbo.MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
		LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=AF.IdEliminado
		WHERE
		 O.IdTipoOperacion = 10 --> APROBACIÓN DE FACTURA
		 AND PE.IdProveedorCompras= @IDPROVEEDOR 
		 AND ISNULL(AF.IdEstatusEliminado,0)=1
	    GROUP BY 
		AF.IdAceptacionPedido,
		Pe.IdPedido, 
		O.FechaRegistro, 
		PR.RazonSocial,
		Pr.RegimenCapital, 
		E.Nombre,
		PG.IdPedido, 
		TP.TipoPedido,
		TM.TipoMonedaCorto, 
		PR.RFC,AF.IdEstatusEliminado,
		PE.IdSolicitudPedido,
		AF.IdEliminado,
		RE.FechaRegistro
		ORDER BY AF.IdAceptacionPedido DESC	
	END 

	IF @ACCION = 'APROBACION_PEDIMENTO'  
	BEGIN 
		SELECT 
		AP.IdAceptacionPedido,
        AP.IdPedido,
        AP.Creado AS CreadoEl,
        AP.NombreUsuarioEntrega,
        CONCAT(ISNULL(PR.RazonSocial, ''), ' ', ISNULL(PR.RegimenCapital, '')) AS Proveedor,
        PG.IdPedido AS IdPedidoGeneral,
        TP.IdTipoPedido,
        PC.IdPedimentoComprobante,
        TP.TipoPedido ,
		CASE WHEN PC.CvTipoDocFacturacion = 2 THEN 
			'Pedimento de importación'
			WHEN pc.CvTipoDocFacturacion = 3 THEN 
			'Comprobante Extranjero'
			END  AS TipoDocumentoFacturacion,
		O.IdOperacion,		 
		E.Nombre AS Estatus,
		P.IdSolicitudPedido,
		PC.IdEliminado,
		RE.FechaRegistro
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
				ON PR.IdProveedor= P.IdSubcontratista 
		 INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC 
			ON APC.IdAceptacionPedido=AP.IdAceptacionPedido
		 INNER JOIN dbo.FI_PedimentoComprobante PC 
			ON PC.IdPedimentoComprobante=APC.IdPedimentoComprobante
		 INNER JOIN dbo.TA_Operacion O 
			ON O.IdDocumento=PC.IdPedimentoComprobante AND O.IdTipoOperacion=16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
		 LEFT JOIN dbo.TA_Estatus AS E
                ON E.IdEstatus = O.IdEstatusOperacion	
		 LEFT JOIN dbo.AD_RegistroEliminacion RE ON RE.IdEliminacion=Pc.IdEliminado	 
		 WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
		 AND ISNULL(PC.IdEstatusEliminado,0)= 1 --> NO MOSTRAR SOLICITUDES DE COMPROBANTE CON ESTATUS DE ELIMINADO = 1		
		 AND P.IdProveedorCompras=@IdProveedor					 
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
				 PC.CvTipoDocFacturacion,
				 O.IdOperacion,
				 PC.IdEstatusEliminado,
				 P.IdSolicitudPedido,
				 PC.IdEliminado,
				 RE.FechaRegistro
				ORDER BY AP.IdAceptacionPedido DESC;
	END 

	IF @ACCION = 'APROBACION_PEDIDO'  
	BEGIN 
		SELECT O.IdOperacion,
           O.IdDocumento,
           O.FechaRegistro,
           O.Descripcion,
		   E.Nombre,
           P.Version,
           getdate() AS  FechaVigencia
		FROM TA_Operacion AS O
			LEFT JOIN MM_Pedido AS P
				ON P.IdSolicitudPedido = O.IdDocumento
			LEFT JOIN dbo.MM_SolicitudPedido SP ON 
			 SP.IdSolicitudPedido = P.IdSolicitudPedido       
			LEFT JOIN TA_Estatus AS E
				ON E.IdEstatus = O.IdEstatusOperacion
			LEFT JOIN TA_Tarea AS T
				ON T.IdOperacion = O.IdOperacion	
			LEFT JOIN dbo.S_Usuario U ON u.IdUsuario=T.IdAprobador
			LEFT JOIN dbo.S_UsuarioProveedor UP ON UP.IdUsuario=U.IdUsuario
			AND UP.IdProveedor = O.IdProveedor 
		WHERE     
			  O.IdProveedor=@IdProveedor
			  AND O.IdTipoOperacion = 9
			  AND P.Version = O.NoVersion
			  AND ISNULL(O.IdEstatusEliminado,0) =1  -->APROBACIÓN NO ESTE ELIMINADO
		GROUP BY O.IdOperacion,
				 O.IdDocumento,
				 O.FechaRegistro,
				 O.Descripcion,
				 E.Nombre,
				 O.IdTipoOperacion,
				 P.Version,
				 O.IdEstatusEliminado          
		ORDER BY O.FechaRegistro DESC
	END 
	IF @ACCION='APROBACION_SOLICITUDPEDIDO'
	BEGIN 
		    SELECT O.IdOperacion,
           O.IdDocumento,
           O.FechaRegistro,
           O.Descripcion,           
		   E.Nombre AS Nombre
			FROM TA_Operacion AS O
			INNER JOIN TA_TipoOperacion AS OT
			ON OT.IdTipoOperacion = O.IdTipoOperacion
			INNER JOIN TA_Estatus AS E
			ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN TA_TareaOperacion AS TTO
			ON TTO.IdOperacion = O.IdOperacion
			INNER JOIN TA_Tarea AS T
			ON T.IdTarea = TTO.IdTarea
			WHERE 
			O.IdTipoOperacion = 2
			AND O.IdProveedor = @IdProveedor
			AND ISNULL(O.IdEstatusEliminado, 0) = 1  --> MOSTRAR NO ELIMINADAS 
			GROUP BY O.IdOperacion,
			O.IdDocumento,
			O.FechaRegistro,
			O.Descripcion,
			E.Nombre,
			O.IdEstatusEliminado
			ORDER BY O.FechaRegistro DESC;

	END 
END 

