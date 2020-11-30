/****** Object:  StoredProcedure [dbo].[Mobile_AprobacionesPorUsuario]    Script Date: 28/02/2019 05:41:41 p. m. ******/
CREATE PROCEDURE [dbo].[Mobile_AprobacionesPorUsuario]
@IdContrato INT =0,
@IdUsuario INT,
@IdTipo INT,
@IdApp INT =0
AS
BEGIN
DECLARE @PROVEDORRFC NVARCHAR(20);
IF	@IdApp = 1
BEGIN
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
DECLARE @IdUsuarioP int;
SET @IdUsuarioP = (SELECT IdUsuario FROM Petrovendor.dbo.S_Usuario WHERE IdUsuarioADINCO = @IdUsuario);
----------------------------------------------------------------
----------------------------------------------------------------
-- SE CREA UNA TABLA PARA TODOS LOS PROVEDDORES QUE TIENE UN USUARIO ADINCO 
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
				ON up.IdUsuario = u.IdUsuario 
WHERE u.IdUsuarioADINCO = @IdUsuario
-----------------TABLA TEMPORAL DE AM_APROBACION---------------
----------------------------------------------------------------
CREATE TABLE #TM_Aprobacion
(
	[IdTipoAprobacion] [int] NULL,
	[IdStatusAprobacionM] [int] NULL,
	[IdUsuario] [int] NULL,
	[IdTareaOrigen] [int] NULL,
	[IdContrato] [int] NULL,
	[FechaCreacion] [datetime] NULL,
	[FechaModificacion] [datetime] NULL,
	[IdDocumento] [int] NULL,
	[ComentarioDocumento] [nvarchar] (max) ,
	[ComentarioAprobacion] [nvarchar] (max),
	[ComentarioAprobacionRechazo] [nvarchar] (max) ,
	[EsVisible] [bit] NULL,
	[NoVersion] [int] NULL,
	[TipoFlujo] [int] NULL,
	[NoSecuencia] [int] NULL,
	[ActualizadoByApp] [bit] NULL,
	[IdPedido] [int] NULL
) 
----------------------------------------------------------------
----------------------------------------------------------------
---------------------SOLICITUDES DE PEDIDO----------------------
----------------------------------------------------------------
DECLARE @IdProveedorCursor AS nvarchar(400) --Sustituirá al IdProveedor en el cursor

--se crea el cursor de para 
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
		    IdUsuario,
		    IdTareaOrigen,
		    IdContrato,
		    FechaCreacion,
		    FechaModificacion,
		    IdDocumento,
		    ComentarioDocumento,
		    ComentarioAprobacion,
		    ComentarioAprobacionRechazo,
		    EsVisible,
		    NoVersion,
		    TipoFlujo,
		    NoSecuencia,
		    ActualizadoByApp,
		    IdPedido
		)
		SELECT O.IdTipoOperacion AS IdTipoAprobacion,
			t.IdEstatus AS IdStatusAprobacionM,
			@IdUsuario AS IdUsuario,
			t.IdTarea AS 'IdTareaOrigen',
			SP.IdContrato,
			O.FechaRegistro AS FechaCreacion,
			NULL AS 'FechaModificacion',
			O.IdDocumento,
			'Solicitud de pedido' AS ComentarioDocumento, 
			O.Descripcion AS ComentarioAprobacion,
			NULL AS ComentarioAprobacionRechazo,
			1 AS EsVisible,
			NULL AS 'NoVersion',
			TF.IdFlujoTarea AS TipoFlujo, 
			T.NoSecuencia AS NoSecuencia,
			NULL AS ActualizadoByApp,
			NULL AS IdPedido
			FROM Petrovendor.dbo.TA_Operacion AS O 
			INNER JOIN Petrovendor.dbo.TA_TipoOperacion AS OT ON OT.IdTipoOperacion = O.IdTipoOperacion
			INNER JOIN Petrovendor.dbo.TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
			INNER JOIN Petrovendor.dbo.TA_TareaOperacion AS TTO ON TTO.IdOperacion = O.IdOperacion
			INNER JOIN Petrovendor.dbo.TA_Tarea AS T ON T.IdTarea = TTO.IdTarea
			INNER JOIN Petrovendor.dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = O.IdDocumento
			INNER JOIN Petrovendor.dbo.TA_FlujoTarea AS TF ON TF.IdFlujoTarea = O.IdFlujoTarea
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
	

