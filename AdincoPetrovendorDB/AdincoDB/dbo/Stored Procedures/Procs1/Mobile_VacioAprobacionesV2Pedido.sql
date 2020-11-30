
CREATE PROCEDURE [dbo].[Mobile_VacioAprobacionesV2Pedido]
@IdUsuario INT
AS
BEGIN
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
ALTER TABLE [dbo].[AM_Aprobacion] DISABLE TRIGGER [NuevaNotificacion]
DELETE FROM Adinco.dbo.AM_Aprobacion WHERE IdUsuario = @IdUsuario;
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
		SELECT  
		o.IdTipoOperacion AS IdTipoAprobacion, 
		t.IdEstatus AS IdStatusAprobacionM,
		@IdUsuario AS IdUsuario,
		t.IdTarea AS IdTareaOrigen,
		sp.IdContrato AS IdContrato,
		O.FechaRegistro AS FechaCreacion,
		NULL AS FechaModificacion,
		O.IdDocumento,
		'Solicitud de pedido' AS ComentarioDocumento, 
        O.Descripcion AS ComentarioAprobacion,
		NULL AS ComentarioAprobacionRechazo,
		--CASE WHEN T.NoSecuencia = 1 THEN 1 ELSE 0 END AS EsVisible,
		1 AS EsVisible,
		NULL AS 'NoVersion',
		TF.IdTipoFlujo AS TipoFlujo, 
		T.NoSecuencia AS NoSecuencia,
		NULL AS ActualizadoByApp,
		NULL AS IdPedido
  FROM	Petrovendor.dbo.TA_Operacion AS O
		INNER JOIN Petrovendor.dbo.TA_TipoOperacion AS OT
				   ON OT.IdTipoOperacion = O.IdTipoOperacion
		INNER JOIN Petrovendor.dbo.TA_Estatus AS E
				   ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN Petrovendor.dbo.TA_TareaOperacion AS TTO
				   ON TTO.IdOperacion = O.IdOperacion
		INNER JOIN Petrovendor.dbo.TA_Tarea AS T
				   ON T.IdTarea = TTO.IdTarea
		INNER JOIN Petrovendor.dbo.MM_SolicitudPedido sp
				   ON O.IdDocumento = sp.IdSolicitudPedido
		JOIN Petrovendor.dbo.MM_SolicitudPedido AS ms ON o.IdDocumento = ms.IdSolicitudPedido
	JOIN Petrovendor.dbo.TA_FlujoTarea AS TF ON TF.IdFlujoTarea = O.IdFlujoTarea
 WHERE
		T.IdAprobador = @IdUsuarioP
		AND O.IdTipoOperacion = 2
		AND O.IdProveedor = @IdProveedorCursor 
		AND t.IdEstatus = 1
		AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 --> MOSTRAR NO ELIMINADAS 
		AND O.IdOperacion NOT IN
		(	SELECT	IdOperacion
			FROM	Petrovendor.dbo.FN_FlujoSerialNoAprobados ( @IdUsuario, @IdProveedorCursor, 2 ) )

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
	DECLARE @FlujoSerial TABLE
	( IdOperacion INT ,
	  NoSecuencia INT )

	DECLARE @OperacionNoAprobadas TABLE
	( IdOperacion INT ) ;

	INSERT INTO @FlujoSerial
( IdOperacion, NoSecuencia )
SELECT	
O.IdOperacion, t.NoSecuencia
FROM Petrovendor.dbo.TA_Operacion O
	LEFT JOIN Petrovendor.dbo.MM_Pedido p
	ON p.IdSolicitudPedido = O.IdDocumento AND p.Version = O.NoVersion
	INNER JOIN Petrovendor.dbo.TA_Tarea t
	ON t.IdOperacion = O.IdOperacion
WHERE
	O.IdTipoOperacion = 9
	AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
	AND t.IdAprobador = @IdUsuario
	AND t.NoSecuencia > 1

	INSERT INTO @OperacionNoAprobadas
	( IdOperacion )
