USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[Mobile_sp_AprobacionesPorUsuarioContador]    Script Date: 18/01/2022 11:18:26 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[Mobile_sp_AprobacionesPorUsuarioContador] --Mobile_sp_AprobacionesPorUsuarioContador 10067
@IdUsuario INT
as
begin 
	declare @PROVEDORRFC NVARCHAR(20),
			@SIGAPROBADOR INT,
			@TIPOFLUJO int,
			@IdProveedorCursor AS nvarchar(400), --Sustituirá al IdProveedor en el cursor,
			@IdUsuarioP int;
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
SET @IdUsuarioP = (SELECT IdUsuario FROM Petrovendor.dbo.S_Usuario WHERE IdUsuarioADINCO = @IdUsuario);
-- SE CREA UNA TABLA PARA TODOS LOS REGISTROS DE TODOS LOS CONTRATOS // SIMILAR A AM_APROBACION
		DROP TABLE IF EXISTS #TM_Aprobacion
		CREATE TABLE #TM_Aprobacion
		(
			[IdTipoAprobacion] [int] NULL,
			[IdStatusAprobacionM] [int] NULL,
			[IdTareaOrigen] [int] NULL,
			[IdContrato] [int] NULL,
			[FechaCreacion] [datetime] NULL,
			[IdDocumento] [int] NULL,
			[ComentarioDocumento] [nvarchar] (max) ,
			[ComentarioAprobacion] [nvarchar] (max),
			[NoVersion] [int] NULL,
			[TipoFlujo] [int] NULL,
			[IdPedido] [int] NULL
		) 
-- SE CREA UNA TABLA PARA TODOS LOS PROVEDDORES QUE TIENE UN USUARIO ADINCO 
		DROP TABLE IF EXISTS #IdsProveedore
		CREATE TABLE #IdsProveedore
		(
			IdProveedor INT NOT null
		)
--SE INSERTAN LOS IDS DE PROVEEDORES QUE TIENE UN USUARIO
		INSERT INTO #IdsProveedore
		(
			IdProveedor
		)
		SELECT 
			up.IdProveedor FROM 
						Petrovendor.dbo.s_usuario u 
						JOIN Petrovendor.dbo.S_UsuarioProveedor AS up
						ON u.IdUsuario = up.IdUsuario  
		WHERE u.IdUsuarioADINCO = @IdUsuario
-- SE CREA UNA TABLA PARA LOS idOperacion de los pedimentos comprobantes
		CREATE TABLE #IdOperaciones
		(
			IdOperacion INT NOT NULL
		)
----------------------------------------
		DECLARE @FlujoSerial TABLE
				(
					IdOperacion INT,
					NoSecuencia INT
				);
		DECLARE @OperacionNoAprobadas TABLE (IdOperacion INT);
----------------------------------------------------------------
----------------------------------------------------------------
---------------------APROBACIÓN DE SOLICITUDES DE PEDIDO (2)----------------------
----------------------------------------------------------------