----------------------------------------------------------------
----------------------------------------------------------------
------------------------PEDIDO----------------------------------
----------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
DECLARE @IdProveedorCursorPedido AS nvarchar(400) --Sustituirá al IdProveedor en el cursor
BEGIN
	    DECLARE CursorSolucitudesPedido CURSOR FOR SELECT DISTINCT(IdProveedor) FROM #IdsProveedore
END
OPEN CursorSolucitudesPedido

	FETCH NEXT FROM CursorSolucitudesPedido INTO @IdProveedorCursorPedido

	WHILE @@fetch_status = 0

	BEGIN
------------------------------------------------------------------------------------
 DECLARE @IdTipoOperacion INT =9

    DECLARE @FlujoSerial TABLE
    (
        IdOperacion INT,
        NoSecuencia INT
    );
    DECLARE @OperacionNoAprobadas TABLE (IdOperacion INT);
    INSERT INTO @FlujoSerial
    (
        IdOperacion,
        NoSecuencia
    )
    SELECT O.IdOperacion,
           t.NoSecuencia
    FROM Petrovendor.dbo.TA_Operacion O
        LEFT JOIN Petrovendor.dbo.MM_Pedido p
            ON p.IdSolicitudPedido = O.IdDocumento
               AND p.Version = O.NoVersion
        INNER JOIN Petrovendor.dbo.TA_Tarea t
            ON t.IdOperacion = O.IdOperacion
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
    IdUsuario,
    IdTareaOrigen,
    IdContrato,
    FechaCreacion,
    FechaModificacion,
    IdDocumento,
    ComentarioDocumento,
    ComentarioAprobacion,
    ComentarioAprobacionRechazo,
    EsVisible,
    NoVersion,
    TipoFlujo,
    NoSecuencia,
    ActualizadoByApp,
    IdPedido
) SELECT 
		O.IdTipoOperacion,
		t.IdEstatus AS [IdStatusAprobacionM],
		@IdUsuario AS [IdUsuario],
		t.IdTarea AS [IdTareaOrigen],
		p.IdContrato,
		O.FechaRegistro AS [FechaCreacion],
		NULL AS [FechaModificacion],
        O.IdDocumento,
		'Solicitud de pedido' AS ComentarioDocumento, 
		o.Descripcion AS ComentarioAprobacion,
		NULL AS ComentarioAprobacionRechazo,
		1 AS  EsVisible,
		P.Version AS 'NoVersion',
        P2.IdPedido,
		t.NoSecuencia,
		NULL AS [ActualizadoByApp],
		P2.IdPedido
    FROM Petrovendor.dbo.TA_Operacion AS O
        LEFT JOIN Petrovendor.dbo.MM_Pedido AS P ON P.IdSolicitudPedido = O.IdDocumento
        INNER   JOIN    Petrovendor.dbo.MM_Pedidos P2 ON P.IdPedido = P2.IdIdentificador
        LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
        LEFT JOIN Petrovendor.dbo.TA_Estatus AS E ON E.IdEstatus = O.IdEstatusOperacion
        LEFT JOIN Petrovendor.dbo.TA_Tarea AS T ON T.IdOperacion = O.IdOperacion
        LEFT JOIN Petrovendor.dbo.S_Usuario U ON U.IdUsuario = T.IdAprobador
        LEFT JOIN Petrovendor.dbo.S_UsuarioProveedor UP ON UP.IdUsuario = U.IdUsuario
                                               AND SP.IdContrato = UP.IdContrato
                                               AND UP.IdProveedor = O.IdProveedor
        LEFT JOIN Petrovendor.dbo.S_Proveedor prov ON prov.IdProveedor = P.IdSubcontratista
    WHERE T.IdAprobador = @IdUsuarioP
          AND O.IdProveedor = @IdProveedorCursorPedido
          AND O.IdTipoOperacion = @IdTipoOperacion
          AND P.Version = O.NoVersion
		  AND t.IdEstatus = 1
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
          AND ISNULL(p.IdEstatusEliminado, 0) <> 1 -->Pedido no eliminado
          AND O.IdOperacion NOT IN (
                                       SELECT IdOperacion FROM @OperacionNoAprobadas
                                   )
    ORDER BY P2.IdPedido
	
	FETCH NEXT FROM CursorSolucitudesPedido INTO @IdProveedorCursorPedido
	END 
	CLOSE CursorSolucitudesPedido
	DEALLOCATE CursorSolucitudesPedido

			SELECT