SELECT	O.IdOperacion
  FROM	Petrovendor.dbo.TA_Operacion O
		INNER JOIN @FlujoSerial f
				   ON f.IdOperacion = O.IdOperacion
		INNER JOIN Petrovendor.dbo.TA_Tarea T
				   ON T.IdOperacion = O.IdOperacion
					  AND	T.NoSecuencia = ( f.NoSecuencia - 1 )
 WHERE
		O.IdTipoOperacion = 9
		AND T.IdEstatus <> 2
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
	SELECT 
		o.IdTipoOperacion AS [IdTipoAprobacion],
		t.IdEstatus AS [IdStatusAprobacionM],
		u.IdUsuarioADINCO AS [IdUsuario],
		t.IdTarea AS [IdTareaOrigen],
		p.IdContrato,
		O.FechaRegistro AS [FechaCreacion],
		NULL AS [FechaModificacion],
		O.IdDocumento AS [IdDocumento],
		'Nuevo Pedido' AS [ComentarioDocumento],
		O.Descripcion AS [ComentarioAprobacion],
		'' AS [ComentarioAprobacionRechazo],
		--CASE WHEN TF.IdTipoFlujo = 2 or t.NoSecuencia = 1 THEN 1 ELSE
		   -- 0 END AS [EsVisible], -- REvisar consulta de seriales y paralelos
		1 AS [EsVisible], 
		P.Version AS [NoVersion],
		TF.IdTipoFlujo,
		t.NoSecuencia AS [NoSecuencia],
		NULL AS [ActualizadoByApp],
		--CONCAT('Requisicion: ', O.IdDocumento, '- Pedido: ', P2.IdPedido, '- Descripción: ', O.Descripcion) AS Descripcion,
		P2.IdPedido AS 'IdPedido'
  FROM	Petrovendor.dbo.TA_Operacion AS O
		LEFT JOIN Petrovendor.dbo.MM_Pedido AS P
				  ON P.IdSolicitudPedido = O.IdDocumento
		INNER JOIN Petrovendor.dbo.MM_Pedidos P2
				   ON P.IdPedido = P2.IdIdentificador
		LEFT JOIN Petrovendor.dbo.MM_SolicitudPedido SP
				  ON SP.IdSolicitudPedido = P.IdSolicitudPedido
		LEFT JOIN Petrovendor.dbo.TA_Estatus AS E
				  ON E.IdEstatus = O.IdEstatusOperacion
		LEFT JOIN Petrovendor.dbo.TA_Tarea AS T
				  ON T.IdOperacion = O.IdOperacion
		LEFT JOIN Petrovendor.dbo.S_Usuario U
				  ON U.IdUsuario = T.IdAprobador
		LEFT JOIN Petrovendor.dbo.S_UsuarioProveedor UP
				  ON UP.IdUsuario = U.IdUsuario
					 AND SP.IdContrato = UP.IdContrato
					 AND UP.IdProveedor = O.IdProveedor
		LEFT JOIN Petrovendor.dbo.S_Proveedor prov
				  ON prov.IdProveedor = P.IdSubcontratista
		LEFT JOIN Petrovendor.dbo.TA_FlujoTarea AS TF ON TF.IdFlujoTarea = O.IdFlujoTarea
 WHERE
		T.IdAprobador = @IdUsuarioP
		AND O.IdProveedor = @IdProveedorCursorPedido
		AND O.IdTipoOperacion = 9
		AND t.IdEstatus = 1
		AND P.Version = O.NoVersion
		AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
		AND ISNULL ( p.IdEstatusEliminado, 0 ) <> 1 -->Pedido no eliminado
		AND O.IdOperacion NOT IN( SELECT IdOperacion FROM	   @OperacionNoAprobadas )
	FETCH NEXT FROM CursorSolucitudesPedido INTO @IdProveedorCursorPedido
	END 
	CLOSE CursorSolucitudesPedido
	DEALLOCATE CursorSolucitudesPedido

	INSERT INTO Adinco.dbo.AM_Aprobacion
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
	)SELECT 
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
		    IdPedido FROM #TM_Aprobacion
	
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
ALTER TABLE [dbo].[AM_Aprobacion] ENABLE TRIGGER [NuevaNotificacion]
-----------------------------------------------------------------------------
END