--IF @IdTipo  = 2 -- SI SON SOLPED HACE ESTO
--BEGIN
--se crea el cursor de para SOLPED
	BEGIN
			DECLARE CursorSolucitudesPedido CURSOR FOR SELECT DISTINCT(IdProveedor) FROM #IdsProveedore
	END
	OPEN CursorSolucitudesPedido

		FETCH NEXT FROM CursorSolucitudesPedido INTO @IdProveedorCursor

		WHILE @@fetch_status = 0

		BEGIN
			INSERT INTO #TM_Aprobacion
			(
				IdTipoAprobacion,
				IdStatusAprobacionM,
				IdTareaOrigen,
				IdContrato,
				FechaCreacion,
				IdDocumento,
				ComentarioDocumento,
				ComentarioAprobacion,
				NoVersion,
				TipoFlujo,
				IdPedido
			)
			SELECT O.IdTipoOperacion AS IdTipoAprobacion,
				t.IdEstatus AS IdStatusAprobacionM,
				t.IdTarea AS 'IdTareaOrigen',
				SP.IdContrato,
				O.FechaRegistro AS FechaCreacion,
				O.IdDocumento,
				'Solicitud de pedido' AS ComentarioDocumento, 
				O.Descripcion AS ComentarioAprobacion,
				NULL AS 'NoVersion',
				TF.IdFlujoTarea AS TipoFlujo, 
				NULL AS IdPedido
				FROM Petrovendor.dbo.TA_Operacion AS O 
				INNER JOIN Petrovendor.dbo.TA_TipoOperacion AS OT ON O.IdTipoOperacion = OT.IdTipoOperacion
				INNER JOIN Petrovendor.dbo.TA_Estatus AS E ON O.IdEstatusOperacion = E.IdEstatus 
				INNER JOIN Petrovendor.dbo.TA_TareaOperacion AS TTO ON O.IdOperacion = TTO.IdOperacion 
				INNER JOIN Petrovendor.dbo.TA_Tarea AS T ON TTO.IdTarea = T.IdTarea 
				INNER JOIN Petrovendor.dbo.MM_SolicitudPedido AS SP ON O.IdDocumento = SP.IdSolicitudPedido 
				INNER JOIN Petrovendor.dbo.TA_FlujoTarea AS TF ON O.IdFlujoTarea = TF.IdFlujoTarea 
				WHERE T.IdAprobador = @IdUsuarioP
				AND O.IdTipoOperacion = 2
				AND t.IdEstatus = 1
				AND O.IdProveedor = @IdProveedorCursor
				AND ISNULL(O.IdEstatusEliminado, 0) <> 1  --> MOSTRAR NO ELIMINADAS 
				AND O.IdOperacion NOT IN (SELECT IdOperacion FROM Petrovendor.dbo.FN_FlujoSerialNoAprobados(@IdUsuarioP,@IdProveedorCursor,2))

			FETCH NEXT FROM CursorSolucitudesPedido INTO @IdProveedorCursor
		END

		CLOSE CursorSolucitudesPedido
		DEALLOCATE CursorSolucitudesPedido
--END
----------------------------------------------------------------
----------------------------------------------------------------
------------------------ APROBACIÓN DE PEDIDO (9)---------------
----------------------------------------------------------------
---------------------------------------------------------------
--IF @IdTipo = 9 -- SI SON PEDIDO HACE ESTO OTRO
--BEGIN
	DECLARE @IdProveedorCursorPedido AS nvarchar(400) --Sustituirá al IdProveedor en el cursor
	BEGIN
			DECLARE CursorPedido CURSOR FOR SELECT DISTINCT(IdProveedor) FROM #IdsProveedore
	END
	OPEN CursorPedido

		FETCH NEXT FROM CursorPedido INTO @IdProveedorCursorPedido

		WHILE @@fetch_status = 0

		BEGIN
	------------------------------------------------------------------------------------
		INSERT INTO @FlujoSerial
		(
			IdOperacion,
			NoSecuencia
		)
		SELECT O.IdOperacion,
			   t.NoSecuencia
		FROM Petrovendor.dbo.TA_Operacion O
			LEFT JOIN Petrovendor.dbo.MM_Pedido p
				ON O.IdDocumento = p.IdSolicitudPedido 
				   AND O.NoVersion = p.Version 
			INNER JOIN Petrovendor.dbo.TA_Tarea t
				ON O.IdOperacion = t.IdOperacion 
		WHERE O.IdTipoOperacion = 9
			  AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
			  AND t.IdAprobador = @IdUsuarioP
			  AND t.NoSecuencia > 1;
		INSERT INTO @OperacionNoAprobadas
		(
			IdOperacion
		)
		SELECT O.IdOperacion
		FROM Petrovendor.dbo.TA_Operacion O
			INNER JOIN @FlujoSerial f
				ON f.IdOperacion = O.IdOperacion
			INNER JOIN Petrovendor.dbo.TA_Tarea T
				ON T.IdOperacion = O.IdOperacion
				   AND T.NoSecuencia = (f.NoSecuencia - 1)
		WHERE O.IdTipoOperacion = 9
			  AND T.IdEstatus <> 2;
		INSERT INTO #TM_Aprobacion
	(
		IdTipoAprobacion,
		IdStatusAprobacionM,
		IdTareaOrigen,
		IdContrato,
		FechaCreacion,
		IdDocumento,
		ComentarioDocumento,
		ComentarioAprobacion,
		NoVersion,
		TipoFlujo,
		IdPedido
	) SELECT 
			O.IdTipoOperacion,
			t.IdEstatus AS [IdStatusAprobacionM],
			t.IdTarea AS [IdTareaOrigen],
			p.IdContrato,
			O.FechaRegistro AS [FechaCreacion],
			O.IdDocumento,
			'Solicitud de pedido' AS ComentarioDocumento, 
			o.Descripcion AS ComentarioAprobacion,
			P.Version AS 'NoVersion',
			P2.IdPedido,
			P2.IdPedido
		FROM Petrovendor.dbo.TA_Operacion AS O
			LEFT JOIN Petrovendor.dbo.MM_Pedido AS P ON O.IdDocumento = P.IdSolicitudPedido
			INNER JOIN    Petrovendor.dbo.MM_Pedidos P2 ON P.IdPedido = P2.IdIdentificador
			LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido SP ON P.IdSolicitudPedido = SP.IdSolicitudPedido 
			LEFT JOIN Petrovendor.dbo.TA_Estatus AS E ON O.IdEstatusOperacion = E.IdEstatus
			LEFT JOIN Petrovendor.dbo.TA_Tarea AS T ON O.IdOperacion = T.IdOperacion
			LEFT JOIN Petrovendor.dbo.S_Usuario U ON T.IdAprobador = U.IdUsuario
			LEFT JOIN Petrovendor.dbo.S_UsuarioProveedor UP ON U.IdUsuario = UP.IdUsuario
												   AND SP.IdContrato = UP.IdContrato
												   AND O.IdProveedor = UP.IdProveedor
			LEFT JOIN Petrovendor.dbo.S_Proveedor prov ON P.IdSubcontratista = prov.IdProveedor
		WHERE T.IdAprobador = @IdUsuarioP
			  AND O.IdProveedor = @IdProveedorCursorPedido
			  AND O.IdTipoOperacion = 9
			  AND P.Version = O.NoVersion
			  AND t.IdEstatus = 1
			  AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
			  AND ISNULL(p.IdEstatusEliminado, 0) <> 1 -->Pedido no eliminado
			  AND O.IdOperacion NOT IN (
										   SELECT IdOperacion FROM @OperacionNoAprobadas
									   )
		ORDER BY P2.IdPedido
	
		FETCH NEXT FROM CursorPedido INTO @IdProveedorCursorPedido
		END 
		CLOSE CursorPedido
		DEALLOCATE CursorPedido