--t.IdAprobacion AS 'Numero' ,
0 AS Numero,
t.ComentarioDocumento AS 'ComentarioDoc',
t.ComentarioAprobacion AS 'ComentarioApr',
CASE WHEN t.ComentarioAprobacionRechazo IS NULL THEN '' ELSE t.ComentarioAprobacionRechazo END AS 'ComentarioFinal',
CASE WHEN CONVERT(nvarchar(10),t.FechaCreacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaCreacion, 105) END AS 'FechaCreacion',
CASE WHEN CONVERT(nvarchar(10),t.FechaModificacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),t.FechaModificacion, 105) END AS 'FechaModificacion',
e.Status AS 'Estatus',
t.IdTipoAprobacion AS 'idTipoAprobacion',
t.IdStatusAprobacionM AS 'IdStatusAprobacionM',
t.IdDocumento AS 'IdDocumento',
t.IdTareaOrigen AS 'IdTareaOrigen',
CASE WHEN t.idtipoaprobacion =9
	THEN
		'http://mobileprocura.adinco.mx/08Mobile/DetalleMobilePedido.aspx?doc=##IDDOC##&ver=##IDVER##' 
	WHEN  t.idtipoaprobacion =2
	THEN
		'http://mobileprocura.adinco.mx/08Mobile/DetalleMobile.aspx?doc=##IDDOC##&mono=##IDUS##'
	END
    AS 'URI',
ta.TipoAprobacion AS 'TipoAprobacion',
t.NoVersion AS 'NoVersion',
t.IdPedido AS 'IdPedido',
CASE WHEN t.IdTipoAprobacion = 2 THEN t.IdDocumento ELSE t.IdPedido END AS 'DisplayMember',
0 AS 'Eliminado'
FROM #TM_Aprobacion AS t
JOIN dbo.AM_StatusAprobacionM AS e
	ON e.IdStatusAprobacionM = t.IdStatusAprobacionM
JOIN dbo.AM_TipoAprobacion AS ta 
	ON ta.idTipoAprobacion = t.IdTipoAprobacion
	WHERE 
	--t.EsVisible= 1 
	--AND 
	t.IdStatusAprobacionM=1
	--AND t.IdUsuario = @IdUsuario
	AND t.IdTipoAprobacion = @IdTipo
	ORDER BY IdTareaOrigen asc
