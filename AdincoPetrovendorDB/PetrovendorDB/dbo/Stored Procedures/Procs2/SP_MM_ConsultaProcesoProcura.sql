
-- =============================================
-- Author:	DANIEL AC
-- Create date: 08/03/2018
-- Description: CONSULTAR PROCESO DE PROCURA PARA POSIBLE ELIMINACIÓN
-- =============================================


CREATE PROCEDURE [dbo].[SP_MM_ConsultaProcesoProcura] 

 @IdSolicitudPedido INT,
 @IdProveedor INT, 
 @IdContrato INT,
 @IdPedido INT = 0,
 @IdAceptacionPedido INT = 0,
 @Proceso NVARCHAR(100) ='SOLICITUD_PEDIDO'
 
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	
	---DROP TABLE #PROCESO
	/*CREACIÓN DE TABLA QUE LLEVARA LA JERARQUIA DE LOS PROCESOS DE PROCURA*/
	CREATE TABLE #PROCESO(ID INT IDENTITY(1,1),ID_PADRE INT, PROCESO NVARCHAR(500),ESTATUS NVARCHAR(500), CLASS NVARCHAR(300), CLAVE_PROCESO NVARCHAR(200), ACCION_EJECUTAR NVARCHAR(300), ID_PROCESO INT, ID_PROCESO_PUBLICO INT)
	
	
	/*INICIO BUSQUEDA DE SOLICITUD DE PEDIDO*/
	IF @Proceso='SOLICITUD_PEDIDO'
	BEGIN 
		/*VALIDAR QUE SOLICITUD PERTENEZCA AL PROVEEDOR*/
		DECLARE @SOLICITUD_VALIDA INT 
		SELECT @SOLICITUD_VALIDA = COUNT(IdSolicitudPedido) FROM dbo.MM_SolicitudPedido WHERE IdProveedor=@IdProveedor AND IdSolicitudPedido=@IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) <> 1
		IF @SOLICITUD_VALIDA > 0 
			BEGIN 
		
				/*BUSQUEDA DE SOLICITUD DE PEDIDO*/
				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO, ID_PROCESO_PUBLICO)	
				SELECT 
				0,
				CONCAT('Solicitud de pedido No.', IdSolicitudPedido),
				'',
				'operacion btn btn-mini btn-info   no-border',
				'solicitudpedido',
				'<i class="fa fa-trash-o"></i> Eliminar', 
				IdSolicitudPedido,
				IdSolicitudPedido 
				FROM dbo.MM_SolicitudPedido 
				WHERE IdSolicitudPedido=@IdSolicitudPedido
				AND ISNULL(IdEstatusEliminado,0) <> 1
	
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
				WHERE IdSolicitudPedido=@IdSolicitudPedido AND O.IdTipoOperacion=2 -->APROBACIÓN DE SOLICITUD DE PEDIDO
				AND ISNULL(SP.IdEstatusEliminado,0)<>1

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
				WHERE IdSolicitudPedido=@IdSolicitudPedido 
				AND O.IdTipoOperacion=2 --> APROBACIÓN DE SOLICITUD DE PEDIDO
				AND O.IdEstatusOperacion=2 --> APROBADA
				AND ISNULL(SP.IdEstatusEliminado,0)<>1

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
				WHERE IdSolicitudPedido=@IdSolicitudPedido 
				AND O.IdTipoOperacion=6 -->ENVIO PROCESO DE COTIZACIÓN
				AND ISNULL(SP.IdEstatusEliminado,0)<>1

				/*BUSQUEDA DE APROBACIONES DE PEDIDO*/
				/*CONTAR CANTIDAD DE APROBACIONES DE PEDIDO*/
				DECLARE @CANTIDAD_APROBACIONES INT = 0 
				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO)
				SELECT 4, CONCAT('Aprobación de pedido No. Operación ', o.IdOperacion),CONCAT('<i class="fa fa-tag text-warning"></i> ',E.Nombre),'','aprobacionpedido','', o.IdOperacion FROM dbo.MM_SolicitudPedido AS SP
				INNER JOIN dbo.TA_Operacion AS O ON O.IdDocumento= SP.IdSolicitudPedido
				INNER JOIN dbo.TA_Estatus AS E ON E.IdEstatus=o.IdEstatusOperacion
				WHERE IdSolicitudPedido=@IdSolicitudPedido
				AND O.IdTipoOperacion=9 --> APROBACIÓN DE PEDIDO
				ORDER BY O.IdOperacion ASC
								
				/*CONSULTA DE PEDIDO DE LAS APROBACIONES CORRESPONDIENTES*/
				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
				SELECT 	
				TEM.ID,
				CONCAT('Pedido ', PG.IdPedido),
				'<span class="text-black">' +(PV.Razonsocial + ' '+ISNULL(PV.RegimenCapital,''))+'</span>',
				'operacion btn btn-mini btn-info    no-border',
				'pedido',
				'<i class="fa fa-trash-o"></i> Eliminar', 
				P.IdPedido,
				PG.IdPedido
				FROM TA_Operacion AS O
				INNER JOIN MM_Pedido AS P ON O.IdDocumento = P.IdSolicitudPedido
				INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista		
				INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
				LEFT JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda
				INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
				INNER JOIN #PROCESO AS TEM ON TEM.ID_PROCESO=O.IdOperacion 
				LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
				WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				 AND O.IdProveedor = @IdProveedor 
				 AND P.IdSolicitudPedido = @IdSolicitudPedido  
				 AND O.NoVersion=P.Version
				 AND O.IdOperacion=TEM.ID_PROCESO
				 AND TEM.CLAVE_PROCESO='aprobacionpedido'
				 AND ISNULL(P.IdEstatusEliminado,0)<>1
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
				INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda
				INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor
				INNER JOIN #PROCESO AS TEM ON TEM.ID_PROCESO=O.IdOperacion 
				INNER JOIN #PROCESO AS TEM_PED ON TEM_PED.ID_PROCESO=P.IdPedido 
				LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
				WHERE O.IdTipoOperacion = 9  --> APROBACIÓN DE PEDIDO
				 AND O.IdEstatusOperacion=2 --> APROBADA
				 AND O.IdProveedor = @IdProveedor 
				 AND P.IdSolicitudPedido = @IdSolicitudPedido  
				 AND O.NoVersion=P.Version
				 AND O.IdOperacion=TEM.ID_PROCESO
				 AND TEM.CLAVE_PROCESO='aprobacionpedido'
				 AND TEM_PED.CLAVE_PROCESO='pedido'
				 AND ISNULL(P.IdEstatusEliminado,0) <> 1
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
				'operacion btn btn-mini btn-info   no-border',
				'aceptacionpedido',
				'<i class="fa fa-trash-o"></i> Eliminar',
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
				 AND P.IdSolicitudPedido = @IdSolicitudPedido  
				 AND O.NoVersion=P.Version
				 AND O.IdOperacion=TEM.ID_PROCESO
				 AND TEM.CLAVE_PROCESO='aprobacionpedido'
				 AND TEM_PED.CLAVE_PROCESO='pedido'
				 AND TEM_CS.CLAVE_PROCESO='confirmacionpedido'
				 AND ISNULL(AP.IdEstatusEliminado,0) <> 1				 
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
				 P.IdSolicitudPedido = @IdSolicitudPedido  	
				 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
				 AND ISNULL(AC.IdEstatusEliminado,0)<>1
				 AND ISNULL(AP.IdNacionalidadProveedor, 0) <> 2 --> DIFERENTE DE NACIONALIDAD EXTRANJERO  
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
				 P.IdSolicitudPedido = @IdSolicitudPedido  	
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
				 AND P.IdSolicitudPedido=	@IdSolicitudPedido		 
				 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
				 AND ISNULL(PC.IdEstatusEliminado,0) <> 1

				/*CONSULTA DE ACEPTACIONES DE PEDIDO DE LAS CONFIRMACIONES DE PEDIDO ACEPTADAS Y COMPROBANTE EXTRANJERO SI EL PROVEEDOR ES EXTRANJERO*/
				SELECT * FROM #PROCESO

		END 
		ELSE
			BEGIN
				--CREATE TABLE #PROCESO_VACIO(ID INT IDENTITY(1,1),ID_PADRE INT, PROCESO NVARCHAR(500),ESTATUS NVARCHAR(500), CLASS NVARCHAR(300), CLAVE_PROCESO NVARCHAR(200), ACCION_EJECUTAR NVARCHAR(300), ID_PROCESO INT,ID_PROCESO_PUBLICO INT)
				/*BUSQUEDA DE SOLICITUD DE PEDIDO*/
				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
				VALUES (0,'SOLICITUD DE PEDIDO NO ENCONTRADA', '','','','',0,0)

				SELECT * FROM  #PROCESO
			END 
 
	END 
	/*FIN BUSQUEDA DE SOLICITUD DE PEDIDO*/

	/*INICIO BUSQUEDA DE PEDIDO*/
	IF @Proceso='PEDIDO'
	BEGIN 
		/*VALIDAR QUE SOLICITUD PERTENEZCA AL PROVEEDOR*/
		DECLARE @PEDIDO_VALIDA INT 
		SELECT @PEDIDO_VALIDA = COUNT(IdSolicitudPedido) FROM dbo.MM_Pedido WHERE IdPedido=@IdPedido AND IdProveedorCompras=@IdProveedor AND IdSolicitudPedido=@IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) <> 1
		IF @PEDIDO_VALIDA > 0 
		BEGIN 	
			/*BUSQUEDA DE PEDIDO*/
			
			/*CONSULTA DE PEDIDO DE LAS APROBACIONES CORRESPONDIENTES*/


				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
				SELECT 	
				0,
				CONCAT('Pedido ', PG.IdPedido),
				'<span class="text-black">' +(PV.Razonsocial + ' '+ISNULL(PV.RegimenCapital,''))+'</span>',
				'operacion btn btn-mini btn-info    no-border',
				'pedido',
				'<i class="fa fa-trash-o"></i> Eliminar', 
				P.IdPedido,
				PG.IdPedido
				FROM TA_Operacion AS O
				INNER JOIN MM_Pedido AS P ON O.IdDocumento = P.IdSolicitudPedido
				INNER JOIN S_Proveedor AS PV ON PV.IdProveedor = P.IdSubcontratista		
				INNER JOIN TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
				INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda
				INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor				
				LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
				WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
				 AND O.IdProveedor = @IdProveedor 
				 AND P.IdSolicitudPedido = @IdSolicitudPedido  
				 AND O.NoVersion=P.Version	
				 AND ISNULL(P.IdEstatusEliminado,0)<>1 --> QUE NO ESTE ELIMINADA
				 AND P.IdPedido=@IdPedido
				GROUP BY 
				P.IdPedido,
				PV.Razonsocial,
				PV.RegimenCapital,
				PG.IdPedido


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
				INNER JOIN PV_TipoMoneda AS TM ON TM.IdMoneda= P.IdMoneda
				INNER JOIN MM_Pedidos AS PG ON P.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = @IdProveedor				 
				INNER JOIN #PROCESO AS TEM_PED ON TEM_PED.ID_PROCESO=P.IdPedido 
				LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
				WHERE O.IdTipoOperacion = 9  --> TIPO APROBACIÓN DE PEDIDO
				 AND O.IdEstatusOperacion=2 -->  ESTATUS APROBADA
				 AND O.IdProveedor = @IdProveedor 
				 AND P.IdSolicitudPedido = @IdSolicitudPedido  
				 AND O.NoVersion=P.Version				 		
				 AND TEM_PED.CLAVE_PROCESO='pedido'
				 AND ISNULL(P.IdEstatusEliminado,0) <> 1	--> QUE NO SE ENCUENTRE ELIMINADO			
				GROUP BY 
				P.IdPedido,
				PV.Razonsocial,
				PV.RegimenCapital,
				PG.IdPedido,				
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
				'operacion btn btn-mini btn-info   no-border',
				'aceptacionpedido',
				'<i class="fa fa-trash-o"></i> Eliminar',
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
				INNER JOIN #PROCESO AS TEM_PED ON TEM_PED.ID_PROCESO=P.IdPedido 
				INNER JOIN #PROCESO AS TEM_CS ON TEM_CS.ID_PROCESO=P.IdPedido 
				LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
				WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO APROBADA
				 AND O.IdEstatusOperacion=2 --> APROBADA
				 AND O.IdProveedor = @IdProveedor 
				 AND P.IdSolicitudPedido = @IdSolicitudPedido  
				 AND O.NoVersion=P.Version						
				 AND TEM_PED.CLAVE_PROCESO='pedido'
				 AND TEM_CS.CLAVE_PROCESO='confirmacionpedido'
				 AND ISNULL(AP.IdEstatusEliminado,0) <> 1				
				GROUP BY 
				P.IdPedido,
				PV.Razonsocial,
				PV.RegimenCapital,
				PG.IdPedido,			
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
				 P.IdSolicitudPedido = @IdSolicitudPedido  	
				 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
				 AND ISNULL(AC.IdEstatusEliminado,0)<>1
				 AND ISNULL(AP.IdNacionalidadProveedor, 0) <> 2 --> DIFERENTE DE NACIONALIDAD EXTRANJERO  
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
				 P.IdSolicitudPedido = @IdSolicitudPedido  	
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
				 AND P.IdSolicitudPedido=	@IdSolicitudPedido		 
				 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
				 AND ISNULL(PC.IdEstatusEliminado,0) <> 1



			SELECT * FROM  #PROCESO
		END
		ELSE		
			BEGIN
				--CREATE TABLE #PROCESO_VACIO(ID INT IDENTITY(1,1),ID_PADRE INT, PROCESO NVARCHAR(500),ESTATUS NVARCHAR(500), CLASS NVARCHAR(300), CLAVE_PROCESO NVARCHAR(200), ACCION_EJECUTAR NVARCHAR(300), ID_PROCESO INT,ID_PROCESO_PUBLICO INT)
				/*BUSQUEDA DE PEDIDO*/
				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
				VALUES (0,'PEDIDO NO ENCONTRADO', '','','','',0,0)
				SELECT * FROM  #PROCESO
			END  

	END 


	/*INICIO BUSQUEDA DE PEDIDO*/
	IF @Proceso='ACEPTACION_PEDIDO'
	BEGIN 
		/*VALIDAR QUE SOLICITUD PERTENEZCA AL PROVEEDOR*/
		DECLARE @ACEPTACIONPEDIDO_VALIDA INT 

		SELECT @ACEPTACIONPEDIDO_VALIDA = COUNT(IdAceptacionPedido) 
		FROM dbo.MM_AceptacionPedido AP
		INNER JOIN dbo.MM_Pedido P ON P.IdPedido=AP.IdPedido
		WHERE P.IdPedido=@IdPedido AND P.IdProveedorCompras=@IdProveedor
		AND P.IdSolicitudPedido=@IdSolicitudPedido  
		AND ISNULL(AP.IdEstatusEliminado,0) <> 1 
		AND AP.IdAceptacionPedido=@IdAceptacionPedido

		IF @ACEPTACIONPEDIDO_VALIDA > 0 
		BEGIN 	
			/*BUSQUEDA DE PEDIDO*/			
			/*CONSULTA DE PEDIDO DE LAS APROBACIONES CORRESPONDIENTES*/

	
				/*ACEPTACIONES DE PEDIDO*/ 
				/*CONSULTA DE ACEPTACIONES DE PEDIDO DE LAS CONFIRMACIONES DE PEDIDO ACEPTADAS*/
				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
	 
				SELECT 	
				0,
				CONCAT('Aceptación de servicio No.',AP.IdAceptacionPedido),
				'',
				'operacion btn btn-mini btn-info   no-border',
				'aceptacionpedido',
				'<i class="fa fa-trash-o"></i> Eliminar',
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
				LEFT JOIN  MM_TipoPedido AS TP ON TP.IdTipoPedido = PG.IdTipoPedido
				WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO APROBADA
				 AND O.IdEstatusOperacion=2 --> APROBADA
				 AND O.IdProveedor = @IdProveedor 
				 AND P.IdSolicitudPedido = @IdSolicitudPedido  
				 AND O.NoVersion=P.Version	
				 AND ISNULL(AP.IdEstatusEliminado,0) <> 1
				 AND AP.IdAceptacionPedido=@IdAceptacionPedido
				GROUP BY 
				P.IdPedido,
				PV.Razonsocial,
				PV.RegimenCapital,
				PG.IdPedido,
				P.RecepcionServicio,
				HV.FechaVigencia,
				O.IdEstatusOperacion,
				AP.IdAceptacionPedido				

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
				 P.IdSolicitudPedido = @IdSolicitudPedido  	
				 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
				 AND ISNULL(AC.IdEstatusEliminado,0)<>1
				 AND ISNULL(AP.IdNacionalidadProveedor, 0) <> 2 --> DIFERENTE DE NACIONALIDAD EXTRANJERO  
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
				 P.IdSolicitudPedido = @IdSolicitudPedido  	
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
				 AND P.IdSolicitudPedido=	@IdSolicitudPedido		 
				 AND TEM_AP.CLAVE_PROCESO='aceptacionpedido'
				 AND ISNULL(PC.IdEstatusEliminado,0) <> 1

				 SELECT * FROM  #PROCESO
		END 
		ELSE		
			BEGIN
				--CREATE TABLE #PROCESO_VACIO(ID INT IDENTITY(1,1),ID_PADRE INT, PROCESO NVARCHAR(500),ESTATUS NVARCHAR(500), CLASS NVARCHAR(300), CLAVE_PROCESO NVARCHAR(200), ACCION_EJECUTAR NVARCHAR(300), ID_PROCESO INT,ID_PROCESO_PUBLICO INT)
				/*BUSQUEDA DE PEDIDO*/
				INSERT INTO #PROCESO(ID_PADRE,PROCESO,ESTATUS,CLASS,CLAVE_PROCESO, ACCION_EJECUTAR,ID_PROCESO,ID_PROCESO_PUBLICO)
				VALUES (0,'ACEPTACIÓN DE SERVICIO NO ENCONTRADO', '','','','',0,0)
				SELECT * FROM  #PROCESO
			END  

	END 
END