--END
----------------------------------------------------------------
----------------------------------------------------------------
------------------------ APROBACIÓN DE COMPRA DIRECTA (14) -----
----------------------------------------------------------------
---------------------------------------------------------------
--IF @IdTipo = 14
--BEGIN
	DECLARE @IdProveedorCursorComprasDirecta AS nvarchar(400) --Sustituirá al IdProveedor en el cursor
	BEGIN
			DECLARE CursorCompraDirecta CURSOR FOR SELECT DISTINCT(IdProveedor) FROM #IdsProveedore
	END
	OPEN CursorCompraDirecta

		FETCH NEXT FROM CursorCompraDirecta INTO @IdProveedorCursorComprasDirecta

		WHILE @@fetch_status = 0

		BEGIN
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
			INSERT INTO #TM_Aprobacion
	(
		IdTipoAprobacion,
		IdStatusAprobacionM,
		IdTareaOrigen,
		IdContrato,
		FechaCreacion,
		IdDocumento,
		ComentarioDocumento,
		ComentarioAprobacion,
		NoVersion,
		TipoFlujo,
		IdPedido
	)SELECT 14 as IdTipoAprobacion,
			1 as IdStatusAprobacionM,
			TA.IdTarea AS IdTareaOrigen,
			C.IdContrato as IdContrato,
			fac.FechaTimbrado as FechaCreacion,
			O.IdDocumento as IdDocumento, 
			CONCAT(' Emisor: ',fac.Emisor ,' ','|',' Monto ejercido: ',((fac.MontoConIva * 100)/100),' ',fac.Moneda collate SQL_Latin1_General_CP1_CI_AS,' ','|',' Instalación:',instalacion.NombreInstalacion) AS ComentarioDocumento,
			O.Descripcion AS ComentarioAprobacion,
			0 as NoVersion,			
			O.IdFlujoTarea as TipoFlujo,
			PG.IdPedido as IdPedido
	FROM Petrovendor..S_Usuario      
		LEFT JOIN Petrovendor..TA_Tarea TA
				ON Petrovendor..S_Usuario.IdUsuario = TA.IdAprobador 
		LEFT JOIN Petrovendor..TA_Operacion O
				ON TA.IdOperacion = O.IdOperacion
		LEFT JOIN Petrovendor..TA_Vencimiento vigencia
				ON O.IdVigencia = vigencia.IdVencimiento 
		LEFT JOIN Petrovendor..MM_Pedidos PG
				ON O.IdDocumento = PG.IdIdentificador 
			   AND O.IdProveedor = PG.IdProveedorCliente
			   AND PG.IdTipoPedido = 1 
		LEFT JOIN Petrovendor..FI_Factura fac
				ON O.IdDocumento = fac.IdFactura       
		LEFT JOIN Petrovendor..CO_Registro reg
				ON fac.IdFactura = reg.IdFactura 
		LEFT JOIN Adinco.dbo.CO_Instalacion instalacion
				ON reg.IdInstalacion = instalacion.IdInstalacion 
		LEFT JOIN Petrovendor..S_UsuarioProveedor UP
				ON Petrovendor..S_Usuario.IdUsuario = UP.IdUsuario 
		LEFT JOIN Adinco.dbo.CO_Contrato AS C
			ON fac.IdContrato = C.IdContrato    
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC
			ON C.IdAreaContractual = AC.IdAreaContractual
	WHERE O.IdEstatusOperacion = 1
		AND O.IdTipoOperacion = 14
		AND S_Usuario.IdUsuario = @IdUsuarioP
		AND UP.IdProveedor = @IdProveedorCursorComprasDirecta
		AND fac.IdContrato = UP.idContrato
		AND O.IdOperacion NOT IN (SELECT IdOperacion FROM Petrovendor..FN_FlujoSerialNoAprobados(@IdUsuarioP,@IdProveedorCursorComprasDirecta,14))
	ORDER BY O.IdOperacion DESC;