END        
IF	@IdApp = 2
BEGIN
	IF @IdTipo = 35
	BEGIN	
	SET @PROVEDORRFC = (SELECT RFC FROM Petrovendor.dbo.S_Proveedor WHERE IdProveedor = @IdContrato);
	CREATE TABLE #SEGUIMIENTOPAGOS(
									IdFactura INT NULL,
									IdFacturaPet INT NULL,
									IdSolicitudPedido VARCHAR(20) NULL,
									Receptor NVARCHAR(200) NULL,
									Fecha DATETIME NULL,
									Serie NVARCHAR(MAX) NULL,
									Folio NVARCHAR(MAX) NULL,
									Total MONEY,
									UUID VARCHAR(500) NULL,
									Moneda VARCHAR(10) NULL,
									Proceso VARCHAR(100) NULL,
									TieneArchivo BIT NULL,
									IdAceptacionPedido INT NULL,
									ReceptorRFC VARCHAR(500)
									);
	INSERT INTO #SEGUIMIENTOPAGOS
		SELECT aFact.IdFactura,
		pFact.IdFactura IdFacturaPet,
		p.IdSolicitudPedido,
		prov.RazonSocial AS Receptor,
		aFact.Fecha,
		aFact.Serie,
		aFact.Folio,
		aFact.MontoConIva AS Total,
		aFact.UUID,
		M.TipoMonedaCorto AS Moneda,
		Proceso = CASE
		WHEN transf.PDF IS NULL THEN
		'No pagado'
		WHEN transf.PDF IS NOT NULL THEN
		'Pagado'
		WHEN aFact.IdFactura IS NULL THEN
		'En proceso'
		END,
		TieneArchivo = CAST(CASE
		WHEN transf.PDF IS NULL THEN
		0
		ELSE
		1
		END AS BIT),
		acepFact.IdAceptacionPedido,
		aFact.Receptor
		FROM Adinco.dbo.FI_Factura aFact
		LEFT JOIN Petrovendor.dbo.FI_Factura pFact ON pFact.UUID = aFact.UUID COLLATE Modern_Spanish_CI_AS
		LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura acepFact ON acepFact.IdFactura = pFact.IdFactura
		INNER JOIN Petrovendor.dbo.MM_AceptacionPedido acepPed ON acepPed.IdAceptacionPedido = acepFact.IdAceptacionPedido
		INNER JOIN Petrovendor.dbo.MM_Pedido p ON p.IdPedido = acepPed.IdPedido
		LEFT JOIN Petrovendor.dbo.TA_Operacion TAO ON TAO.IdDocumento = acepFact.IdAceptacionFactura
		LEFT JOIN Petrovendor.dbo.TA_Estatus AS TE ON TE.IdEstatus = TAO.IdEstatusOperacion
		INNER JOIN Petrovendor.dbo.S_Proveedor prov ON prov.RFC = aFact.Receptor COLLATE Modern_Spanish_CI_AS
		LEFT JOIN Adinco.dbo.PV_TipoMoneda M ON M.IdMoneda = aFact.IdMoneda
		LEFT JOIN Adinco.dbo.FI_TransferFactura transFac ON transFac.IdFactura = aFact.IdFactura
		LEFT JOIN Adinco.dbo.FI_Transfer transf ON transf.IdTransferencia = transFac.IdTransfer
		WHERE TE.IdEstatus = 2 --aprobadas
		AND aFact.Activa = 1
		AND pFact.Activa = 1
		AND prov.Activo = 1
		AND TAO.IdProveedor = @IdContrato
		AND ISNULL(prov.IsEliminado, 0) = 0

