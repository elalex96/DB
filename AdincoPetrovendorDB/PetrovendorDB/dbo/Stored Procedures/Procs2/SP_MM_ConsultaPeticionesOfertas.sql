-- =============================================
-- Author:		DANIEL AC
-- Create date: <21/09/2022>
-- Description:	Optimizacion del sp
-- =============================================
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <24/02/2022>
-- Description:	<Optimizacion del sp>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaPeticionesOfertas] 
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
		ComentarioInternoPO VARCHAR(3000),
		IdTipoSolicitudPedido INT,
		IdPrioridadSolicitudPedido INT,
		IdContrato INT,
		IdAsignador INT,
		MotivoUrgencia VARCHAR(MAX),
		IdTipoProceso INT,
		IdEstatusEliminado INT,
		FechaFinalizacion DATETIME		
	);
	CREATE NONCLUSTERED INDEX ix_tempLISTA_SOLPEDIdSolicitudPedido ON #LISTA_SOLPED (IdSolicitudPedido);
	CREATE NONCLUSTERED INDEX ix_tempLISTA_SOLPEDIdTipoSolicitudPedido ON #LISTA_SOLPED (IdTipoSolicitudPedido);
	CREATE NONCLUSTERED INDEX ix_tempLISTA_SOLPEDIdPrioridadSolicitudPedido ON #LISTA_SOLPED (IdPrioridadSolicitudPedido);
	CREATE NONCLUSTERED INDEX ix_tempLISTA_SOLPEDIdContrato ON #LISTA_SOLPED (IdContrato);
	CREATE NONCLUSTERED INDEX ix_tempLISTA_SOLPEDIdAsignador ON #LISTA_SOLPED (IdAsignador);
	CREATE NONCLUSTERED INDEX ix_tempLISTA_SOLPEDIdTipoProceso ON #LISTA_SOLPED (IdTipoProceso);

	CREATE TABLE #CompradoresAsignados(IdSolicitudPedido INT, Compradores NVARCHAR(MAX))
	CREATE NONCLUSTERED INDEX ix_tempCompradoresAsignadosIdSolicitudPedido ON #CompradoresAsignados (IdSolicitudPedido);

	CREATE TABLE #ProductosNoCotizados(IdSolicitudPedido INT, Cantidad INT)
	CREATE NONCLUSTERED INDEX ix_tempProductosNoCotizadosIdSolicitudPedido ON #CompradoresAsignados (IdSolicitudPedido);

	CREATE TABLE #ProductosCotizados(IdSolicitudPedido INT, Cantidad INT)
	CREATE NONCLUSTERED INDEX ix_tempProductosCotizadosIdSolicitudPedido ON #CompradoresAsignados (IdSolicitudPedido);

	CREATE TABLE #RequisionesNoCotizados(IdSolicitudPedido INT)
	CREATE NONCLUSTERED INDEX ix_tempRequisionesNoCotizadosIdSolicitudPedido ON #RequisionesNoCotizados (IdSolicitudPedido);
	
	CREATE TABLE #Solicitudes(
		IdSolicitudPedido INT,
		IdContrato INT		
	);

	CREATE NONCLUSTERED INDEX ix_tempSolicitudesIdSolicitudPedido ON #Solicitudes (IdSolicitudPedido);
	CREATE NONCLUSTERED INDEX ix_tempSolicitudesIdContrato ON #Solicitudes (IdContrato);

	CREATE TABLE #Contrato(		
		IdContrato INT,
		NumeroContrato VARCHAR(200)
	);	
	CREATE NONCLUSTERED INDEX ix_tempContratoIdContrato ON #Solicitudes (IdContrato);

	CREATE TABLE #Pagina(
		R INT, 
		IdSolicitudPedido INT,
		FechaAlta DATETIME,
		_Page BIGINT					
	);
	CREATE NONCLUSTERED INDEX ix_tempPaginaIdSolicitudPedido ON #Solicitudes (IdSolicitudPedido);
	

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

	-- OBTENER SOLICITUDES IDS QUE PUEDE VER EL USUARIO ACTUAL
	INSERT INTO #Solicitudes
	(
	IdSolicitudPedido,
	IdContrato	
	)
	SELECT 
	SP.IdSolicitudPedido,
	SP.IdContrato	
	FROM dbo.MM_SolicitudPedido (NOLOCK) SP
	LEFT JOIN dbo.MM_SolicitudPedidoComprador (NOLOCK) SPC 
				ON	SP.IdSolicitudPedido = SPC.IdSolicitudPedido
	WHERE SP.IdProveedor = @IdProveedor
	AND SP.Activo = 1
	AND ISNULL(SP.Visible,1) = 1
	AND ISNULL(SP.IdEstatusEliminado,0) <> 1
	AND (CASE 
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
	GROUP BY SP.IdSolicitudPedido,SP.IdContrato
	
	-- OBTENER CONTRATOS AGRUPADOS
	INSERT INTO #Contrato(IdContrato)
	SELECT IdContrato
	FROM #Solicitudes 
	GROUP BY IdContrato

	UPDATE CO
	SET CO.NumeroContrato= C.NumeroContrato
	FROM #Contrato CO
	JOIN Adinco.dbo.CO_Contrato AS C (NOLOCK)
        ON CO.IdContrato=C.IdContrato 


	IF @Consulta = 1  --> PENDIENTES DE ENVIAR 
	BEGIN

		INSERT INTO #LISTA_SOLPED (
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
		FechaFinalizacion)
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
		FROM #Solicitudes (NOLOCK) AS S
			JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
				ON S.IdSolicitudPedido = SP.IdSolicitudPedido
				AND (SP.PeticionEnviada = 0 OR SP.PeticionEnviada IS NULL )
			JOIN dbo.TA_Operacion (NOLOCK) AS OT
				ON SP.IdSolicitudPedido = OT.IdDocumento
					AND OT.IdEstatusOperacion = 2 --> SOLPED APROBADA
					AND OT.IdTipoOperacion = 2 --> APROBACIÓN DE SOLPED			
			LEFT JOIN dbo.S_Usuario (NOLOCK) AS U
				ON OT.IdAsignador = U.IdUsuario
			LEFT JOIN dbo.TA_Operacion (NOLOCK) AS TAO
				ON SP.IdSolicitudPedido = TAO.IdDocumento 
					AND TAO.IdTipoOperacion = 6 --> CTE 
					AND TAO.IdProveedor = @IdProveedor
		WHERE (
				SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
				SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
				U.Nombre LIKE '%' + @Buscar + '%')
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
				
			--OBTENER REQUISICIONES QUE SE VAN A MOSTRAR
			INSERT INTO #Pagina(R, IdSolicitudPedido,FechaAlta,_Page)
			SELECT 
				R.R,
				R.IdSolicitudPedido, 
				R.FechaAlta,
				R._Page
			FROM 
			(
			SELECT	
				ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
				SP.IdSolicitudPedido AS IdSolicitudPedido, 
				SP.FechaAlta,					
				(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
			FROM #LISTA_SOLPED AS SP
			)
			AS R 
			WHERE R.R = 1 AND R._Page = (@Page - 1)
			ORDER BY R.IdSolicitudPedido DESC

			--OBTENER COMPRADORES DE LA REQUISICIONES DE LA PAGINA ACTUAL
			INSERT INTO #CompradoresAsignados(IdSolicitudPedido,Compradores)
			SELECT 
				SP.IdSolicitudPedido, 
				(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA)
				FROM dbo.MM_SolicitudPedidoComprador SPC 
					JOIN dbo.S_Usuario (NOLOCK) U 
						ON SPC.IdAsignadoA=U.IdUsuario
					LEFT JOIN dbo.S_TipoUsuario (NOLOCK) TU 
						ON U.IdTipoUsuario=TU.IdTipoUsuario 			
				WHERE 		
					SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
					AND SPC.Activo=1
				FOR XML PATH ( '' )), 1, 1, '' ))
			FROM #PAGINA (NOLOCK) SP
			
			--RETORNAR INFORMACIÓN
			SELECT	
			R.R,
			SP.IdSolicitudPedido AS IdSolicitudPedido, 
			CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,
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
			R._Page,
			@AllRecords AS Records,
			@RecordsByPage AS RecordByPage
		FROM #PAGINA R
			JOIN #LISTA_SOLPED AS SP 
				ON R.IdSolicitudPedido = SP.IdSolicitudPedido
			JOIN dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
				ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
			JOIN #Contrato(NOLOCK) C
				ON SP.IdContrato = C.IdContrato
			JOIN dbo.S_Usuario (NOLOCK) AS U
				ON SP.IdAsignador = U.IdUsuario		
			LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
				ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
			LEFT JOIN #CompradoresAsignados AS CA	
				ON SP.IdSolicitudPedido = CA.IdSolicitudPedido				
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
				CA.Compradores,
				R._Page,						
				R.R

	END

	IF @Consulta = 2  --> ENVIADA VIGENTE
	BEGIN

				INSERT INTO #LISTA_SOLPED
				(
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
				FechaFinalizacion)
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
				FROM #Solicitudes S
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON S.IdSolicitudPedido = SP.IdTipoSolicitudPedido	
							AND SP.PeticionEnviada = 1
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2 --> APROBADA
							AND OT.IdTipoOperacion = 2	--> APROBACIÓN DE SOLPED				
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON  SP.IdSolicitudPedido = TAO.IdDocumento 
						AND TAO.IdTipoOperacion = 6 --> APROBACIÓN DE COTIZACIÓN
						AND TAO.IdProveedor = @IdProveedor
						AND DATEDIFF(MINUTE, TAO.FechaFinalizacion, GETDATE()) < 0					
				WHERE (
								SP.IdSolicitudPedido LIKE '%' + @Buscar + '%' OR
								SP.MotivoUrgencia LIKE '%' + @Buscar + '%' OR
								U.Nombre LIKE '%' + @Buscar + '%' OR
								dbo.Fn_ObtenerProveedoresPorSolPed (SP.IdSolicitudPedido ) LIKE '%' + @Buscar + '%'
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

					
				
				--OBTENER REQUISICIONES QUE SE VAN A MOSTRAR
				INSERT INTO #Pagina(R, IdSolicitudPedido,FechaAlta,_Page)
				SELECT 
					R.R,
					R.IdSolicitudPedido,
					R.FechaAlta,					
					R._Page					
				FROM 
				(
				   SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido		
					SP.FechaAlta,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM  #LISTA_SOLPED AS SP 
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.FechaAlta DESC

				--OBTENER COMPRADORES DE LA REQUISICIONES DE LA PAGINA ACTUAL
				INSERT INTO #CompradoresAsignados(IdSolicitudPedido,Compradores)
				SELECT 
					SP.IdSolicitudPedido, 
					(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA)
					FROM dbo.MM_SolicitudPedidoComprador SPC 
						JOIN dbo.S_Usuario (NOLOCK) U 
							ON SPC.IdAsignadoA=U.IdUsuario
						LEFT JOIN dbo.S_TipoUsuario (NOLOCK) TU 
							ON U.IdTipoUsuario=TU.IdTipoUsuario 			
					WHERE 		
						SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
						AND SPC.Activo=1
					FOR XML PATH ( '' )), 1, 1, '' ))
				FROM #PAGINA (NOLOCK) SP

			--RETORNAR INFORMACIÓN	
			SELECT	
			R.R,
			SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
			CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
			CASE 
				WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
				WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
			END AS EstatusOferta,--EstatusOferta
			dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
			CASE WHEN WPDI.MECANISMO_CONTRATACION ='L' THEN
						'Licitación'
			ELSE 
				ISNULL(TP.TipoPedido, 'Sin clasificación') END
			AS TipoProceso,--TipoProceso
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
			R._Page,
			@AllRecords AS Records,
			@RecordsByPage AS RecordByPage	
		FROM #PAGINA R
			JOIN #LISTA_SOLPED AS SP
				ON R.IdSolicitudPedido = SP.IdSolicitudPedido
			JOIN MM_TipoSolicitudPedido (NOLOCK) AS TSP
				ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
			JOIN #Contrato (NOLOCK) C
				ON SP.IdContrato = C.IdContrato
			JOIN dbo.S_Usuario (NOLOCK) AS U
				ON SP.IdAsignador = U.IdUsuario
			LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
				ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
				AND ISNULL(PO.IdEstatusEliminado,0) = 0
			LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
				ON SP.IdSolicitudPedido = PED.IdSolicitudPedido				
				AND ISNULL(PED.IdEstatusEliminado,0) = 0					
			LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
				ON	SP.IdTipoProceso = TP.IdTipoPedido
			LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
				ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
			LEFT JOIN #CompradoresAsignados AS CA	
				ON SP.IdSolicitudPedido = CA.IdSolicitudPedido		
			LEFT JOIN WDEA_PurchasingDocumentsImportados WPDI
				ON PED.IdPedido = WPDI.IdPedidoADINCO
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
					SP.FechaFinalizacion,					
					R._Page,						
					R.R	,
					WPDI.MECANISMO_CONTRATACION

			END

	IF @Consulta = 3 --> ENVIADA VENCIDA
	BEGIN

				INSERT INTO #LISTA_SOLPED
				(
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
					FechaFinalizacion)
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
				FROM #Solicitudes S
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON S.IdSolicitudPedido = SP.IdSolicitudPedido							
							AND SP.PeticionEnviada = 1
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2 --> ÁPROBADO
							AND OT.IdTipoOperacion = 2		--> APROBACIÓN DE SOLPED			
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON  SP.IdSolicitudPedido = TAO.IdDocumento 
						AND TAO.IdTipoOperacion = 6 --> OPERACIÓN DE COTIZACIÓN
						AND TAO.IdProveedor = @IdProveedor
						AND DATEDIFF(MINUTE, TAO.FechaFinalizacion, GETDATE()) >= 0					
				WHERE (
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

				--OBTENER REQUISICIONES QUE SE VAN A MOSTRAR
				INSERT INTO #Pagina(R, IdSolicitudPedido,FechaAlta,_Page)
				SELECT 
					R.R,
					R.IdSolicitudPedido, 
					R.FechaAlta,					 
					R._Page					
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					SP.FechaAlta,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM  #LISTA_SOLPED AS SP				
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC
				
				--OBTENER COMPRADORES DE LA REQUISICIONES DE LA PAGINA ACTUAL
				INSERT INTO #CompradoresAsignados(IdSolicitudPedido,Compradores)
				SELECT 
					SP.IdSolicitudPedido, 
					(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA)
					FROM dbo.MM_SolicitudPedidoComprador SPC 
						JOIN dbo.S_Usuario (NOLOCK) U 
							ON SPC.IdAsignadoA=U.IdUsuario
						LEFT JOIN dbo.S_TipoUsuario (NOLOCK) TU 
							ON U.IdTipoUsuario=TU.IdTipoUsuario 			
					WHERE 		
						SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
						AND SPC.Activo=1
					FOR XML PATH ( '' )), 1, 1, '' ))
				FROM #PAGINA (NOLOCK) SP
				
				--RETORNAR INFORMACIÓN
				SELECT	
					R.R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					CASE WHEN WPDI.MECANISMO_CONTRATACION ='L' THEN
						'Licitación'
					ELSE 
					ISNULL(TP.TipoPedido, 'Sin clasificación') END AS TipoProceso,--TipoProceso
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
					ISNULL(dbo.Fn_ObtenerProveedoresPorSolPed ( SP.IdSolicitudPedido),'---') AS Proveedores, --Proveedores
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
					R._Page,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage		
				FROM #PAGINA R
				JOIN #LISTA_SOLPED AS SP
					ON R.IdSolicitudPedido = SP.IdSolicitudPedido
					JOIN dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
						ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
					JOIN #Contrato (NOLOCK) C
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido						
						AND ISNULL(PED.IdEstatusEliminado,0) = 0					
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido		
					LEFT JOIN WDEA_PurchasingDocumentsImportados WPDI
						ON PED.IdPedido = WPDI.IdPedidoADINCO
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
							SP.FechaFinalizacion,							
							R._Page,						
							R.R,
							WPDI.MECANISMO_CONTRATACION
				 ORDER BY SP.FechaAlta DESC			
			


	END

	IF @Consulta = 4 -->COTIZADA
	BEGIN

				INSERT INTO #LISTA_SOLPED
				(
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
					FechaFinalizacion)
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
				FROM #Solicitudes S
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON S.IdSolicitudPedido = SP.IdSolicitudPedido							
						AND SP.PeticionEnviada = 1
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2 --> APROBADA
							AND OT.IdTipoOperacion = 2		 --> APROBACIÓN DE SOLPED 			
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON TAO.IdDocumento = SP.IdSolicitudPedido
						AND TAO.IdTipoOperacion = 6 --> APROBACIÓN DE COTIZACIÓN
						AND TAO.IdProveedor = @IdProveedor
					JOIN dbo.MM_PeticionOferta (NOLOCK) AS POF
						ON SP.IdSolicitudPedido = POF.IdSolicitudPedido
						AND ISNULL(POF.IdEstatusEliminado,0) = 0
					JOIN dbo.MM_PeticionOfertaDetalle (NOLOCK) AS POFD
					 ON POF.IdPeticionOferta = POFD.IdPeticionOferta
						 AND POF.Cotizado = 1
						 AND POFD.Cotizado = 1					
				WHERE (
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

				--OBTENER REQUISICIONES QUE SE VAN A MOSTRAR
				INSERT INTO #Pagina(R, IdSolicitudPedido,FechaAlta,_Page)
				SELECT 
					R.R,
					R.IdSolicitudPedido, 
					R.FechaAlta,					
					R._Page					
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					SP.FechaAlta,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM #LISTA_SOLPED AS SP				
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.FechaAlta DESC

				--OBTENER COMPRADORES DE LA REQUISICIONES DE LA PAGINA ACTUAL
				INSERT INTO #CompradoresAsignados(IdSolicitudPedido,Compradores)
				SELECT 
					SP.IdSolicitudPedido, 
					(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA)
					FROM dbo.MM_SolicitudPedidoComprador SPC 
						JOIN dbo.S_Usuario (NOLOCK) U 
							ON SPC.IdAsignadoA=U.IdUsuario
						LEFT JOIN dbo.S_TipoUsuario (NOLOCK) TU 
							ON U.IdTipoUsuario=TU.IdTipoUsuario 			
					WHERE 		
						SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
						AND SPC.Activo=1
					FOR XML PATH ( '' )), 1, 1, '' ))
				FROM #PAGINA (NOLOCK) SP

				--RETORNAR INFORMACIÓN
				SELECT 
					R.R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					CASE WHEN WPDI.MECANISMO_CONTRATACION ='L' THEN
						'Licitación'
					ELSE 
					ISNULL(TP.TipoPedido, 'Sin clasificación') END AS TipoProceso,--TipoProceso
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
					R._Page,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage	
				FROM #PAGINA R
					JOIN #LISTA_SOLPED AS SP
						ON R.IdSolicitudPedido = SP.IdSolicitudPedido
					JOIN dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
						ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
					JOIN #Contrato (NOLOCK) C
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido					
						AND ISNULL(PED.IdEstatusEliminado,0) = 0					
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados (NOLOCK) AS CA	
						ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
					LEFT JOIN WDEA_PurchasingDocumentsImportados WPDI
						ON PED.IdPedido = WPDI.IdPedidoADINCO
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
							SP.FechaFinalizacion,							
							R._Page,						
							R.R,
							WPDI.MECANISMO_CONTRATACION
				 ORDER BY SP.FechaAlta DESC

	END

	IF @Consulta = 5 -->SIN RESPUESTA DEL PROVEEDOR
	BEGIN
			
			INSERT INTO #LISTA_SOLPED
			(
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
				FechaFinalizacion)
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
			FROM #Solicitudes S
				JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
					ON S.IdSolicitudPedido = SP.IdSolicitudPedido					
						AND SP.PeticionEnviada = 1
				JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
						AND OT.IdEstatusOperacion = 2 --> APROBADA
						AND OT.IdTipoOperacion = 2 --> APRBACIÓN DE SOLPED
				JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
				JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON SP.IdSolicitudPedido = TAO.IdDocumento
						AND TAO.IdTipoOperacion = 6 --> APROBACIÓN DE COTIZACION
						AND DATEDIFF(MINUTE, TAO.FechaFinalizacion, GETDATE()) >= 0	
			WHERE (
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

				-- PRODUCTOS NO COTIZADOS
				INSERT INTO #ProductosNoCotizados(IdSolicitudPedido, Cantidad)
				SELECT SP.IdSolicitudPedido, COUNT(PODI.IdPeticionOfertaDetalle) 
				FROM #LISTA_SOLPED SP (NOLOCK) 
				LEFT JOIN dbo.MM_PeticionOferta AS POI (NOLOCK) 
					ON SP.IdSolicitudPedido = POI.IdSolicitudPedido
				LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI (NOLOCK) 
					ON POI.IdPeticionOferta= PODI.IdPeticionOferta 
				WHERE ISNULL(POI.Cotizado,0) = 0
				GROUP BY SP.IdSolicitudPedido

				-- PRODUCTOS SOLICITADOS A  COTIZAR
				INSERT INTO #ProductosCotizados(IdSolicitudPedido, Cantidad)
				SELECT 
					SP.IdSolicitudPedido,
					COUNT(PODI.IdPeticionOfertaDetalle) 
				FROM #LISTA_SOLPED SP (NOLOCK) 
				LEFT JOIN dbo.MM_PeticionOferta AS POI (NOLOCK) 
					ON SP.IdSolicitudPedido = POI.IdSolicitudPedido
				LEFT JOIN dbo.MM_PeticionOfertaDetalle AS PODI (NOLOCK) 
					ON PODI.IdPeticionOferta = POI.IdPeticionOferta				 
				GROUP BY SP.IdSolicitudPedido
				
				-- REUNIR REQUISICIONES QUE NO SE COTIZARON 
				INSERT INTO #RequisionesNoCotizados(IdSolicitudPedido)
				SELECT PNC.IdSolicitudPedido
				FROM #ProductosNoCotizados PNC					
				JOIN #ProductosCotizados PC 
					ON PNC.IdSolicitudPedido = PC.IdSolicitudPedido
				    AND ISNULL(PNC.Cantidad,0) =  ISNULL(PC.Cantidad,0) --> DONDE NO SE COTIZO LA MISMA CANTIDAD SOLICITADA 

				--> ELIMINAR SOLPEDS QUE NO SE COTIZARON
				DELETE  SP
				FROM #LISTA_SOLPED SP 
				LEFT JOIN #RequisionesNoCotizados RNO
					ON SP.IdSolicitudPedido = RNO.IdSolicitudPedido
				WHERE RNO.IdSolicitudPedido IS NULL 

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #LISTA_SOLPED);
				
				--OBTENER REQUISICIONES QUE SE VAN A MOSTRAR
				INSERT INTO #Pagina(R, IdSolicitudPedido,FechaAlta,_Page)
				SELECT 
					R.R,
					R.IdSolicitudPedido, 
					R.FechaAlta,					 
					R._Page					
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					SP.FechaAlta,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM #LISTA_SOLPED AS SP			
				) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.FechaAlta DESC

				--OBTENER COMPRADORES DE LA REQUISICIONES DE LA PAGINA ACTUAL
				INSERT INTO #CompradoresAsignados(IdSolicitudPedido,Compradores)
				SELECT 
					SP.IdSolicitudPedido, 
					(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA)
					FROM dbo.MM_SolicitudPedidoComprador SPC 
						JOIN dbo.S_Usuario (NOLOCK) U 
							ON SPC.IdAsignadoA=U.IdUsuario
						LEFT JOIN dbo.S_TipoUsuario (NOLOCK) TU 
							ON U.IdTipoUsuario=TU.IdTipoUsuario 			
					WHERE 		
						SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
						AND SPC.Activo=1
					FOR XML PATH ( '' )), 1, 1, '' ))
				FROM #PAGINA (NOLOCK) SP

				--RETORNAR INFORMACIÓN
				SELECT	
					R.R,					
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					CASE WHEN WPDI.MECANISMO_CONTRATACION ='L' THEN
						'Licitación'
					ELSE 
					ISNULL(TP.TipoPedido, 'Sin clasificación') END AS TipoProceso,--TipoProceso
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
					R._Page,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage		
				FROM #PAGINA R
					JOIN #LISTA_SOLPED AS SP
						ON R.IdSolicitudPedido = SP.IdSolicitudPedido
					JOIN dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP 
						ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
					JOIN #Contrato (NOLOCK) C
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido						
						AND ISNULL(PED.IdEstatusEliminado,0) = 0				
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados (NOLOCK) AS CA	
						ON SP.IdSolicitudPedido = CA.IdSolicitudPedido		
					LEFT JOIN WDEA_PurchasingDocumentsImportados WPDI
						ON PED.IdPedido = WPDI.IdPedidoADINCO	
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
							SP.FechaFinalizacion,							
							R._Page,						
							R.R,
							WPDI.MECANISMO_CONTRATACION
				 ORDER BY SP.FechaAlta DESC		

			END

	IF @Consulta = 6 -->NO COTIZADA
	BEGIN
			
			INSERT INTO #LISTA_SOLPED
			(
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
				FechaFinalizacion)
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
			FROM #Solicitudes S
				JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
					ON S.IdSolicitudPedido = SP.IdSolicitudPedido						
						AND SP.PeticionEnviada = 1
				JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
						AND OT.IdEstatusOperacion = 2
						AND OT.IdTipoOperacion = 2				
				JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
				JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON SP.IdSolicitudPedido = TAO.IdDocumento 
						AND TAO.IdTipoOperacion = 6
						AND TAO.IdProveedor = @IdProveedor				
			WHERE (
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

				-- PRODUCTOS NO COTIZADOS
				INSERT INTO #ProductosNoCotizados(IdSolicitudPedido, Cantidad)
				SELECT 
					SP.IdSolicitudPedido,
					COUNT(1)
				FROM #LISTA_SOLPED SP  (NOLOCK)
				JOIN dbo.MM_PeticionOferta AS POI  (NOLOCK)
					ON SP.IdSolicitudPedido = POI.IdSolicitudPedido
				JOIN dbo.MM_PeticionOfertaDetalle AS PODI  (NOLOCK)
					ON POI.IdPeticionOferta=PODI.IdPeticionOferta	
			    WHERE  PODI.NoCotizar = 1 --> MATERIALES QUE SE MARCARON COMO NO COTIZADOS				 
				GROUP BY SP.IdSolicitudPedido			

				-- PRODUCTOS SOLICITADOS A  COTIZAR
				INSERT INTO #ProductosCotizados(IdSolicitudPedido, Cantidad)
				SELECT 
					SP.IdSolicitudPedido,
					COUNT(1) 
				FROM  #LISTA_SOLPED SP  (NOLOCK)
				JOIN dbo.MM_PeticionOferta AS POI  (NOLOCK)
					ON SP.IdSolicitudPedido = POI.IdSolicitudPedido
				JOIN dbo.MM_PeticionOfertaDetalle AS PODI
						ON POI.IdPeticionOferta=PODI.IdPeticionOferta 				
				GROUP BY SP.IdSolicitudPedido

				-- REUNIR REQUISICIONES QUE NO SE COTIZARON 
				INSERT INTO #RequisionesNoCotizados(IdSolicitudPedido)
				SELECT PNC.IdSolicitudPedido
				FROM #ProductosNoCotizados PNC	  (NOLOCK)				
				JOIN #ProductosCotizados PC   (NOLOCK)
					ON PNC.IdSolicitudPedido = PC.IdSolicitudPedido
				WHERE ISNULL(PNC.Cantidad,0) =  ISNULL(PC.Cantidad,0) --> DONDE NO SE COTIZO LA MISMA CANTIDAD SOLICITADA 
				
				-- PRODUCTOS NO COTIZADOS POR QUE NO SE HA RECUPERADO QUE FUERON POR INVITACIÓN
				INSERT INTO #RequisionesNoCotizados(IdSolicitudPedido)
				SELECT 
					SP.IdSolicitudPedido					
				FROM #LISTA_SOLPED SP  (NOLOCK)
				LEFT JOIN dbo.MM_PeticionOferta AS POI  (NOLOCK)
					ON SP.IdSolicitudPedido = POI.IdSolicitudPedido				
			    WHERE  POI.IdPeticionOferta IS NULL --> MATERIALES QUE SE MARCARON COMO NO COTIZADOS				 
				GROUP BY SP.IdSolicitudPedido	

				--> ELIMINAR SOLPEDS QUE NO SE COTIZARON
				DELETE  SP
				FROM #LISTA_SOLPED SP (NOLOCK)
				LEFT JOIN #RequisionesNoCotizados RNO  (NOLOCK)
					ON SP.IdSolicitudPedido = RNO.IdSolicitudPedido
				WHERE RNO.IdSolicitudPedido IS NULL 

				SET @AllRecords = (SELECT COUNT(IdSolicitudPedido) FROM #LISTA_SOLPED);
				
				--OBTENER REQUISICIONES QUE SE VAN A MOSTRAR
				INSERT INTO #Pagina(R, IdSolicitudPedido,FechaAlta,_Page)
				SELECT 
					R.R,
					R.IdSolicitudPedido, 
					R.FechaAlta,					
					R._Page
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido	
					SP.FechaAlta,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM #LISTA_SOLPED AS SP 					
				) 
				AS R				
				ORDER BY R.FechaAlta DESC

				--OBTENER COMPRADORES DE LA REQUISICIONES DE LA PAGINA ACTUAL
				INSERT INTO #CompradoresAsignados(IdSolicitudPedido,Compradores)
				SELECT 
					SP.IdSolicitudPedido, 
					(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA)
					FROM dbo.MM_SolicitudPedidoComprador SPC 
						JOIN dbo.S_Usuario (NOLOCK) U 
							ON SPC.IdAsignadoA=U.IdUsuario
						LEFT JOIN dbo.S_TipoUsuario (NOLOCK) TU 
							ON U.IdTipoUsuario=TU.IdTipoUsuario 			
					WHERE 		
						SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
						AND SPC.Activo=1
					FOR XML PATH ( '' )), 1, 1, '' ))
				FROM #PAGINA (NOLOCK) SP

				--RETORNAR INFORMACIÓN
				SELECT	
					R.R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					CASE WHEN WPDI.MECANISMO_CONTRATACION ='L' THEN
						'Licitación'
					ELSE 
					ISNULL(TP.TipoPedido, 'Sin clasificación') END  AS TipoProceso,--TipoProceso
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
					R._Page,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage		
				FROM #PAGINA R
					JOIN #LISTA_SOLPED AS SP
					ON R.IdSolicitudPedido = SP.IdSolicitudPedido
					JOIN dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
						ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
					JOIN #Contrato (NOLOCK) C
						ON SP.IdContrato = C.IdContrato
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
						ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
						AND ISNULL(PO.IdEstatusEliminado,0) = 0
					LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
						ON SP.IdSolicitudPedido = PED.IdSolicitudPedido						
						AND ISNULL(PED.IdEstatusEliminado,0) = 0					
					LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
						ON	SP.IdTipoProceso = TP.IdTipoPedido
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados (NOLOCK) AS CA	
						ON SP.IdSolicitudPedido = CA.IdSolicitudPedido	
					LEFT JOIN WDEA_PurchasingDocumentsImportados WPDI
						ON PED.IdPedido = WPDI.IdPedidoADINCO
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
							SP.FechaFinalizacion,							
							R._Page,						
							R.R,
							WPDI.MECANISMO_CONTRATACION 
				 ORDER BY SP.FechaAlta DESC		

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
				FROM #Solicitudes S					
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON 	S.IdSolicitudPedido = SP.IdSolicitudPedido							
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2 --> CTE DE SOLPED APROBADO
							AND OT.IdTipoOperacion = 2 --> APROBACIÓN DE SOLPED					
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON SP.IdSolicitudPedido = TAO.IdDocumento
						AND TAO.IdTipoOperacion = 6  --> CTE APROBACIÓN DE COTIZACIÓN
						AND TAO.IdProveedor = @IdProveedor
				WHERE (
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
				
				--OBTENER REQUISICIONES QUE SE VAN A MOSTRAR
				INSERT INTO #Pagina(R, IdSolicitudPedido,FechaAlta,_Page)
				SELECT 
					R.R,
					R.IdSolicitudPedido, 
					R.FechaAlta,
					R._Page	
				FROM 
				(
				SELECT	
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedid
					SP.FechaAlta,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM #LISTA_SOLPED AS SP) 
				AS R
				WHERE R.R = 1 AND R._Page = (@Page - 1)
				ORDER BY R.FechaAlta DESC
				
				--OBTENER COMPRADORES DE LA REQUISICIONES DE LA PAGINA ACTUAL
				INSERT INTO #CompradoresAsignados(IdSolicitudPedido,Compradores)
				SELECT 
					SP.IdSolicitudPedido, 
					(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA)
					FROM dbo.MM_SolicitudPedidoComprador SPC 
						JOIN dbo.S_Usuario (NOLOCK) U 
							ON SPC.IdAsignadoA=U.IdUsuario
						LEFT JOIN dbo.S_TipoUsuario (NOLOCK) TU 
							ON U.IdTipoUsuario=TU.IdTipoUsuario 			
					WHERE 		
						SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
						AND SPC.Activo=1
					FOR XML PATH ( '' )), 1, 1, '' ))
				FROM #PAGINA (NOLOCK) SP

				--RETORNAR INFORMACIÓN
				SELECT 
					R.R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					C.NumeroContrato AS Contrato,--Contrato
					U.Nombre AS SolicitadoPor,
					CONVERT ( NVARCHAR,SP.FechaAlta, 22 ) AS FechaAlta,--FechaAlta
					CASE 
						WHEN SP.PeticionEnviada = 1 THEN 'Enviada'
						WHEN ISNULL(SP.PeticionEnviada,0) = 0 THEN 'Pendiente de Enviar'
					END AS EstatusOferta,--EstatusOferta
					dbo.Fn_ObtenerInstalacionesPorSolPed ( SP.IdSolicitudPedido ) AS Instalaciones,-- Instalaciones
					CASE WHEN WPDI.MECANISMO_CONTRATACION ='L' THEN
						'Licitación'
					ELSE 
					ISNULL(TP.TipoPedido, 'Sin clasificación') 
					END AS TipoProceso,--TipoProceso
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
					R._Page,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage		
				FROM #PAGINA R
				JOIN #LISTA_SOLPED AS SP
					ON R.IdSolicitudPedido = SP.IdSolicitudPedido
				JOIN dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP
					ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
				JOIN #Contrato (NOLOCK) C
					ON SP.IdContrato = C.IdContrato
				JOIN #Solicitudes S
					ON  SP.IdSolicitudPedido = S.IdSolicitudPedido
				LEFT JOIN dbo.S_Usuario (NOLOCK) AS U
					ON SP.IdAsignador = U.IdUsuario
				LEFT JOIN dbo.MM_PeticionOferta (NOLOCK) AS PO
					ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
					AND ISNULL(PO.IdEstatusEliminado,0) = 0
				LEFT JOIN dbo.MM_Pedido (NOLOCK) AS PED
					ON SP.IdSolicitudPedido = PED.IdSolicitudPedido					
					AND ISNULL(PED.IdEstatusEliminado,0) = 0					
				LEFT JOIN dbo.MM_TipoPedido (NOLOCK) AS TP
					ON	SP.IdTipoProceso = TP.IdTipoPedido
				LEFT JOIN #CompradoresAsignados AS CA	
					ON SP.IdSolicitudPedido = CA.IdSolicitudPedido	
				LEFT JOIN WDEA_PurchasingDocumentsImportados WPDI
					ON PED.IdPedido = WPDI.IdPedidoADINCO
				GROUP BY SP.IdSolicitudPedido,
						C.NumeroContrato,
						U.Nombre,
						SP.FechaAlta,
						SP.PeticionEnviada,
						TP.TipoPedido,
						SP.UnaSolaEntregaRequerida,
						SP.FechaEntregaRequerida,
						SP.FechaEntregaFinRequerida,
						SP.FechaFinalizacion,
						SP.MotivoUrgencia, 
						TSP.TipoSolicitudPedido, 
						TP.IdTipoPedido,
						CA.Compradores,
						SP.ComentarioInternoPO,	
						WPDI.MECANISMO_CONTRATACION,
						R._Page,						
						R.R
				 ORDER BY SP.FechaAlta DESC

		END

	IF @Consulta = 8  --> MOSTRAR TODAS SIN COMPRADOR ASIGNADO
	BEGIN
			
		--OBTENER COMPRADORES DE LA REQUISICIONES 
			INSERT INTO #CompradoresAsignados(IdSolicitudPedido,Compradores)
			SELECT 
				SP.IdSolicitudPedido, 
				(SELECT	STUFF ((SELECT CAST(',' AS VARCHAR(MAX)) + ISNULL(U.Nombre,'') + ISNULL('('+TU.NombreTipoUsuario+')','')+ '|'  + CONVERT ( NVARCHAR(MAX), SPC.IdAsignadoA)
				FROM dbo.MM_SolicitudPedidoComprador SPC 
					JOIN dbo.S_Usuario (NOLOCK) U 
						ON SPC.IdAsignadoA=U.IdUsuario
					LEFT JOIN dbo.S_TipoUsuario (NOLOCK) TU 
						ON U.IdTipoUsuario=TU.IdTipoUsuario 			
				WHERE 		
					SPC.IdSolicitudPedido = SP.IdSolicitudPedido	
					AND SPC.Activo=1
				FOR XML PATH ( '' )), 1, 1, '' ))
			FROM #Solicitudes (NOLOCK) SP

			INSERT INTO #LISTA_SOLPED
			(
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
				FechaFinalizacion)
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
				FROM #Solicitudes S
					JOIN dbo.MM_SolicitudPedido (NOLOCK) AS SP 
						ON S.IdSolicitudPedido = SP.IdSolicitudPedido						
					JOIN dbo.TA_Operacion (NOLOCK) AS OT
						ON SP.IdSolicitudPedido = OT.IdDocumento
							AND OT.IdEstatusOperacion = 2
							AND OT.IdTipoOperacion = 2					
					JOIN dbo.S_Usuario (NOLOCK) AS U
						ON OT.IdAsignador = U.IdUsuario
					LEFT JOIN dbo.TA_Operacion (NOLOCK) AS TAO
						ON SP.IdSolicitudPedido = TAO.IdDocumento 
						AND TAO.IdTipoOperacion = 6 --> CTE DE APROBACIÓN DE COTIZACIÓN
						AND TAO.IdProveedor = @IdProveedor
					LEFT JOIN #CompradoresAsignados (NOLOCK) AS CA	
						ON SP.IdSolicitudPedido = CA.IdSolicitudPedido
				WHERE LEN(RTRIM((LTRIM(ISNULL(CA.Compradores,'')))))=0 	--> SI NO TIENE COMPRADORES ASIGNADOS
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
				
				--OBTENER REQUISICIONES QUE SE VAN A MOSTRAR
				INSERT INTO #Pagina(R, IdSolicitudPedido,FechaAlta,_Page)
				SELECT 					
					R.R,
					R.IdSolicitudPedido, 
					R.FechaAlta,
					R._Page				
				FROM 
				(
				SELECT						
					ROW_NUMBER() OVER(PARTITION BY SP.IdSolicitudPedido ORDER BY SP.IdSolicitudPedido DESC) AS R,
					SP.IdSolicitudPedido AS IdSolicitudPedido, --IdSolicitudPedido
					SP.FechaAlta,
					(ROW_NUMBER() OVER(ORDER BY SP.IdSolicitudPedido DESC) - 1)/ @RecordsByPage AS _Page
				FROM #LISTA_SOLPED AS SP
				)
				AS R 
				WHERE R.R = 1
				AND R._Page = (@Page - 1)
				ORDER BY R.IdSolicitudPedido DESC
								
				
				--RETORNAR INFORMACIÓN
				SELECT	
					C.NumeroContrato AS Contrato,--Contrato	
					R.R,									
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
					R._Page,
					@AllRecords AS Records,
					@RecordsByPage AS RecordByPage		
				FROM #PAGINA R
					JOIN #LISTA_SOLPED AS SP
						ON R.IdSolicitudPedido = SP.IdSolicitudPedido
					JOIN dbo.MM_TipoSolicitudPedido (NOLOCK) AS TSP 
						ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido 
					JOIN #Contrato (NOLOCK) C
						ON SP.IdContrato = C.IdContrato
					LEFT JOIN dbo.S_Usuario (NOLOCK) AS U
						ON SP.IdAsignador = U.IdUsuario					
					LEFT JOIN dbo.MM_PrioridadSolicitudPedido (NOLOCK) AS PSP
						ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
					LEFT JOIN #CompradoresAsignados AS CA (NOLOCK)
						ON SP.IdSolicitudPedido = CA.IdSolicitudPedido				
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
						SP.MotivoUrgencia,
						R._Page,						
						R.R
				 ORDER BY SP.FechaAlta DESC

			END

END