------------------------------------------------------------------------------------
------------------------------------------------------------
		FETCH NEXT FROM CursorCompraDirecta INTO @IdProveedorCursorComprasDirecta
		END 
		CLOSE CursorCompraDirecta
		DEALLOCATE CursorCompraDirecta
	
--END
----------------------------------------------------------------
----------------------------------------------------------------
------------------------ APROBACIÓN DE PEDIMENTO COMPROBANTE (19)
----------------------------------------------------------------
---------------------------------------------------------------
--IF @IdTipo = 19
--BEGIN
	DECLARE @IdProveedorCursorPedimentoComprobante AS nvarchar(400) --Sustituirá al IdProveedor en el cursor
	BEGIN
			DECLARE CursorPedimentoComprobante CURSOR FOR SELECT DISTINCT(IdProveedor) FROM #IdsProveedore
	END
	OPEN CursorPedimentoComprobante

		FETCH NEXT FROM CursorPedimentoComprobante INTO @IdProveedorCursorPedimentoComprobante

		WHILE @@fetch_status = 0

		BEGIN
------------------------------------------------------------------------------------
---------------- SE INSERTAN LOS IdOperacion de todos los contratos
------------------------------------------------------------------------------------
			INSERT INTO #IdOperaciones (IdOperacion)SELECT
					OP.IdOperacion as TipoFlujo
				FROM Petrovendor..FI_AceptacionPedido_PedimentoComprobante AS APC
					JOIN Petrovendor..TA_Operacion AS OP
						ON APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento 
						AND OP.IdTipoOperacion = 19
						AND APC.IdProveedor = OP.IdProveedor 
					JOIN Petrovendor..FI_PedimentoComprobante AS PC
						ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante 
					JOIN Petrovendor..S_Usuario AS US
						ON APC.CreadoPor = US.IdUsuario 
					JOIN Adinco.dbo.PV_Subcontratista AS PVS
						ON PC.IdSubcontratistaExportador = PVS.IdSubcontratista 
					JOIN Adinco.dbo.PV_TipoMoneda AS TM
						ON PC.IdMoneda = TM.IdMoneda 
					JOIN Petrovendor..TA_Estatus AS ET
						ON OP.IdEstatusOperacion = ET.IdEstatus
					LEFT JOIN Petrovendor.dbo.TA_Tarea AS T ON OP.IdOperacion = T.IdOperacion 
				WHERE 
					APC.IdProveedor = @IdProveedorCursorPedimentoComprobante
					AND 
					APC.Activo = 1
					AND T.IdEstatus = 1
					AND T.IdAprobador = @IdUsuarioP
					AND OP.IdTipoOperacion = 19
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------
------------------------------------------------------------
		FETCH NEXT FROM CursorPedimentoComprobante INTO @IdProveedorCursorPedimentoComprobante
		END 
		CLOSE CursorPedimentoComprobante
		DEALLOCATE CursorPedimentoComprobante