---------------------------------------
		INSERT INTO #SEGUIMIENTOPAGOS
		SELECT aFact.IdFactura,
		pFact.IdFactura IdFacturaPet,
		'N/A',
		CON.RazonSocial AS Receptor,
		aFact.Fecha,
		aFact.Serie,
		aFact.Folio,
		aFact.MontoConIva AS Total,
		aFact.UUID,
		M.TipoMonedaCorto AS Moneda,
		Proceso = CASE
		WHEN transf.PDF IS NULL THEN
		'No pagado'
		WHEN transf.PDF IS NOT NULL THEN
		'Pagado'
		WHEN aFact.IdFactura IS NULL THEN
		'En proceso'
		END,
		TieneArchivo = CAST(CASE
		WHEN transf.PDF IS NULL THEN
		0
		ELSE
		1
		END AS BIT),
		acepFact.IdAceptacionPedido,
		aFact.Receptor
		FROM Adinco.dbo.FI_Factura aFact
		LEFT JOIN Petrovendor.dbo.FI_Factura pFact ON pFact.UUID = aFact.UUID COLLATE Modern_Spanish_CI_AS
		LEFT JOIN Petrovendor.dbo.MPY_MM_AceptacionFactura acepFact ON acepFact.IdFactura = pFact.IdFactura
		INNER JOIN Petrovendor.dbo.MPY_MM_AceptacionPedido acepPed ON acepPed.IdAceptacionPedido = acepFact.IdAceptacionPedido
		LEFT JOIN Petrovendor.dbo.TA_Estatus AS TE ON TE.IdEstatus = acepFact.IdEstatus
		LEFT JOIN Adinco.dbo.CO_Contratista AS CON ON CON.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = pFact.Receptor COLLATE SQL_Latin1_General_CP1_CI_AS
		LEFT JOIN Adinco.dbo.PV_TipoMoneda M ON M.IdMoneda = aFact.IdMoneda
		LEFT JOIN Adinco.dbo.FI_TransferFactura transFac ON transFac.IdFactura = aFact.IdFactura
		LEFT JOIN Adinco.dbo.FI_Transfer transf ON transf.IdTransferencia = transFac.IdTransfer
		WHERE TE.IdEstatus = 2 --aprobadas
		AND aFact.Activa = 1
		AND pFact.Activa = 1
		AND pFact.Emisor = @PROVEDORRFC
		AND pFact.IdFactura IS NOT NULL;
		
		SELECT 
			IdFactura AS 'Numero',
			CONCAT('Monto:',Total,Moneda) AS 'ComentarioDoc',
			Receptor AS 'ComentarioApr',
			Proceso AS 'ComentarioFinal',
			CASE WHEN CONVERT(nvarchar(10),Fecha, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),Fecha, 105) END AS 'FechaCreacion',
			'-' AS 'FechaModificacion',
			Proceso AS 'Estatus',
			35 AS 'idTipoAprobacion',
			CASE WHEN Proceso = 'Pagado' THEN '2' WHEN Proceso = 'No pagado' THEN '1' END  AS IdStatusAprobacionM,
			CONCAT(Folio, Serie)AS 'IdDocumento',
			IdFacturaPet AS 'IdTareaOrigen',
			TieneArchivo AS 'URI',
			'Seguimiento de Pago' AS 'TipoAprobacion',
			1 AS NoVersion
				FROM #SEGUIMIENTOPAGOS ORDER BY Fecha DESC;
	END
    IF @IdTipo = 9
	BEGIN
	SELECT 
	1,
	0 AS Numero,
	'Nuevo pedido' AS 'ComentarioDoc',
	o.Descripcion AS 'ComentarioApr',
	t.Comentario AS 'ComentarioFinal',
	CASE WHEN CONVERT(nvarchar(10),o.FechaRegistro, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),o.FechaRegistro, 105) END AS 'FechaCreacion',
	CASE WHEN CONVERT(nvarchar(10),o.FechaModificacion, 105) IS NULL THEN '-' ELSE CONVERT(nvarchar(10),o.FechaModificacion, 105) END AS 'FechaModificacion',
	e.Status AS 'Estatus',
	o.IdTipoOperacion AS 'idTipoAprobacion',
	t.IdEstatus AS 'IdStatusAprobacionM',
	o.IdDocumento,
	t.IdTarea AS 'IdTareaOrigen',
	CASE WHEN o.IdTipoOperacion =9
		THEN
			'http://mobileprocura.adinco.mx/08Mobile/DetalleMobilePedido.aspx?doc=##IDDOC##&ver=##IDVER##' 
		WHEN  o.IdTipoOperacion =2
		THEN
			'http://mobileprocura.adinco.mx/08Mobile/DetalleMobile.aspx?doc=##IDDOC##&mono=##IDUS##'
		END
		AS 'URI',
	TIPO.TipoAprobacion,
	o.NoVersion
					FROM Petrovendor.dbo.TA_Tarea t
					INNER JOIN Petrovendor.dbo.TA_Operacion o
					ON o.IdOperacion = t.IdOperacion
					AND o.IdTipoOperacion = 9
					INNER JOIN Petrovendor.dbo.MM_Pedido p
					ON p.IdSolicitudPedido = o.IdDocumento
					AND p.Version = o.NoVersion
					JOIN Adinco.dbo.AM_StatusAprobacionM AS e
					ON e.IdStatusAprobacionM = t.IdEstatus
					JOIN Adinco.dbo.AM_TipoAprobacion AS TIPO 
					ON o.IdTipoOperacion = TIPO.idTipoAprobacion
					WHERE o.IdProveedor = @IdContrato
					AND t.IdEstatus = 2
					AND o.IdTipoOperacion = 9
    END
END    
END

