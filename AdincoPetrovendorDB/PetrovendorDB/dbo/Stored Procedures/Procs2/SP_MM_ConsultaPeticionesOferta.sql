
-- =============================================
-- Author: Pedro Acuña
-- Update date: 28/08/2018
-- Description: se agrega en el grid de todos el campo de idtipoproceso para identificar a donde se va a redirigir la oferta
-- ademas se agrega el retorno de si fue cotizada, quienes son los proveedores que cotizaron, cual es su vencimiento, cuales son los pedidos?,
-- estatus del pedido, instalacion y cuales son los materiales
-- =============================================
-- =============================================
-- Author: Alexander Gomez
-- Update date: 10/09/2019
-- Description: Se valida que exista una peticion oferta para mostrar los botones de la peticion oferta
-- =============================================
-- Author: Daniel AC
-- Update date: 20/11/2019
-- Description: Se agregaron filtros para que el usuario actual solo puede ver las ofertas que le fueron asingadas o si es usuario admini o adminin de compras puede ver todas y se agrego
-- Consulta 5 para mostrar las peticiones de oferta que no tiene un comprador asignado 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPeticionesOferta] --420,3,4,'2019-08-26','2019-09-10'
	@IdProveedor INT,
	@Consulta INT, 
	@IdTipoProceso INT ,
	@FechaDesde DATE, 
	@FechaHasta DATE,
	@IdUsuario INT =	NULL