------------------------------------------------------------------------------------
--------------- SE TERMINA EL CURSOS QUE INSERTAN LOS IDOPERACION ------------------
------------------------------------------------------------------------------------

------------------------------------------------------------------------------------
----------------- SE COMIENZAN A INSERTAR LOS PEDIMENTOS COMPROBANTES CON VALIDACIÓN EN EL IDOPERACION ---------------

DECLARE @IdOperacionCursor AS nvarchar(400) --Sustituirá al IdOperacion en el cursor
	BEGIN
			DECLARE CursorIdOperacion CURSOR FOR SELECT DISTINCT(IdOperacion) FROM #IdOperaciones
	END
	OPEN CursorIdOperacion
		FETCH NEXT FROM CursorIdOperacion INTO @IdOperacionCursor
		WHILE @@fetch_status = 0
		BEGIN
		 set @TIPOFLUJO = (SELECT  
         FT.IdTipoFlujo  
        FROM Petrovendor..TA_Operacion AS OP  
        JOIN Petrovendor..TA_FlujoTarea AS FT   
         ON OP.IdFlujoTarea  =FT.IdFlujoTarea 
        WHERE OP.IdOperacion = @IdOperacionCursor); 
		
		IF @TIPOFLUJO = 1 -- Flujo Serial
		BEGIN
			SET @SIGAPROBADOR = (SELECT TOP 1  
			TA.IdAprobador  
			 FROM Petrovendor..TA_Tarea AS TA  
			 WHERE TA.IdOperacion = @IdOperacionCursor  
			  AND TA.IdEstatus <> 7  
			  AND TA.Activo = 1  
			  AND TA.FechaCambioEstatus IS NULL  
			 ORDER BY TA.NoSecuencia ASC);
		END
		IF @TIPOFLUJO = 2 --FLUJO PARALELO
		BEGIN 
			SET @SIGAPROBADOR = (SELECT TOP 1  
			  TA.IdAprobador  
			 FROM Petrovendor..TA_Tarea AS TA  
			 WHERE TA.IdOperacion = @IdOperacionCursor  
			  AND TA.IdEstatus <> 7  
			  AND TA.Activo = 1  
			  AND TA.FechaCambioEstatus IS NULL  
			  AND TA.IdAprobador = @IdUsuarioP)
		END
		IF @IdUsuarioP = @SIGAPROBADOR
		BEGIN
