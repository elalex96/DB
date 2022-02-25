USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultaPeticionesOfertas]    Script Date: 23/02/2022 09:54:15 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <07/02/2020>
-- Description:	<consulta para la pantalla para la solicitud de oferta,
-- consultando por parametros simulando los grids de devexpress(Pendientes de enviar, enviada, todas, etc..)>
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: <22/01/2021>
-- Description:	Se agrego columna de Contrato en todas las consultas finales del filtro
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <24/02/2022>
-- Description:	<Optimizacion del sp>
-- =============================================
ALTER PROCEDURE [dbo].[SP_MM_ConsultaPeticionesOfertas] --516,7,2415,1,'',2
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

	CREATE TABLE #LISTA_SOLPED(
		IdSolicitudPedido INT,
		FechaAlta DATETIME,
		PeticionEnviada BIT,
		UnaSolaEntregaRequerida BIT,
		FechaEntregaRequerida DATETIME,
		FechaEntregaFinRequerida DATETIME,
		ComentarioInternoPO VARCHAR(MAX),
		IdTipoSolicitudPedido INT,
		IdPrioridadSolicitudPedido INT,
		IdContrato INT,
		IdAsignador INT,
		MotivoUrgencia VARCHAR(MAX),
		IdTipoProceso INT,
		IdEstatusEliminado INT,
		FechaFinalizacion DATETIME
	);

	--CONSULTAR SI EL USUARIO ACTUAL ES ADMINISTRADOR DE COMPRAS
	SELECT  
		@EsAdministradorCompras = Activo
	FROM dbo.CC_AdministradorCompras (NOLOCK)
	WHERE IdUsuario = @IdUsuario 
	AND Activo=1
	AND IdProveedor=@IdProveedor
		
	--CONSULTAR SI EL USUARIO ACTUAL ES USUARIO DE TIPO ADMINISTRADOR 
	SELECT @EsTipoAdministrador= CASE WHEN COUNT(1)> 0 THEN 1 ELSE 0 END
	FROM dbo.S_Usuario (NOLOCK) U 
	WHERE U.IdTipoUsuario IN (3,4,6,7,8)  --> CTES Administrador,Ventas,finanzas,Director General,Root
	AND U.IdUsuario=@IdUsuario

		--SI CUMPLE ALGUNO DE ESTOS PARAMETROS ES UN ADMINISTRADOR Y PUEDE VER TODAS LAS PETICIONES DE SOL OFERTA
		-- SI NO SOLO PODRÁ VER LAS SOL OFERTA DONDE FUE ASIGNADO
	IF @EsTipoAdministrador=1 OR @EsAdministradorCompras =1
	BEGIN
        SET @EsAdministrador =1
	END 

	CREATE TABLE #CompradoresAsignados(IdSolicitudPedido INT, Compradores NVARCHAR(MAX))
		
	INSERT INTO #CompradoresAsignados
	SELECT 
		SP.IdSolicitudPedido, 
		(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA)
	FROM dbo.MM_SolicitudPedidoComprador SPC 
		INNER JOIN dbo.S_Usuario (NOLOCK) U 
			ON SPC.IdAsignadoA=U.IdUsuario
		LEFT JOIN dbo.S_TipoUsuario (NOLOCK) TU 
			ON U.IdTipoUsuario=TU.IdTipoUsuario 			
	WHERE 		
		SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
		AND SPC.Activo=1
			FOR XML PATH ( '' )), 1, 1, '' ))
			FROM dbo.MM_SolicitudPedido (NOLOCK) SP
			WHERE SP.IdProveedor = @IdProveedor

	---- OT.IdEstatusOperacion= 2 ---> Aprobada por aprobadores internos
	----  OT.IdTipoOperacion=2 ---> Tipo de operación Solicitud de pedido
	---- PeticionEnviada Cuando la Solicitud de pedido es enviada a una petición de oferta con sus respectivos proveedores de ventas
	IF @Consulta = 1  --> PENDIENTES DE ENVIAR 
	BEGIN

		INSERT INTO #LISTA_SOLPED
		SELECT
			SP.IdSolicitudPedido,
			SP.FechaAlta,
			SP.PeticionEnviada,
			SP.UnaSolaEntregaRequerida,
			SP.FechaEntregaRequerida,
			SP.FechaEntregaFinRequerida,
			SP.ComentarioInternoPO,
			SP.IdTipoSolicitudPedido,
			SP.IdPrioridadSolicitudPedido,
			SP.IdContrato,
			OT.IdAsignador,
			SP.MotivoUrgencia,
			SP.IdTipoProceso,
			SP.IdEstatusEliminado,
			TAO.FechaFinalizacion
		FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
			JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
				ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
					AND SP.IdProveedor = @IdProveedor
					AND SP.Activo = 1
					AND ISNULL(SP.Visible,1) = 1
					AND ISNULL(SP.IdEstatusEliminado,0) <> 1
					AND (SP.PeticionEnviada = 0 OR SP.PeticionEnviada IS NULL )
			JOIN dbo.TA_Operacion (NOLOCK) AS OT
				ON SP.IdSolicitudPedido = OT.IdDocumento
					AND OT.IdEstatusOperacion = 2
					AND OT.IdTipoOperacion = 2
			LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
				ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
			JOIN dbo.S_Usuario (NOLOCK) AS U
				ON OT.IdAsignador = U.IdUsuario
			LEFT JOIN dbo.TA_Operacion (NOLOCK) AS TAO
				ON TAO.IdDocumento = SP.IdSolicitudPedido
					AND TAO.IdTipoOperacion = 6
					AND TAO.IdProveedor = @IdProveedor
		WHERE (CASE 
					WHEN ISNULL(@EsAdministrador,0) IN (0,1) 
						AND  SPC.IdSolicitudPedidoComprador IS NOT NULL 
						AND SPC.IdAsignadoA = @IdUsuario AND SPC.Activo = 1
					THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
						1
					WHEN  ISNULL(@EsAdministrador,0) = 1 
					THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
						1 
					ELSE 
						0  --> NO MOSTRAR NINGUNA
					END) = 1
					AND (
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
		GROUP BY SP.IdSolicitudPedido,
						SP.FechaAlta,
						SP.PeticionEnviada,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.ComentarioInternoPO,
						SP.IdTipoSolicitudPedido,
						SP.IdPrioridadSolicitudPedido,
						U.Nombre,
						SP.IdContrato,
						SP.FechaEntregaFinRequerida,
						OT.IdAsignador,
						SP.MotivoUrgencia,
						SP.IdTipoProceso,
						SP.IdEstatusEliminado,
						TAO.FechaFinalizacion;

		SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #LISTA_SOLPED);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END AS FechaEntrega,--FechaEntrega
					SP.MotivoUrgencia, --MotivoUrgencia
					TSP.TipoSolicitudPedido, --TipoSolicitudPedido
					SP.ComentarioInternoPO,--ComentarioInternoPO
					C.NumeroContrato AS Contrato,--Contrato
					ISNULL(CA.Compradores,'') AS IdAsignado,
					U.Nombre AS SolicitadoPor,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					PSP.Prioridad, 
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN #LISTA_SOLPED AS SP
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
					JOIN Adinco.dbo.CO_Contrato (NOLOCK) c
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE (
							SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
							SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
							U.Nombre LIKE '%' + @Buscar + '%' OR
							dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
						)
				GROUP BY SP.IdSolicitudPedido, --IdSolicitudPedido
						SP.FechaAlta,--FechaAlta
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.FechaEntregaFinRequerida,
						SP.MotivoUrgencia, --MotivoUrgencia
						TSP.TipoSolicitudPedido, --TipoSolicitudPedido
						SP.ComentarioInternoPO,--ComentarioInternoPO
						C.NumeroContrato,--Contrato
						U.Nombre,
						PSP.Prioridad,
						CA.Compradores)
				AS R 
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC

	END

	IF @Consulta = 2  --> ENVIADA VIGENTE
	BEGIN

				INSERT INTO #LISTA_SOLPED
				SELECT
					SP.IdSolicitudPedido,
					SP.FechaAlta,
					SP.PeticionEnviada,
					SP.UnaSolaEntregaRequerida,
					SP.FechaEntregaRequerida,
					SP.FechaEntregaFinRequerida,
					SP.ComentarioInternoPO,
					SP.IdTipoSolicitudPedido,
					SP.IdPrioridadSolicitudPedido,
					SP.IdContrato,
					OT.IdAsignador,
					SP.MotivoUrgencia,
					SP.IdTipoProceso,
					SP.IdEstatusEliminado,
					TAO.FechaFinalizacion
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
							AND SP.IdProveedor = @IdProveedor
							AND SP.Activo = 1
							AND ISNULL(SP.Visible,1) = 1
							AND ISNULL(SP.IdEstatusEliminado,0) <> 1
							AND SP.PeticionEnviada = 1
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON TAO.IdDocumento = SP.IdSolicitudPedido
						AND TAO.IdTipoOperacion = 6
						AND TAO.IdProveedor = @IdProveedor
						AND DATEDIFF(MINUTE, TAO.FechaFinalizacion, GETDATE()) < 0
				WHERE (CASE 
							WHEN ISNULL(@EsAdministrador,0) IN (0,1) 
								AND  SPC.IdSolicitudPedidoComprador IS NOT NULL 
								AND SPC.IdAsignadoA = @IdUsuario 
								AND SPC.Activo = 1 
							THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 
							THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
							0  --> NO MOSTRAR NINGUNA 
					   END) = 1
					   AND (
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido,
						SP.FechaAlta,
						SP.PeticionEnviada,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.ComentarioInternoPO,
						SP.IdTipoSolicitudPedido,
						SP.IdPrioridadSolicitudPedido,
						U.Nombre,
						SP.IdContrato,
						SP.FechaEntregaFinRequerida,
						OT.IdAsignador,
						SP.MotivoUrgencia,
						SP.IdTipoProceso,
						SP.IdEstatusEliminado,
						TAO.FechaFinalizacion;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #LISTA_SOLPED);

				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					ISNULL(TP.TipoPedido, 'Sin clasificación') AS TipoProceso,--TipoProceso
					CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END AS FechaEntrega,--FechaEntrega
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
					END AS Cotizado,--Cotizado
					SP.FechaFinalizacion AS FechaFinalizacion, --FechaFinalizacion
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores, --Proveedores
					SP.MotivoUrgencia, --MotivoUrgencia
					TSP.TipoSolicitudPedido, --TipoSolicitudPedido
					CASE 
					WHEN PED.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConPedido, --ConPedido
					CASE
						WHEN PO.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConOferta,--ConOferta
					TP.IdTipoPedido AS IdTipoProceso,--IdTipoProceso
					SP.ComentarioInternoPO,--ComentarioInternoPO
					C.NumeroContrato AS Contrato,--Contrato
					ISNULL(CA.Compradores,'') AS IdAsignado,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					U.Nombre AS SolicitadoPor,
					PSP.Prioridad, 
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN #LISTA_SOLPED AS SP
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
					JOIN Adinco.dbo.CO_Contrato (NOLOCK) c
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido
						AND ISNULL(PED.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE (
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
							SP.PeticionEnviada, 
							SP.IdTipoProceso, 
							TP.TipoPedido, 
							SP.IdEstatusEliminado, 
							TP.IdTipoPedido,
							TP.IdTipoPedido,
							SP.ComentarioInternoPO,
							C.NumeroContrato,
							CA.Compradores,
							PO.IdSolicitudPedido,
							PED.IdSolicitudPedido,
							SP.FechaFinalizacion
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


			END

	IF @Consulta = 3 --> ENVIADA VENCIDA
	BEGIN

				INSERT INTO #LISTA_SOLPED
				SELECT
					SP.IdSolicitudPedido,
					SP.FechaAlta,
					SP.PeticionEnviada,
					SP.UnaSolaEntregaRequerida,
					SP.FechaEntregaRequerida,
					SP.FechaEntregaFinRequerida,
					SP.ComentarioInternoPO,
					SP.IdTipoSolicitudPedido,
					SP.IdPrioridadSolicitudPedido,
					SP.IdContrato,
					OT.IdAsignador,
					SP.MotivoUrgencia,
					SP.IdTipoProceso,
					SP.IdEstatusEliminado,
					TAO.FechaFinalizacion
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
							AND SP.IdProveedor = @IdProveedor
							AND SP.Activo = 1
							AND ISNULL(SP.Visible,1) = 1
							AND ISNULL(SP.IdEstatusEliminado,0) <> 1
							AND SP.PeticionEnviada = 1
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON TAO.IdDocumento = SP.IdSolicitudPedido
						AND TAO.IdTipoOperacion = 6
						AND TAO.IdProveedor = @IdProveedor
						AND DATEDIFF(MINUTE, TAO.FechaFinalizacion, GETDATE()) >= 0
				WHERE (CASE 
							WHEN ISNULL(@EsAdministrador,0) IN (0,1) 
								AND  SPC.IdSolicitudPedidoComprador IS NOT NULL 
								AND SPC.IdAsignadoA = @IdUsuario 
								AND SPC.Activo = 1 
							THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 
							THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
							0  --> NO MOSTRAR NINGUNA 
					   END) = 1
					   AND (
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido,
						SP.FechaAlta,
						SP.PeticionEnviada,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.ComentarioInternoPO,
						SP.IdTipoSolicitudPedido,
						SP.IdPrioridadSolicitudPedido,
						U.Nombre,
						SP.IdContrato,
						SP.FechaEntregaFinRequerida,
						OT.IdAsignador,
						SP.MotivoUrgencia,
						SP.IdTipoProceso,
						SP.IdEstatusEliminado,
						TAO.FechaFinalizacion;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #LISTA_SOLPED);

				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					ISNULL(TP.TipoPedido, 'Sin clasificación') AS TipoProceso,--TipoProceso
					CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END AS FechaEntrega,--FechaEntrega
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
					END AS Cotizado,--Cotizado
					SP.FechaFinalizacion AS FechaFinalizacion, --FechaFinalizacion
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores, --Proveedores
					SP.MotivoUrgencia, --MotivoUrgencia
					TSP.TipoSolicitudPedido, --TipoSolicitudPedido
					CASE 
					WHEN PED.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConPedido, --ConPedido
					CASE
						WHEN PO.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConOferta,--ConOferta
					TP.IdTipoPedido AS IdTipoProceso,--IdTipoProceso
					SP.ComentarioInternoPO,--ComentarioInternoPO
					C.NumeroContrato AS Contrato,--Contrato
					ISNULL(CA.Compradores,'') AS IdAsignado,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					U.Nombre AS SolicitadoPor,
					PSP.Prioridad, 
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN #LISTA_SOLPED AS SP
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
					JOIN Adinco.dbo.CO_Contrato (NOLOCK) c
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido
						AND ISNULL(PED.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE (
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
							SP.PeticionEnviada, 
							SP.IdTipoProceso, 
							TP.TipoPedido, 
							SP.IdEstatusEliminado, 
							TP.IdTipoPedido,
							TP.IdTipoPedido,
							SP.ComentarioInternoPO,
							C.NumeroContrato,
							CA.Compradores,
							PO.IdSolicitudPedido,
							PED.IdSolicitudPedido,
							SP.FechaFinalizacion
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


	END

	IF @Consulta = 4 -->COTIZADA
	BEGIN

				INSERT INTO #LISTA_SOLPED
				SELECT
					SP.IdSolicitudPedido,
					SP.FechaAlta,
					SP.PeticionEnviada,
					SP.UnaSolaEntregaRequerida,
					SP.FechaEntregaRequerida,
					SP.FechaEntregaFinRequerida,
					SP.ComentarioInternoPO,
					SP.IdTipoSolicitudPedido,
					SP.IdPrioridadSolicitudPedido,
					SP.IdContrato,
					OT.IdAsignador,
					SP.MotivoUrgencia,
					SP.IdTipoProceso,
					SP.IdEstatusEliminado,
					TAO.FechaFinalizacion
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
							AND SP.IdProveedor = @IdProveedor
							AND SP.Activo = 1
							AND ISNULL(SP.Visible,1) = 1
							AND ISNULL(SP.IdEstatusEliminado,0) <> 1
							AND SP.PeticionEnviada = 1
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON TAO.IdDocumento = SP.IdSolicitudPedido
						AND TAO.IdTipoOperacion = 6
						AND TAO.IdProveedor = @IdProveedor
					JOIN dbo.MM_PeticionOferta (NOLOCK) AS POF
						ON SP.IdSolicitudPedido = POF.IdSolicitudPedido
						AND ISNULL(POF.IdEstatusEliminado,0) = 0
					JOIN dbo.MM_PeticionOfertaDetalle (NOLOCK) AS POFD
					 ON POF.IdPeticionOferta = POFD.IdPeticionOferta
						 AND POF.Cotizado = 1
						 AND POFD.Cotizado = 1
				WHERE (CASE 
							WHEN ISNULL(@EsAdministrador,0) IN (0,1) 
								AND  SPC.IdSolicitudPedidoComprador IS NOT NULL 
								AND SPC.IdAsignadoA = @IdUsuario 
								AND SPC.Activo = 1 
							THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 
							THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
							0  --> NO MOSTRAR NINGUNA 
					   END) = 1
					   AND (
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido,
						SP.FechaAlta,
						SP.PeticionEnviada,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.ComentarioInternoPO,
						SP.IdTipoSolicitudPedido,
						SP.IdPrioridadSolicitudPedido,
						U.Nombre,
						SP.IdContrato,
						SP.FechaEntregaFinRequerida,
						OT.IdAsignador,
						SP.MotivoUrgencia,
						SP.IdTipoProceso,
						SP.IdEstatusEliminado,
						TAO.FechaFinalizacion;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #LISTA_SOLPED);

				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					ISNULL(TP.TipoPedido, 'Sin clasificación') AS TipoProceso,--TipoProceso
					CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END AS FechaEntrega,--FechaEntrega
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
					END AS Cotizado,--Cotizado
					SP.FechaFinalizacion AS FechaFinalizacion, --FechaFinalizacion
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores, --Proveedores
					SP.MotivoUrgencia, --MotivoUrgencia
					TSP.TipoSolicitudPedido, --TipoSolicitudPedido
					CASE 
					WHEN PED.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConPedido, --ConPedido
					CASE
						WHEN PO.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConOferta,--ConOferta
					TP.IdTipoPedido AS IdTipoProceso,--IdTipoProceso
					SP.ComentarioInternoPO,--ComentarioInternoPO
					C.NumeroContrato AS Contrato,--Contrato
					ISNULL(CA.Compradores,'') AS IdAsignado,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					U.Nombre AS SolicitadoPor,
					PSP.Prioridad, 
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN #LISTA_SOLPED AS SP
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
					JOIN Adinco.dbo.CO_Contrato (NOLOCK) c
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido
						AND ISNULL(PED.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados (NOLOCK) AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE (
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
							SP.PeticionEnviada, 
							SP.IdTipoProceso, 
							TP.TipoPedido, 
							SP.IdEstatusEliminado, 
							TP.IdTipoPedido,
							TP.IdTipoPedido,
							SP.ComentarioInternoPO,
							C.NumeroContrato,
							CA.Compradores,
							PO.IdSolicitudPedido,
							PED.IdSolicitudPedido,
							SP.FechaFinalizacion
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


	END

	IF @Consulta = 5 -->SIN RESPUESTA DEL PROVEEDOR
	BEGIN
			
			INSERT INTO #LISTA_SOLPED
			SELECT
				SP.IdSolicitudPedido,
				SP.FechaAlta,
				SP.PeticionEnviada,
				SP.UnaSolaEntregaRequerida,
				SP.FechaEntregaRequerida,
				SP.FechaEntregaFinRequerida,
				SP.ComentarioInternoPO,
				SP.IdTipoSolicitudPedido,
				SP.IdPrioridadSolicitudPedido,
				SP.IdContrato,
				OT.IdAsignador,
				SP.MotivoUrgencia,
				SP.IdTipoProceso,
				SP.IdEstatusEliminado,
				TAO.FechaFinalizacion
			FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
				JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
					ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
						AND SP.IdProveedor = @IdProveedor
						AND SP.Activo = 1
						AND ISNULL(SP.Visible,1) = 1
						AND ISNULL(SP.IdEstatusEliminado,0) <> 1
						AND SP.PeticionEnviada = 1
				JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
						AND OT.IdEstatusOperacion = 2
						AND OT.IdTipoOperacion = 2
				LEFT JOIN dbo.MM_Pedido (NOLOCK) AS P
					ON SP.IdSolicitudPedido = P.IdSolicitudPedido 
				LEFT JOIN dbo.MM_Pedidos (NOLOCK) AS PS
					ON P.IdPedido = PS.IdIdentificador 
					 AND SP.IdProveedor = PS.IdProveedorCliente  
					 AND PS.IdTipoPedido IN (2, 4) --> MERCADEO/AD DIRECTO
				LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
				JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
				JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON SP.IdSolicitudPedido = TAO.IdDocumento
						AND TAO.IdTipoOperacion = 6
						AND DATEDIFF(MINUTE, TAO.FechaFinalizacion, GETDATE()) >= 0
			WHERE (SELECT 
						COUNT(PODI.IdPeticionOfertaDetalle) 
					FROM dbo.MM_PeticionOferta AS POI
					JOIN dbo.MM_PeticionOfertaDetalle AS PODI
						ON POI.IdPeticionOferta= PODI.IdPeticionOferta 
					WHERE 
						POI.IdSolicitudPedido = SP.IdSolicitudPedido
						AND ISNULL(POI.Cotizado,0) = 0) = (SELECT 
																COUNT(PODI.IdPeticionOfertaDetalle) 
															FROM dbo.MM_PeticionOferta AS POI
															JOIN dbo.MM_PeticionOfertaDetalle AS PODI
																ON PODI.IdPeticionOferta = POI.IdPeticionOferta
															WHERE 
																POI.IdSolicitudPedido = SP.IdSolicitudPedido)
					AND (CASE 
						WHEN ISNULL(@EsAdministrador,0) IN (0,1) 
							AND  SPC.IdSolicitudPedidoComprador IS NOT NULL 
							AND SPC.IdAsignadoA = @IdUsuario 
							AND SPC.Activo = 1 
						THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
							1
						WHEN  ISNULL(@EsAdministrador,0) = 1 
						THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
							1 
						ELSE 
							0  --> NO MOSTRAR NINGUNA 
					END) = 1
					AND (
						SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
						SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
						U.Nombre LIKE '%' + @Buscar + '%' OR
						dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
						)
			GROUP BY SP.IdSolicitudPedido,
						SP.FechaAlta,
						SP.PeticionEnviada,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.ComentarioInternoPO,
						SP.IdTipoSolicitudPedido,
						SP.IdPrioridadSolicitudPedido,
						U.Nombre,
						SP.IdContrato,
						SP.FechaEntregaFinRequerida,
						OT.IdAsignador,
						SP.MotivoUrgencia,
						SP.IdTipoProceso,
						SP.IdEstatusEliminado,
						TAO.FechaFinalizacion;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #LISTA_SOLPED);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					ISNULL(TP.TipoPedido, 'Sin clasificación') AS TipoProceso,--TipoProceso
					CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END AS FechaEntrega,--FechaEntrega
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
					END AS Cotizado,--Cotizado
					SP.FechaFinalizacion AS FechaFinalizacion, --FechaFinalizacion
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores, --Proveedores
					SP.MotivoUrgencia, --MotivoUrgencia
					TSP.TipoSolicitudPedido, --TipoSolicitudPedido
					CASE 
					WHEN PED.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConPedido, --ConPedido
					CASE
						WHEN PO.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConOferta,--ConOferta
					TP.IdTipoPedido AS IdTipoProceso,--IdTipoProceso
					SP.ComentarioInternoPO,--ComentarioInternoPO
					C.NumeroContrato AS Contrato,--Contrato
					ISNULL(CA.Compradores,'') AS IdAsignado,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					U.Nombre AS SolicitadoPor,
					PSP.Prioridad, 
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN #LISTA_SOLPED AS SP
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
					JOIN Adinco.dbo.CO_Contrato (NOLOCK) c
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido
						AND ISNULL(PED.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados (NOLOCK) AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE (
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
							SP.PeticionEnviada, 
							SP.IdTipoProceso, 
							TP.TipoPedido, 
							SP.IdEstatusEliminado, 
							TP.IdTipoPedido,
							TP.IdTipoPedido,
							SP.ComentarioInternoPO,
							C.NumeroContrato,
							CA.Compradores,
							PO.IdSolicitudPedido,
							PED.IdSolicitudPedido,
							SP.FechaFinalizacion
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


			END

	IF @Consulta = 6 -->NO COTIZADA
	BEGIN
			
			INSERT INTO #LISTA_SOLPED
			SELECT
				SP.IdSolicitudPedido,
				SP.FechaAlta,
				SP.PeticionEnviada,
				SP.UnaSolaEntregaRequerida,
				SP.FechaEntregaRequerida,
				SP.FechaEntregaFinRequerida,
				SP.ComentarioInternoPO,
				SP.IdTipoSolicitudPedido,
				SP.IdPrioridadSolicitudPedido,
				SP.IdContrato,
				OT.IdAsignador,
				SP.MotivoUrgencia,
				SP.IdTipoProceso,
				SP.IdEstatusEliminado,
				TAO.FechaFinalizacion
			FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
				JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
					ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
						AND SP.IdProveedor = @IdProveedor
						AND SP.Activo = 1
						AND ISNULL(SP.Visible,1) = 1
						AND ISNULL(SP.IdEstatusEliminado,0) <> 1
						AND SP.PeticionEnviada = 1
				JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
						AND OT.IdEstatusOperacion = 2
						AND OT.IdTipoOperacion = 2
				LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
				JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
				JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON TAO.IdDocumento = SP.IdSolicitudPedido
						AND TAO.IdTipoOperacion = 6
						AND TAO.IdProveedor = @IdProveedor
			WHERE (SELECT 
									COUNT(1)
								FROM dbo.MM_PeticionOferta AS POI
								LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
									ON POI.IdPeticionOferta=PODI.IdPeticionOferta  
								WHERE 
									POI.IdSolicitudPedido = SP.IdSolicitudPedido
									AND PODI.NoCotizar = 1) = (SELECT 
																	COUNT(1) 
																FROM dbo.MM_PeticionOferta AS POI
																	LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI
																		ON POI.IdPeticionOferta=PODI.IdPeticionOferta 
																WHERE 
																	POI.IdSolicitudPedido = SP.IdSolicitudPedido)
				AND (CASE 
						WHEN ISNULL(@EsAdministrador,0) IN (0,1) 
							AND  SPC.IdSolicitudPedidoComprador IS NOT NULL 
							AND SPC.IdAsignadoA = @IdUsuario 
							AND SPC.Activo = 1 
						THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
							1
						WHEN  ISNULL(@EsAdministrador,0) = 1 
						THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
							1 
						ELSE 
							0  --> NO MOSTRAR NINGUNA 
					END) = 1
					AND (
						SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
						SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
						U.Nombre LIKE '%' + @Buscar + '%' OR
						dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
						)
			GROUP BY SP.IdSolicitudPedido,
						SP.FechaAlta,
						SP.PeticionEnviada,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.ComentarioInternoPO,
						SP.IdTipoSolicitudPedido,
						SP.IdPrioridadSolicitudPedido,
						U.Nombre,
						SP.IdContrato,
						SP.FechaEntregaFinRequerida,
						OT.IdAsignador,
						SP.MotivoUrgencia,
						SP.IdTipoProceso,
						SP.IdEstatusEliminado,
						TAO.FechaFinalizacion;

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #LISTA_SOLPED);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					ISNULL(TP.TipoPedido, 'Sin clasificación') AS TipoProceso,--TipoProceso
					CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END AS FechaEntrega,--FechaEntrega
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
					END AS Cotizado,--Cotizado
					SP.FechaFinalizacion AS FechaFinalizacion, --FechaFinalizacion
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores, --Proveedores
					SP.MotivoUrgencia, --MotivoUrgencia
					TSP.TipoSolicitudPedido, --TipoSolicitudPedido
					CASE 
					WHEN PED.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConPedido, --ConPedido
					CASE
						WHEN PO.IdSolicitudPedido IS NOT NULL THEN 1
						ELSE 0
					END AS ConOferta,--ConOferta
					TP.IdTipoPedido  AS IdTipoProceso,--IdTipoProceso
					SP.ComentarioInternoPO,--ComentarioInternoPO
					C.NumeroContrato AS Contrato,--Contrato
					ISNULL(CA.Compradores,'') AS IdAsignado,
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					U.Nombre AS SolicitadoPor,
					PSP.Prioridad, 
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN #LISTA_SOLPED AS SP
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
					JOIN Adinco.dbo.CO_Contrato (NOLOCK) c
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido
						AND ISNULL(PED.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados (NOLOCK) AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE (
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
							SP.PeticionEnviada, 
							SP.IdTipoProceso, 
							TP.TipoPedido, 
							SP.IdEstatusEliminado, 
							TP.IdTipoPedido,
							TP.IdTipoPedido,
							SP.ComentarioInternoPO,
							C.NumeroContrato,
							CA.Compradores,
							PO.IdSolicitudPedido,
							PED.IdSolicitudPedido,
							SP.FechaFinalizacion
				) 
				AS R
				--WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC


			END

	IF @Consulta = 7  --> MOSTRAR TODAS 
	BEGIN
				
				INSERT INTO #LISTA_SOLPED(
					IdSolicitudPedido,
					FechaAlta,
					PeticionEnviada,
					UnaSolaEntregaRequerida,
					FechaEntregaRequerida,
					FechaEntregaFinRequerida,
					ComentarioInternoPO,
					IdTipoSolicitudPedido,
					IdPrioridadSolicitudPedido,
					IdContrato,
					IdAsignador,
					MotivoUrgencia,
					IdTipoProceso,
					IdEstatusEliminado,
					FechaFinalizacion
				)
				SELECT
					SP.IdSolicitudPedido,
					SP.FechaAlta,
					SP.PeticionEnviada,
					SP.UnaSolaEntregaRequerida,
					SP.FechaEntregaRequerida,
					SP.FechaEntregaFinRequerida,
					SP.ComentarioInternoPO,
					SP.IdTipoSolicitudPedido,
					SP.IdPrioridadSolicitudPedido,
					SP.IdContrato,
					OT.IdAsignador,
					SP.MotivoUrgencia,
					SP.IdTipoProceso,
					SP.IdEstatusEliminado,
					TAO.FechaFinalizacion
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
							AND SP.IdProveedor = @IdProveedor
							AND SP.Activo = 1
							AND ISNULL(SP.Visible,1) = 1
							AND ISNULL(SP.IdEstatusEliminado,0) <> 1
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON SP.IdSolicitudPedido = TAO.IdDocumento
						AND TAO.IdTipoOperacion = 6
						AND TAO.IdProveedor = @IdProveedor
				WHERE (CASE 
							WHEN ISNULL(@EsAdministrador,0) IN (0,1) 
								AND SPC.IdSolicitudPedidoComprador IS NOT NULL 
								AND SPC.IdAsignadoA = @IdUsuario 
								AND SPC.Activo = 1 
							THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 
							THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
							0  --> NO MOSTRAR NINGUNA 
					   END) = 1
					   AND (
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)
				GROUP BY SP.IdSolicitudPedido,
						SP.FechaAlta,
						SP.PeticionEnviada,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.ComentarioInternoPO,
						SP.IdTipoSolicitudPedido,
						SP.IdPrioridadSolicitudPedido,
						U.Nombre,
						SP.IdContrato,
						SP.FechaEntregaFinRequerida,
						OT.IdAsignador,
						SP.MotivoUrgencia,
						SP.IdTipoProceso,
						SP.IdEstatusEliminado,
						TAO.FechaFinalizacion;

				SET @AllRecords = (SELECT COUNT(1) FROM #LISTA_SOLPED);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					C.NumeroContrato AS Contrato,--Contrato
					U.Nombre AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					ISNULL(TP.TipoPedido, 'Sin clasificación') AS TipoProceso,--TipoProceso
					CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END AS FechaEntrega,--FechaEntrega
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
					END AS Cotizado,--Cotizado
					SP.FechaFinalizacion AS FechaFinalizacion, --FechaFinalizacion
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ),'---') AS Proveedores, --Proveedores
					SP.MotivoUrgencia, --MotivoUrgencia
					TSP.TipoSolicitudPedido, --TipoSolicitudPedido
					CASE 
						WHEN SUM(PED.IdPedido) > 1 THEN 1
						ELSE 0
					END AS ConPedido, --ConPedido
					CASE
						WHEN SUM(PO.IdPeticionOferta) > 1 THEN 1
						ELSE 0
					END AS ConOferta,--ConOferta
					TP.IdTipoPedido AS IdTipoProceso,--IdTipoProceso
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,--ComentarioInternoPO
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN #LISTA_SOLPED AS SP
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
					JOIN Adinco.dbo.CO_Contrato (NOLOCK) c
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido
						AND ISNULL(PED.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_SolicitudPedidoComprador  (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN #CompradoresAsignados AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE (
							SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
							SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
							U.Nombre LIKE '%' + @Buscar + '%' OR
							dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
						)
				GROUP BY SP.IdSolicitudPedido, --IdSolicitudPedido
						C.NumeroContrato,--Contrato
						U.Nombre,
						SP.FechaAlta,--FechaAlta
						SP.PeticionEnviada,
						TP.TipoPedido,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.FechaEntregaFinRequerida,
						SP.FechaFinalizacion,
						SP.MotivoUrgencia, --MotivoUrgencia
						TSP.TipoSolicitudPedido, --TipoSolicitudPedido
						TP.IdTipoPedido,
						CA.Compradores,
						SP.ComentarioInternoPO) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.FechaAlta DESC
		
		END

	IF @Consulta = 8  --> MOSTRAR TODAS SIN COMPRADOR ASIGNADO
	BEGIN

			INSERT INTO #LISTA_SOLPED
				SELECT
					SP.IdSolicitudPedido,
					SP.FechaAlta,
					SP.PeticionEnviada,
					SP.UnaSolaEntregaRequerida,
					SP.FechaEntregaRequerida,
					SP.FechaEntregaFinRequerida,
					SP.ComentarioInternoPO,
					SP.IdTipoSolicitudPedido,
					SP.IdPrioridadSolicitudPedido,
					SP.IdContrato,
					OT.IdAsignador,
					SP.MotivoUrgencia,
					SP.IdTipoProceso,
					SP.IdEstatusEliminado,
					TAO.FechaFinalizacion
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
							AND SP.IdProveedor = @IdProveedor
							AND SP.Activo = 1
							AND ISNULL(SP.Visible,1) = 1
							AND ISNULL(SP.IdEstatusEliminado,0) <> 1
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON TAO.IdDocumento = SP.IdSolicitudPedido
						AND TAO.IdTipoOperacion = 6
						AND TAO.IdProveedor = @IdProveedor
					LEFT JOIN #CompradoresAsignados (NOLOCK) AS CA	
						ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE LEN(RTRIM((LTRIM(ISNULL(CA.Compradores,'')))))=0 AND	--> SI NO TIENE COMPRADORES ASIGNADOS  
					(CASE 
							WHEN ISNULL(@EsAdministrador,0) IN (0,1) 
								AND  SPC.IdSolicitudPedidoComprador IS NOT NULL 
								AND SPC.IdAsignadoA = @IdUsuario 
								AND SPC.Activo = 1 
							THEN --MOSTRAR SOLAMENTE DONDE FUE ASIGNADO
								1
							WHEN  ISNULL(@EsAdministrador,0) = 1 
							THEN -->MOSTRAR TODAS SIN IMPORTAR SI FUE ASIGNADO O NO YA QUE ES ADMINISTRADOR
								1 
							ELSE 
							0  --> NO MOSTRAR NINGUNA 
					   END) = 1
					   AND (
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
							)

				GROUP BY SP.IdSolicitudPedido,
						SP.FechaAlta,
						SP.PeticionEnviada,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.ComentarioInternoPO,
						SP.IdTipoSolicitudPedido,
						SP.IdPrioridadSolicitudPedido,
						U.Nombre,
						SP.IdContrato,
						SP.FechaEntregaFinRequerida,
						OT.IdAsignador,
						SP.MotivoUrgencia,
						SP.IdTipoProceso,
						SP.IdEstatusEliminado,
						TAO.FechaFinalizacion;

				SET @AllRecords = (SELECT COUNT(1) FROM #LISTA_SOLPED);
				
				SELECT 
					*,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage
				FROM 
				(
				SELECT	
					C.NumeroContrato AS Contrato,--Contrato
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					U.Nombre AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE SP.UnaSolaEntregaRequerida
						WHEN 1 THEN CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 )
						WHEN 0 THEN CONCAT (CONVERT ( NVARCHAR, SP.FechaEntregaRequerida, 22 ), '|' ,CONVERT ( NVARCHAR, SP.FechaEntregaFinRequerida, 22 ))
					END AS FechaEntrega,--FechaEntrega
					TSP.TipoSolicitudPedido, --TipoSolicitudPedido
					PSP.Prioridad, 
					ISNULL(CA.Compradores,'') AS IdAsignado,
					SP.ComentarioInternoPO,--ComentarioInternoPO
					SP.MotivoUrgencia, --MotivoUrgencia
					ISNULL(@EsAdministrador,0) AS EsAdministrador,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					JOIN #LISTA_SOLPED AS SP
						ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
					JOIN Adinco.dbo.CO_Contrato (NOLOCK) c
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
						ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE (
							SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
							SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
							U.Nombre LIKE '%' + @Buscar + '%' OR
							dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
						)
				GROUP BY C.NumeroContrato,--Contrato
						SP.IdSolicitudPedido,
						U.Nombre,
						SP.FechaAlta,--FechaAlta
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.FechaEntregaFinRequerida,
						TSP.TipoSolicitudPedido, --TipoSolicitudPedido
						PSP.Prioridad, 
						CA.Compradores,
						SP.ComentarioInternoPO,--ComentarioInternoPO
						SP.MotivoUrgencia
				)
				AS R 
				WHERE R.R = 1
				AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC
			END

END
