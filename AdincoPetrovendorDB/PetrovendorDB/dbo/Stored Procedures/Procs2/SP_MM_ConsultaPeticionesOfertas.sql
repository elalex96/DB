-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <07/02/2020>
-- Description:	<consulta para la pantalla para la solciitud de oferta,
-- consultando por parametros simulando los grids de devexpress(Pendientes de enviar, enviada, todas, etc..)>
-- =============================================
create PROCEDURE [dbo].[SP_MM_ConsultaPeticionesOfertas] --420,7,2205,1,'',2
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@Consulta INT,
	@IdUsuario INT,
	@Page INT,
	@Buscar NVARCHAR(200),
	@IdTipoProceso INT = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @EsAdministradorCompras BIT =0
	DECLARE @EsTipoAdministrador BIT = 0
	DECLARE @EsAdministrador INT =0
	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 5;

		--CONSULTAR SI EL USUARIO ACTUAL ES ADMINISTRADOR DE COMPRAS
	SELECT  
		@EsAdministradorCompras = Activo
	FROM dbo.CC_AdministradorCompras
	WHERE IdUsuario = @IdUsuario 
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
		
		--IF @Consulta = 7  --> OBTENER EL NOMBRE DE LOS COMPRODORES ASIGNADOS
		
		--BEGIN  
		--	INSERT INTO #CompradoresAsignados
		--	SELECT SP.IdSolicitudPedido, 
		--	(SELECT	STUFF ((SELECT CAST(', ' AS VARCHAR(MAX)) +  ISNULL(U.Nombre,'') +ISNULL('('+TU.NombreTipoUsuario+')','') 
		--	FROM dbo.MM_SolicitudPedidoComprador SPC 	
		--	INNER JOIN dbo.S_Usuario U ON U.IdUsuario=SPC.IdAsignadoA
		--	LEFT JOIN dbo.S_TipoUsuario TU ON TU.IdTipoUsuario = U.IdTipoUsuario	
		--	WHERE 		
		--	SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
		--	AND SPC.Activo=1
		--	ORDER BY U.Nombre ASC
		--	FOR XML PATH ( '' )), 1, 1, '' ))
		--	FROM dbo.MM_SolicitudPedido SP
		--	WHERE 
		--	SP.IdProveedor = @IdProveedor
		--END 
		--ELSE 
		--BEGIN 
			INSERT INTO #CompradoresAsignados

			SELECT SP.IdSolicitudPedido, 
			(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA )
			FROM dbo.MM_SolicitudPedidoComprador SPC 
			INNER JOIN dbo.S_Usuario U ON U.IdUsuario=SPC.IdAsignadoA
			LEFT JOIN dbo.S_TipoUsuario TU ON TU.IdTipoUsuario = U.IdTipoUsuario			
			WHERE 		
			SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
			AND SPC.Activo=1
			FOR XML PATH ( '' )), 1, 1, '' ))
			FROM dbo.MM_SolicitudPedido SP
			WHERE 
			SP.IdProveedor = @IdProveedor
		--END 
			
		
		---- OT.IdEstatusOperacion= 2 ---> Aprobada por aprobadores internos
		----  OT.IdTipoOperacion=2 ---> Tipo de operación Solicitud de pedido
		---- PeticionEnviada Cuando la Solicitud de pedido es enviada a una petición de oferta con sus respectivos proveedores de ventas
		IF @Consulta = 1  --> PENDIENTES DE ENVIAR 
			BEGIN

				SELECT		
					SP.IdSolicitudPedido
				INTO #RESULTADOSNOENVIADAS
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
						(SP.PeticionEnviada = 0 OR SP.PeticionEnviada IS NULL )
						--AND ( SP.IdTipoProceso IS NULL )
						AND ISNULL ( SP.Visible, 1 ) = 1
						AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGGA ESTATUS ELIMINADO
				AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1
							AND 
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY	SP.IdSolicitudPedido;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #RESULTADOSNOENVIADAS);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT		
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido, 
					U.Nombre AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS  FechaAlta,
					TSP.TipoSolicitudPedido, 
					PSP.Prioridad, 
					(CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN
								  CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END ) AS FechaEntrega, 
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,
					SP.MotivoUrgencia, 
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage _Page
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
						(SP.PeticionEnviada = 0 OR SP.PeticionEnviada IS NULL )
						--AND ( SP.IdTipoProceso IS NULL )
						AND ISNULL ( SP.Visible, 1 ) = 1
						AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGGA ESTATUS ELIMINADO
				AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1
							AND 
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY	SP.IdSolicitudPedido, 
							SP.MotivoUrgencia, 
							TSP.TipoSolicitudPedido, 
							PSP.Prioridad, 
							SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, 
							SP.FechaEntregaRequerida, 
							SP.FechaEntregaFinRequerida, 
							U.Nombre ,
							SP.IdTipoProceso,SP.Asignado,
							SP.ComentarioInternoPO,
							CA.Compradores)
				AS R WHERE R.R = 1
					AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC

			END

		IF @Consulta = 2  --> ENVIADA VIGENTE
			BEGIN

				SELECT	
					SP.IdSolicitudPedido
				INTO #RESULTADOENVIADAVIGENTE
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
				LEFT JOIN dbo.MM_Pedido AS P
					ON P.IdSolicitudPedido = SP.IdSolicitudPedido
				LEFT JOIN dbo.MM_Pedidos AS PS
					ON PS.IdIdentificador = P.IdPedido
					 AND PS.IdProveedorCliente = SP.IdProveedor
					 AND PS.IdTipoPedido IN (2, 4)
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND DATEDIFF(MINUTE, TAP.FechaFinalizacion, GETDATE()) < 0
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' --OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' 
								OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #RESULTADOENVIADAVIGENTE);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido,
					U.Nombre AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS  FechaAlta,
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta ,
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones ,
					ISNULL(TP.TipoPedido, 'Sin clasificación' ) AS TipoProceso, 
					(CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END ) AS FechaEntrega,
					CASE 
						WHEN (SUM(CASE 
									WHEN PO.NoCotizar = 1 THEN 1
									ELSE
										CASE 
											WHEN PO.Cotizado = 1 THEN 1 
											ELSE 0 
										END
									END )) > 0 THEN 'Cotizado'
						ELSE 'No Cotizado'
					END AS Cotizado , 
					dbo.Fn_ObtenerFechaFinalizacionCotizacionPorSolPed(SP.IdSolicitudPedido, @IdProveedor ) AS FechaFinalizacion ,
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores ,
					--CASE 
					--	WHEN LEN(CA.Compradores)> 0 THEN CA.Compradores
					--	ELSE 'Sin asignar'
					--END  AS Asignados,
					SP.MotivoUrgencia, 
					TSP.TipoSolicitudPedido, 
					--PSP.Prioridad, 
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_Pedido WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConPedido,
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConOferta,
					TP.IdTipoPedido AS IdTipoProceso,
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC)) AS _R,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1) AS _ROW,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
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
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND DATEDIFF(MINUTE, TAP.FechaFinalizacion, GETDATE()) < 0
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado, TP.IdTipoPedido,CA.Compradores,TP.IdTipoPedido,SP.ComentarioInternoPO
				--ORDER BY	SP.IdSolicitudPedido DESC
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


			END

		IF @Consulta = 3 --> ENVIADA VENCIDA
		BEGIN

				SELECT	
					SP.IdSolicitudPedido
				INTO #RESULTADOENVIADAVENCIDA
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
				LEFT JOIN dbo.MM_Pedido AS P
					ON P.IdSolicitudPedido = SP.IdSolicitudPedido
				LEFT JOIN dbo.MM_Pedidos AS PS
					ON PS.IdIdentificador = P.IdPedido
					 AND PS.IdProveedorCliente = SP.IdProveedor
					 AND PS.IdTipoPedido IN (2, 4)
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND DATEDIFF(MINUTE, TAP.FechaFinalizacion, GETDATE()) >= 0
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' --OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' 
								OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #RESULTADOENVIADAVENCIDA);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido,
					U.Nombre  AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS  FechaAlta,
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta ,
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones ,
					ISNULL(TP.TipoPedido, 'Sin clasificación' ) AS TipoProceso, 
					(CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END ) AS FechaEntrega,
					CASE 
						WHEN (SUM(CASE 
									WHEN PO.NoCotizar = 1 THEN 1
									ELSE
										CASE 
											WHEN PO.Cotizado = 1 THEN 1 
											ELSE 0 
										END
									END )) > 0 THEN 'Cotizado'
						ELSE 'No Cotizado'
					END AS Cotizado , 
					dbo.Fn_ObtenerFechaFinalizacionCotizacionPorSolPed(SP.IdSolicitudPedido, @IdProveedor ) AS FechaFinalizacion ,
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores ,
					--CASE 
					--	WHEN LEN(CA.Compradores)> 0 THEN CA.Compradores
					--	ELSE 'Sin asignar'
					--END  AS Asignados,
					SP.MotivoUrgencia, 
					TSP.TipoSolicitudPedido, 
					--PSP.Prioridad, 
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_Pedido WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConPedido,
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConOferta,
					TP.IdTipoPedido AS IdTipoProceso,
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC)) AS _R,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1) AS _ROW,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
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
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND DATEDIFF(MINUTE, TAP.FechaFinalizacion, GETDATE()) >= 0
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado, TP.IdTipoPedido,CA.Compradores,TP.IdTipoPedido,SP.ComentarioInternoPO
				--ORDER BY	SP.IdSolicitudPedido DESC
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


			END

		IF @Consulta = 4 -->COTIZADA
		BEGIN

				SELECT	
					SP.IdSolicitudPedido
				INTO #RESULTADOCOTIZADA
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
				LEFT JOIN dbo.MM_Pedido AS P
					ON P.IdSolicitudPedido = SP.IdSolicitudPedido
				LEFT JOIN dbo.MM_Pedidos AS PS
					ON PS.IdIdentificador = P.IdPedido
					 AND PS.IdProveedorCliente = SP.IdProveedor
					 AND PS.IdTipoPedido IN (2, 4)
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND (SELECT 
									COUNT(1) 
								FROM dbo.MM_PeticionOferta AS POI
								LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
									ON PODI.IdPeticionOferta = POI.IdPeticionOferta
								WHERE 
									POI.IdSolicitudPedido = SP.IdSolicitudPedido
									AND POI.Cotizado = 1
									AND PODI.Cotizado = 1) >= 1
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' --OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' 
								OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #RESULTADOCOTIZADA);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido,
					U.Nombre AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS  FechaAlta,
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta ,
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones ,
					ISNULL(TP.TipoPedido, 'Sin clasificación' ) AS TipoProceso, 
					(CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END ) AS FechaEntrega,
					CASE 
						WHEN (SUM(CASE 
									WHEN PO.NoCotizar = 1 THEN 1
									ELSE
										CASE 
											WHEN PO.Cotizado = 1 THEN 1 
											ELSE 0 
										END
									END )) > 0 THEN 'Cotizado'
						ELSE 'No Cotizado'
					END AS Cotizado , 
					dbo.Fn_ObtenerFechaFinalizacionCotizacionPorSolPed(SP.IdSolicitudPedido, @IdProveedor ) AS FechaFinalizacion ,
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores ,
					--CASE 
					--	WHEN LEN(CA.Compradores)> 0 THEN CA.Compradores
					--	ELSE 'Sin asignar'
					--END  AS Asignados,
					SP.MotivoUrgencia, 
					TSP.TipoSolicitudPedido, 
					--PSP.Prioridad, 
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_Pedido WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConPedido,
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConOferta,
					TP.IdTipoPedido AS IdTipoProceso,
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC)) AS _R,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1) AS _ROW,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
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
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND (SELECT 
									COUNT(1) 
								FROM dbo.MM_PeticionOferta AS POI
								LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
									ON PODI.IdPeticionOferta = POI.IdPeticionOferta
								WHERE 
									POI.IdSolicitudPedido = SP.IdSolicitudPedido
									AND POI.Cotizado = 1
									AND PODI.Cotizado = 1) >= 1
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado, TP.IdTipoPedido,CA.Compradores,TP.IdTipoPedido,SP.ComentarioInternoPO
				--ORDER BY	SP.IdSolicitudPedido DESC
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


			END

		IF @Consulta = 5 -->SIN RESPUESTA DEL PROVEEDOR
		BEGIN

				SELECT	
					SP.IdSolicitudPedido
				INTO #RESULTADOSINRESPEUSTA
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
				LEFT JOIN dbo.MM_Pedido AS P
					ON P.IdSolicitudPedido = SP.IdSolicitudPedido
				LEFT JOIN dbo.MM_Pedidos AS PS
					ON PS.IdIdentificador = P.IdPedido
					 AND PS.IdProveedorCliente = SP.IdProveedor
					 AND PS.IdTipoPedido IN (2, 4)
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND (SELECT 
									COUNT(PODI.IdPeticionOfertaDetalle) 
								FROM dbo.MM_PeticionOferta AS POI
								LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
									ON PODI.IdPeticionOferta = POI.IdPeticionOferta
								WHERE 
									POI.IdSolicitudPedido = SP.IdSolicitudPedido
									AND ISNULL(POI.Cotizado,0) = 0) = (SELECT 
																			COUNT(PODI.IdPeticionOfertaDetalle) 
																		FROM dbo.MM_PeticionOferta AS POI
																		LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
																			ON PODI.IdPeticionOferta = POI.IdPeticionOferta
																		WHERE 
																			POI.IdSolicitudPedido = SP.IdSolicitudPedido)
							AND DATEDIFF(MINUTE, TAP.FechaFinalizacion, GETDATE()) >= 0
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' --OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' 
								OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #RESULTADOSINRESPEUSTA);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido,
					U.Nombre AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS  FechaAlta,
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta ,
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones ,
					ISNULL(TP.TipoPedido, 'Sin clasificación' ) AS TipoProceso, 
					(CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END ) AS FechaEntrega,
					CASE 
						WHEN (SUM(CASE 
									WHEN PO.NoCotizar = 1 THEN 1
									ELSE
										CASE 
											WHEN PO.Cotizado = 1 THEN 1 
											ELSE 0 
										END
									END )) > 0 THEN 'Cotizado'
						ELSE 'No Cotizado'
					END AS Cotizado , 
					dbo.Fn_ObtenerFechaFinalizacionCotizacionPorSolPed(SP.IdSolicitudPedido, @IdProveedor ) AS FechaFinalizacion ,
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores ,
					--CASE 
					--	WHEN LEN(CA.Compradores)> 0 THEN CA.Compradores
					--	ELSE 'Sin asignar'
					--END  AS Asignados,
					SP.MotivoUrgencia, 
					TSP.TipoSolicitudPedido, 
					--PSP.Prioridad, 
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_Pedido WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConPedido,
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConOferta,
					TP.IdTipoPedido AS IdTipoProceso,
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC)) AS _R,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1) AS _ROW,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
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
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND (SELECT 
									COUNT(PODI.IdPeticionOfertaDetalle) 
								FROM dbo.MM_PeticionOferta AS POI
								LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
									ON PODI.IdPeticionOferta = POI.IdPeticionOferta
								WHERE 
									POI.IdSolicitudPedido = SP.IdSolicitudPedido
									AND ISNULL(POI.Cotizado,0) = 0) = (SELECT 
																			COUNT(PODI.IdPeticionOfertaDetalle) 
																		FROM dbo.MM_PeticionOferta AS POI
																		LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
																			ON PODI.IdPeticionOferta = POI.IdPeticionOferta
																		WHERE 
																			POI.IdSolicitudPedido = SP.IdSolicitudPedido)
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado, TP.IdTipoPedido,CA.Compradores,SP.ComentarioInternoPO
				--ORDER BY	SP.IdSolicitudPedido DESC
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


			END

		IF @Consulta = 6 -->NO COTIZADA
		BEGIN

				SELECT	
					SP.IdSolicitudPedido
				INTO #RESULTADONOCOTIZADA
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
				LEFT JOIN dbo.MM_Pedido AS P
					ON P.IdSolicitudPedido = SP.IdSolicitudPedido
				LEFT JOIN dbo.MM_Pedidos AS PS
					ON PS.IdIdentificador = P.IdPedido
					 AND PS.IdProveedorCliente = SP.IdProveedor
					 AND PS.IdTipoPedido IN (2, 4)
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND (SELECT 
									COUNT(1)
								FROM dbo.MM_PeticionOferta AS POI
								LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
									ON PODI.IdPeticionOferta = POI.IdPeticionOferta
								WHERE 
									POI.IdSolicitudPedido = SP.IdSolicitudPedido
									AND PODI.NoCotizar = 1) = (SELECT 
																	COUNT(1) 
																FROM dbo.MM_PeticionOferta AS POI
																	LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
																		ON PODI.IdPeticionOferta = POI.IdPeticionOferta
																WHERE 
																	POI.IdSolicitudPedido = SP.IdSolicitudPedido)
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' --OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' 
								OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #RESULTADONOCOTIZADA);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido,
					U.Nombre AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS  FechaAlta,
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta ,
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones ,
					ISNULL(TP.TipoPedido, 'Sin clasificación' ) AS TipoProceso, 
					(CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END ) AS FechaEntrega,
					CASE 
						WHEN (SUM(CASE 
									WHEN PO.NoCotizar = 1 THEN 1
									ELSE
										CASE 
											WHEN PO.Cotizado = 1 THEN 1 
											ELSE 0 
										END
									END )) > 0 THEN 'Cotizado'
						ELSE 'No Cotizado'
					END AS Cotizado , 
					dbo.Fn_ObtenerFechaFinalizacionCotizacionPorSolPed(SP.IdSolicitudPedido, @IdProveedor ) AS FechaFinalizacion ,
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores ,
					--CASE 
					--	WHEN LEN(CA.Compradores)> 0 THEN CA.Compradores
					--	ELSE 'Sin asignar'
					--END  AS Asignados,
					SP.MotivoUrgencia, 
					TSP.TipoSolicitudPedido, 
					--PSP.Prioridad, 
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_Pedido WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConPedido,
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConOferta,
					TP.IdTipoPedido AS IdTipoProceso,
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC)) AS _R,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1) AS _ROW,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
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
				LEFT JOIN dbo.TA_Operacion AS TAP
					ON TAP.IdDocumento = SP.IdSolicitudPedido
					AND TAP.IdTipoOperacion = 6
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND SP.PeticionEnviada = 1
							AND (SELECT 
									COUNT(1)
								FROM dbo.MM_PeticionOferta AS POI
								LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
									ON PODI.IdPeticionOferta = POI.IdPeticionOferta
								WHERE 
									POI.IdSolicitudPedido = SP.IdSolicitudPedido
									AND PODI.NoCotizar = 1) = (SELECT 
																	COUNT(1) 
																FROM dbo.MM_PeticionOferta AS POI
																	LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
																		ON PODI.IdPeticionOferta = POI.IdPeticionOferta
																WHERE 
																	POI.IdSolicitudPedido = SP.IdSolicitudPedido)
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado, TP.IdTipoPedido,CA.Compradores,TP.IdTipoPedido,SP.ComentarioInternoPO
				--ORDER BY	SP.IdSolicitudPedido DESC
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


			END

		IF @Consulta = 7  --> MOSTRAR TODAS 
			BEGIN
				
				SELECT	
					SP.IdSolicitudPedido
				INTO #RESULTADOSTODOS
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
				LEFT JOIN dbo.MM_Pedido AS P
					ON P.IdSolicitudPedido = SP.IdSolicitudPedido
				LEFT JOIN dbo.MM_Pedidos AS PS
					ON PS.IdIdentificador = P.IdPedido
					 AND PS.IdProveedorCliente = SP.IdProveedor
					 AND PS.IdTipoPedido IN (2, 4)
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' --OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' 
								OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #RESULTADOSTODOS);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido,
					Contrato = c.NumeroContrato,
					U.Nombre AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS  FechaAlta,
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta ,
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones ,
					ISNULL(TP.TipoPedido, 'Sin clasificación' ) AS TipoProceso, 
					(CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END ) AS FechaEntrega,
					CASE 
						WHEN (SUM(CASE 
									WHEN PO.NoCotizar = 1 THEN 1
									ELSE
										CASE 
											WHEN PO.Cotizado = 1 THEN 1 
											ELSE 0 
										END
									END )) > 0 THEN 'Cotizado'
						ELSE 'No Cotizado'
					END AS Cotizado , 
					dbo.Fn_ObtenerFechaFinalizacionCotizacionPorSolPed(SP.IdSolicitudPedido, @IdProveedor ) AS FechaFinalizacion ,
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores ,
					--CASE 
					--	WHEN LEN(CA.Compradores)> 0 THEN CA.Compradores
					--	ELSE 'Sin asignar'
					--END  AS Asignados,
					SP.MotivoUrgencia, 
					TSP.TipoSolicitudPedido, 
					--PSP.Prioridad, 
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_Pedido WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConPedido,
					CASE 
						WHEN (SELECT COUNT(1) FROM dbo.MM_PeticionOferta WHERE IdSolicitudPedido = SP.IdSolicitudPedido AND ISNULL(IdEstatusEliminado,0) = 0) > 0 THEN 1
						ELSE 0
					END AS ConOferta,
					TP.IdTipoPedido AS IdTipoProceso,
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC)) AS _R,
					--(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1) AS _ROW,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM		MM_SolicitudPedido				AS SP
				INNER JOIN	MM_TipoSolicitudPedido			AS TSP
				ON			TSP.IdTipoSolicitudPedido		=	SP.IdTipoSolicitudPedido
				INNER JOIN	MM_PrioridadSolicitudPedido		AS PSP
				ON			PSP.IdPrioridadSolicitudPedido	= SP.IdPrioridadSolicitudPedido
				INNER JOIN	TA_Operacion					AS OT
				ON			OT.IdDocumento					=	SP.IdSolicitudPedido
				INNER JOIN	S_Usuario						AS	U
				ON			U.IdUsuario						=	OT.IdAsignador
				LEFT JOIN	dbo.MM_TipoPedido				TP
				ON			TP.IdTipoPedido					=	SP.IdTipoProceso
				LEFT JOIN	MM_PeticionOferta				AS	PO
				ON			PO.IdSolicitudPedido			=	SP.IdSolicitudPedido
				LEFT JOIN	dbo.MM_SolicitudPedidoComprador SPC 
				ON			SPC.IdSolicitudPedido			=	SP.IdSolicitudPedido	
				LEFT JOIN	#CompradoresAsignados			CA	
				ON			CA.IdSolicitudPedido			=	SP.IdSolicitudPedido
				inner join	Adinco.dbo.CO_Contrato			c
				on			c.IdContrato					=	sp.IdContrato
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO	
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1 AND
							(
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								--PS.IdPedido LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado, TP.IdTipoPedido,CA.Compradores,TP.IdTipoPedido,SP.ComentarioInternoPO,
							c.NumeroContrato
				--ORDER BY	SP.IdSolicitudPedido DESC
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC
		
		END

		IF @Consulta = 8  --> MOSTRAR TODAS SIN COMPRADOR ASIGNADO
			BEGIN

				SELECT		
					SP.IdSolicitudPedido
					INTO #RESULTADOSSINASIGNADOR
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
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1
						AND LEN(RTRIM((LTRIM(ISNULL(CA.Compradores,'')))))=0	--> SI NO TIENE COMPRADORES ASIGNADOS 
						AND (
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)						 
				GROUP BY	SP.IdSolicitudPedido

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #RESULTADOSSINASIGNADOR);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					Contrato = c.NumeroContrato,
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido, 
					U.Nombre AS SolicitadoPor, 
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS  FechaAlta,
					--CASE 
					--	WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
					--	WHEN SP.PeticionEnviada IS NULL THEN 'Pendiente de Enviar'
					--END AS EstatusOferta,
					--ISNULL ( TP.TipoPedido, 'Sin clasificación' ) AS TipoProceso,
					(CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN
								  CONCAT (
									  CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,
									  CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END) AS FechaEntrega,
					TSP.TipoSolicitudPedido,
					PSP.Prioridad, 
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,
					SP.MotivoUrgencia, 
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage _Page
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
				LEFT JOIN Adinco.dbo.CO_Contrato AS C ON SP.IdContrato = C.IdContrato
				WHERE		SP.IdProveedor = @IdProveedor
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
							AND SP.Activo = 1
							AND ISNULL ( SP.Visible, 1 ) = 1
							AND ISNULL ( SP.IdEstatusEliminado, 0 ) <> 1 --> NO TENGA ESTATUS ELIMINADO
							AND CASE WHEN ISNULL(@EsAdministrador,0) IN (0,1) AND  SPC.IdSolicitudPedidoComprador IS NOT NULL AND SPC.IdAsignadoA=@IdUsuario AND SPC.Activo=1 THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
								0  --> NO MOSTRAR NINGUNA 
							END =1
						AND LEN(RTRIM((LTRIM(ISNULL(CA.Compradores,'')))))=0	--> SI NO TIENE COMPRADORES ASIGNADOS 		
						AND (
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)				 
				GROUP BY	SP.IdSolicitudPedido, SP.MotivoUrgencia, TSP.TipoSolicitudPedido, PSP.Prioridad, SP.FechaAlta ,
							SP.UnaSolaEntregaRequerida, SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, U.Nombre ,
							SP.PeticionEnviada, SP.IdTipoProceso, TP.TipoPedido, SP.IdEstatusEliminado, TP.IdTipoPedido,CA.Compradores,
							SP.ComentarioInternoPO,
							c.NumeroContrato
				)
				AS R --WHERE R.R = 1
					--AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC
			END

	END