------------------------------------------------------------------------------------
---------------- SE INSERTAN LOS PEDIMENTOS COMPROBANTES
------------------------------------------------------------------------------------
			INSERT INTO #TM_Aprobacion
			(
				IdTipoAprobacion,
				IdStatusAprobacionM,
				IdTareaOrigen,
				IdContrato,
				FechaCreacion,
				IdDocumento,
				ComentarioDocumento,
				ComentarioAprobacion,
				NoVersion,
				TipoFlujo,
				IdPedido
			)SELECT
					19 as IdTipoAprobacion,
					ET.IdEstatus as IdStatusAprobacionM,
					T.IdTarea as IdTareaOrigen,
					PC.IdContrato as IdContrato,
					APC.CreadoEl as FechaCreacion,
					PC.IdPedimentoComprobante as IdDocumento,
					CONCAT('Exportador: ',PVS.RazonSocial,' | ','Folio Comprobante: ',PC.FolioComprobante,' | ','Fecha de Pago: ' ,PC.FechaPago ,' | ','Moneda: ',TM.TipoMonedaCorto collate Modern_Spanish_CI_AS,' | ', 'Número de Factura: ',PC.NumFacturaC,' |  Proveedor:', APC.IdProveedor) as ComentarioDocumento,
					CONCAT('Cargado Por: ', US.Nombre, 'Flujo tipo' ,@TIPOFLUJO) as ComentarioAprobacion,
					0 as NoVersion,
					OP.IdOperacion as TipoFlujo,
					PC.IdPedimentoComprobante as IdPedido
				FROM Petrovendor..FI_AceptacionPedido_PedimentoComprobante AS APC
					JOIN Petrovendor..TA_Operacion AS OP
						ON APC.IdAceptacionPedidoPedimentoComprobante = OP.IdDocumento 
						AND OP.IdTipoOperacion = 19
						AND APC.IdProveedor = OP.IdProveedor 
					JOIN Petrovendor..FI_PedimentoComprobante AS PC
						ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante 
					JOIN Petrovendor..S_Usuario AS US
						ON APC.CreadoPor = US.IdUsuario 
					JOIN Adinco.dbo.PV_Subcontratista AS PVS
						ON PC.IdSubcontratistaExportador = PVS.IdSubcontratista 
					JOIN Adinco.dbo.PV_TipoMoneda AS TM
						ON PC.IdMoneda = TM.IdMoneda 
					JOIN Petrovendor..TA_Estatus AS ET
						ON OP.IdEstatusOperacion = ET.IdEstatus
					LEFT JOIN Petrovendor.dbo.TA_Tarea AS T ON OP.IdOperacion = T.IdOperacion 
				WHERE 
					OP.IdOperacion = @IdOperacionCursor
					AND 
					APC.Activo = 1
					AND T.IdEstatus = 1
					AND T.IdAprobador = @IdUsuarioP
					AND OP.IdTipoOperacion = 19
		END
------------------------------------------------------------------------------------
------------------------------------------------------------
		FETCH NEXT FROM CursorIdOperacion INTO @IdOperacionCursor
		END 
		CLOSE CursorIdOperacion
		DEALLOCATE CursorIdOperacion
------------------------------------------------------------------------------------
--------------- SE TERMINA EL CURSOS QUE INSERTAN LOS IDOPERACION ------------------
------------------------------------------------------------------------------------
--END
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-----------------------SE SELECCIONAN TODOS LOS REGISTROS----------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

SELECT
		t.IdContrato,
		CONCAT(AC.NombreAreaContractual,'- - ',C.NumeroContrato) AS NumeroContrato,
		ta.NombreOperacion AS 'TipoAprobacion',
		t.IdTipoAprobacion AS 'idTipoAprobacion',
		CASE WHEN CONVERT(nvarchar(10),t.FechaCreacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaCreacion, 105) END AS 'FechaCreacion',
		t.ComentarioDocumento AS 'ComentarioDoc',
		t.ComentarioAprobacion AS 'ComentarioApr',
		e.Status AS 'Estatus',
		
		t.IdStatusAprobacionM AS 'IdStatusAprobacionM',
		t.IdTareaOrigen AS 'IdTareaOrigen',
		t.NoVersion AS 'NoVersion',
		t.IdPedido AS 'IdPedido',
		CASE 
			WHEN t.IdTipoAprobacion = 2 THEN t.IdDocumento 
			WHEN t.IdTipoAprobacion = 9 THEN t.IdPedido 
			WHEN t.IdTipoAprobacion = 14 THEN ISNULL(t.IdPedido,0) 
			WHEN t.IdTipoAprobacion = 19 THEN ISNULL(t.IdPedido,0) 
			END AS 'DisplayMember',
		t.IdDocumento AS 'IdDocumento',
		t.TipoFlujo
		INTO #DATOSAPROBACIONES
FROM #TM_Aprobacion AS t
		left JOIN dbo.AM_StatusAprobacionM AS e
			ON t.IdStatusAprobacionM = e.IdStatusAprobacionM 
		left JOIN Petrovendor..TA_TipoOperacion AS ta 
			ON t.IdTipoAprobacion = ta.IdTipoOperacion 
		left JOIN dbo.CO_CONTRATO as c
			ON t.IdContrato = c.IdContrato
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC
		ON C.IdAreaContractual = AC.IdAreaContractual
		--where t.IdContrato = 3
		ORDER BY t.FechaCreacion ASC
------------------------------------------------------
--select * from #IdOperaciones

SELECT COUNT(1) AS APROBACIONES_PENDIENTES FROM #DATOSAPROBACIONES

end