AS
	BEGIN
		SET NOCOUNT ON
		DECLARE @EsAdministradorCompras BIT =0
		DECLARE @EsTipoAdministrador BIT = 0
		DECLARE @EsAdministrador BIT =0

		--CONSULTAR SI EL USUARIO ACTUAL ES ADMINISTRADOR DE COMPRAS
		SELECT  @EsAdministradorCompras=Activo
		FROM dbo.CC_AdministradorCompras 
		WHERE IdUsuario=@IdUsuario 
		AND Activo=1
		AND IdProveedor=@IdProveedor
		
		--CONSULTAR SI EL USUARIO ACTUAL ES USUARIO DE TIPO ADMINISTRADOR 
		SELECT @EsTipoAdministrador= CASE WHEN COUNT(1)> 0 THEN 1 ELSE 0 END
		FROM dbo.S_Usuario U 
		WHERE U.IdTipoUsuario IN (3,4,6,7,8)  --> CTES Administrador,Ventas,finanzas,Director General,Root
		AND U.IdUsuario=@IdUsuario

		--SI CUMPLE ALGUNO DE ESTOS PARAMETROS ES UN ADMINISTRADOR Y PUEDE VER TODAS LAS PETICIONES DE SOL OFERTA
		-- SI NO SOLO PODRÁ VER LAS SOL OFERTA DONDE FUE ASIGNADO
		IF @EsTipoAdministrador=1 OR @EsAdministradorCompras =1
		BEGIN
         SET @EsAdministrador =1
		END 

		CREATE TABLE #CompradoresAsignados(IdSolicitudPedido INT, Compradores NVARCHAR(MAX))
		
		IF @Consulta = 3  --> OBTENER EL NOMBRE DE LOS COMPRODORES ASIGNADOS
		
		BEGIN  
			INSERT INTO #CompradoresAsignados
			SELECT SP.IdSolicitudPedido, 
			(SELECT	STUFF ((SELECT CAST(', ' AS VARCHAR(MAX)) +  ISNULL(U.Nombre,'') +ISNULL('('+TU.NombreTipoUsuario+')','')
			FROM dbo.MM_SolicitudPedidoComprador SPC 	
			INNER JOIN dbo.S_Usuario U ON U.IdUsuario=SPC.IdAsignadoA
			LEFT JOIN dbo.S_TipoUsuario TU ON TU.IdTipoUsuario = U.IdTipoUsuario	
			WHERE 		
			SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
			AND SPC.Activo=1
			ORDER BY U.Nombre ASC
			FOR XML PATH ( '' )), 1, 1, '' ))
			FROM dbo.MM_SolicitudPedido SP
			WHERE 
			SP.IdProveedor = @IdProveedor
			AND SP.FechaAlta BETWEEN ''
				AND	 DATEADD ( DAY, 1, @FechaHasta )
		END 
		ELSE 
		BEGIN 
			INSERT INTO #CompradoresAsignados

			SELECT SP.IdSolicitudPedido, 
			(SELECT	STUFF ((SELECT CAST(' ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA )
			FROM dbo.MM_SolicitudPedidoComprador SPC 		
			WHERE 		
			SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
			AND SPC.Activo=1
			FOR XML PATH ( '' )), 1, 1, '' ))
			FROM dbo.MM_SolicitudPedido SP
			WHERE 
			SP.IdProveedor = @IdProveedor
			AND SP.FechaAlta BETWEEN ''
				AND	 DATEADD ( DAY, 1, @FechaHasta )
		END 
			
		
		---- OT.IdEstatusOperacion= 2 ---> Aprobada por aprobadores internos
		----  OT.IdTipoOperacion=2 ---> Tipo de operación Solicitud de pedido
		---- PeticionEnviada Cuando la Solicitud de pedido es enviada a una petición de oferta con sus respectivos proveedores de ventas
		IF @Consulta = 1  --> MOSTRAR LAS NO ENVIADAS 
			BEGIN
				SELECT		SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							( CASE SP.UnaSolaEntregaRequerida
							  WHEN 1 THEN
								  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 )
							  WHEN 0 THEN
								  CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 ), ' -- ' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 103 ))
							  END ) AS FechaEntrega, U.Nombre, ISNULL ( SP.IdTipoProceso, 0 ) AS IdTipoProceso,
							  ISNULL(CA.Compradores,'') AS IdAsignado,
							  SP.ComentarioInternoPO,
							  ISNULL(@EsAdministrador,0) AS EsAdministrador
				FROM		MM_SolicitudPedido AS SP
				INNER JOIN	MM_TipoSolicitudPedido AS TSP
					ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
				INNER JOIN	MM_PrioridadSolicitudPedido AS PSP
					ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
				INNER JOIN	TA_Operacion AS OT
					ON OT.IdDocumento = SP.IdSolicitudPedido
				INNER JOIN	S_Usuario AS U
					ON U.IdUsuario = OT.IdAsignador
				LEFT JOIN dbo.MM_SolicitudPedidoComprador SPC 
					ON SPC.IdSolicitudPedido = SP.IdSolicitudPedido		
				LEFT JOIN #CompradoresAsignados CA ON CA.IdSolicitudPedido = SP.IdSolicitudPedido		
				WHERE
							SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND SP.Activo = 1
							AND OT.IdTipoOperacion = 2
							AND
								(	SP.PeticionEnviada = 0
									OR		SP.PeticionEnviada IS NULL )
							--AND ( SP.IdTipoProceso IS NULL )
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGGA ESTATUS ELIMINADO
							AND SP.FechaAlta BETWEEN @FechaDesde
											 AND	 DATEADD ( DAY, 1, @FechaHasta )
				AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.IdTipoProceso,SP.Asignado,
							SP.ComentarioInternoPO,
							CA.Compradores
				ORDER BY	SP.IdSolicitudPedido DESC
			END

		IF @Consulta = 2  --> MOSTRAR LAS ENVIADAS
			BEGIN
				SELECT		SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							(CASE SP.UnaSolaEntregaRequerida
							  WHEN 1 THEN
								  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 )
							  WHEN 0 THEN
								  CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 ), ' -- ' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 103 ))
							  END) AS FechaEntrega, U.Nombre, ISNULL ( SP.IdTipoProceso, 0 ) AS IdTipoProceso,
							  ISNULL(CA.Compradores,'') AS IdAsignado,
							  SP.ComentarioInternoPO,
							  ISNULL(@EsAdministrador,0) AS EsAdministrador
				FROM		MM_SolicitudPedido AS SP
				INNER JOIN	MM_TipoSolicitudPedido AS TSP
					ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
				INNER JOIN	MM_PrioridadSolicitudPedido AS PSP
					ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
				INNER JOIN	TA_Operacion AS OT
					ON OT.IdDocumento = SP.IdSolicitudPedido
				INNER JOIN	S_Usuario AS U
					ON U.IdUsuario = OT.IdAsignador
				LEFT JOIN dbo.MM_SolicitudPedidoComprador SPC 
					ON SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
				LEFT JOIN #CompradoresAsignados CA ON CA.IdSolicitudPedido = SP.IdSolicitudPedido	
				WHERE
							SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND
								(	SP.PeticionEnviada = 1
									OR		SP.PeticionEnviada IS NOT NULL )
							AND ( SP.IdTipoProceso = @IdTipoProceso )
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGGA ESTATUS ELIMINADO
							AND SP.FechaAlta BETWEEN @FechaDesde
											 AND	 DATEADD ( DAY, 1, @FechaHasta )
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, SP.FechaAlta, SP.UnaSolaEntregaRequerida ,
							SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre, SP.IdTipoProceso ,
							TSP.TipoSolicitudPedido, PSP.Prioridad,SP.Asignado,
							SP.ComentarioInternoPO,
							CA.Compradores
				ORDER BY	SP.IdSolicitudPedido DESC
			END

		IF @Consulta = 3  --> MOSTRAR TODAS 
			BEGIN
				
				SELECT		SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							( CASE SP.UnaSolaEntregaRequerida
							  WHEN 1 THEN
								  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 )
							  WHEN 0 THEN
								  CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 ), ' -- ' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 103 ))
							  END ) AS FechaEntrega, U.Nombre, CASE WHEN SP.PeticionEnviada = 1 THEN
																		'Enviada'
															   WHEN SP.PeticionEnviada IS NULL THEN
																   'Pendiente de Enviar'
															   END AS EstatusOferta ,
							ISNULL ( SP.IdTipoProceso, 0 ) AS IdTipoProceso ,
							ISNULL ( TP.TipoPedido, 'Sin clasificación' ) AS NombreTipo, TP.IdTipoPedido ,
							CASE WHEN ( SUM ( CASE WHEN PO.NoCotizar = 1 THEN
													   1
											  ELSE
												  CASE WHEN PO.Cotizado = 1 THEN 1 ELSE 0 END
											  END )) > 0 THEN
									 'Cotizado'
							ELSE
								'No Cotizado'
							END AS Cotizado ,
							dbo.Fn_ObtenerFechaFinalizacionCotizacionPorSolPed ( SP.IdSolicitudPedido, @IdProveedor ) AS FechaFinalizacion ,
							dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones ,
							CASE WHEN ( SUM ( CASE WHEN PO.NoCotizar = 1 THEN
													   1
											  ELSE
												  CASE WHEN PO.Cotizado = 1 THEN 1 ELSE 0 END
											  END )) > 0 THEN
									 'icon-yes fa fa-check-circle'
							ELSE
								'icon-no fa fa-times-circle'
							END AS CotizadoIcon, CASE WHEN SP.PeticionEnviada = 1 THEN
														  'icon-yes fa fa-check-circle'
												 WHEN SP.PeticionEnviada IS NULL THEN
													 'icon-exclamation fa fa-exclamation-circle'
												 END AS EstatusOfertaIcon ,
							dbo.Fn_ObtenerPedidosPorSolPedRetornoHtml ( SP.IdSolicitudPedido, @IdProveedor ) AS html ,
							CASE WHEN dbo.Fn_ObtenerFechaFinalizacionCotizacionPorSolPed (
										  SP.IdSolicitudPedido, @IdProveedor ) > GETDATE () THEN
									 'label label-success'
							WHEN dbo.Fn_ObtenerFechaFinalizacionCotizacionPorSolPed ( SP.IdSolicitudPedido, @IdProveedor ) < GETDATE () THEN
								'label label-danger'
							ELSE
								''
							END AS EtiqVenc, 
							CASE 
								WHEN ISNULL((SELECT COUNT(IdPeticionOferta) FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido),0) = 0 THEN 'hidden' 
							END AS mostrarLink ,
							dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) AS Proveedores ,
							CASE WHEN dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) IS NULL THEN
									 'hidden'
							END AS mostrarProveedor, CASE WHEN NOT EXISTS
			(	SELECT	1
				FROM	dbo.MM_Pedido
				WHERE
						IdSolicitudPedido = SP.IdSolicitudPedido
						AND ISNULL ( IdEstatusEliminado, 0 ) = 0 ) THEN
															  'hidden'
													 END AS ocultarBoton, CASE WHEN SP.IdTipoProceso IS NULL THEN
																				   'icon-no fa fa-times-circle'
																		  WHEN SP.IdTipoProceso = 2 THEN
																			  'fa-m'
																		  WHEN SP.IdTipoProceso = 4 THEN
																			  'fa-ad'
																		  END AS iconoTipoProceso ,
							CASE WHEN SP.IdTipoProceso IS NULL THEN '' ELSE 'badge' END AS badgeIcon,
							'<button class=''btn btn-default btn-small'' onclick=''irSolicitudOferta('+ LTRIM(SP.IdSolicitudPedido) + ', ' + ISNULL(LTRIM(TP.IdTipoPedido), 0) +')''><strong>Ir a la Solicitud de Oferta</strong></button>' AS idSolicitudOferta,
							'<button class=''btn btn-default btn-small'' onclick=''irOferta('+ LTRIM(SP.IdSolicitudPedido) +', ' + ISNULL(LTRIM(TP.IdTipoPedido), 0)  +')''><strong>Ir a la Oferta</strong></button>' AS irOferta,
							CASE WHEN LEN(CA.Compradores)>0 THEN 
								CA.Compradores
							ELSE 
								'Sin asignar'
							END  AS Asignados
				FROM		MM_SolicitudPedido AS SP
				INNER JOIN	MM_TipoSolicitudPedido AS TSP
					ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
				INNER JOIN	MM_PrioridadSolicitudPedido AS PSP
					ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
				INNER JOIN	TA_Operacion AS OT
					ON OT.IdDocumento = SP.IdSolicitudPedido
				INNER JOIN	S_Usuario AS U
					ON U.IdUsuario = OT.IdAsignador
				LEFT JOIN	dbo.MM_TipoPedido TP
					ON TP.IdTipoPedido = SP.IdTipoProceso
				LEFT JOIN	MM_PeticionOferta AS PO
					ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
				LEFT JOIN dbo.MM_SolicitudPedidoComprador SPC 
					ON SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
				LEFT JOIN #CompradoresAsignados CA ON CA.IdSolicitudPedido = SP.IdSolicitudPedido
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND SP.FechaAlta BETWEEN @FechaDesde
							AND	 DATEADD ( DAY, 1, @FechaHasta )
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado, TP.IdTipoPedido,CA.Compradores
				ORDER BY	SP.IdSolicitudPedido DESC
			END

		IF @Consulta = 4  --> MOSTRAR TODAS SIN COMPRADOR ASIGNADO
			BEGIN
				
				SELECT		SP.IdSolicitudPedido, 
							SP.MotivoUrgencia, 
							TSP.TipoSolicitudPedido, 
							PSP.Prioridad, 
							SP.FechaAlta ,
							(CASE SP.UnaSolaEntregaRequerida
							  WHEN 1 THEN
								  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 )
							  WHEN 0 THEN
								  CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 103 ), ' -- ' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 103 ))
							  END) AS FechaEntrega, 
							U.Nombre, 
							ISNULL ( SP.IdTipoProceso, 0 ) AS IdTipoProceso,
							ISNULL(CA.Compradores,'') AS IdAsignado,
							SP.ComentarioInternoPO,
							  ISNULL(@EsAdministrador,0) AS EsAdministrador,
							CASE WHEN SP.PeticionEnviada = 1 THEN
									'Enviada'
							WHEN SP.PeticionEnviada IS NULL THEN
								'Pendiente de Enviar'
							END AS EstatusOferta,
							ISNULL ( TP.TipoPedido, 'Sin clasificación' ) AS NombreTipo
				FROM		MM_SolicitudPedido AS SP
				INNER JOIN	MM_TipoSolicitudPedido AS TSP
					ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
				INNER JOIN	MM_PrioridadSolicitudPedido AS PSP
					ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
				INNER JOIN	TA_Operacion AS OT
					ON OT.IdDocumento = SP.IdSolicitudPedido
				INNER JOIN	S_Usuario AS U
					ON U.IdUsuario = OT.IdAsignador
				LEFT JOIN	dbo.MM_TipoPedido TP
					ON TP.IdTipoPedido = SP.IdTipoProceso
				LEFT JOIN	MM_PeticionOferta AS PO
					ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
				LEFT JOIN dbo.MM_SolicitudPedidoComprador SPC 
					ON SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
				LEFT JOIN #CompradoresAsignados CA ON CA.IdSolicitudPedido = SP.IdSolicitudPedido
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND SP.FechaAlta BETWEEN @FechaDesde
							AND	 DATEADD ( DAY, 1, @FechaHasta )
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1
						AND LEN(RTRIM((LTRIM(ISNULL(CA.Compradores,'')))))=0	--> SI NO TIENE COMPRADORES ASIGNADOS 						 
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado, TP.IdTipoPedido,CA.Compradores,
							SP.ComentarioInternoPO
				ORDER BY	SP.IdSolicitudPedido DESC
			END
	END

