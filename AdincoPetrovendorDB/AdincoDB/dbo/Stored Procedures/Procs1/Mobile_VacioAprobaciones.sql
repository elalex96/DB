create PROCEDURE [dbo].[Mobile_VacioAprobaciones]
@Usuario VARCHAR(250)= '',
@IdUsuario INT = 0
AS
BEGIN
	DECLARE
    @IdusuarioAprobador INT=0;
----------------------------------------------------------------------------------------------------------------
	SET @IdusuarioAprobador = (SELECT IdUsuario FROM Petrovendor.dbo.S_Usuario WHERE IdUsuarioADINCO = @IdUsuario)

	SELECT IdTareaOrigen 
	INTO #Ids
	FROM dbo.AM_Aprobacion WHERE 
	IdUsuario = @IdUsuario 
	AND IdTipoAprobacion = 9 
	AND IdStatusAprobacionM = 1
----------------------------------------------------------------------------------------------------------------

	SELECT 
		[IdTareaOrigen] 
		INTO
        #IdsSolped
		FROM dbo.AM_Aprobacion WHERE 
		IdUsuario = @IdUsuario
		AND IdStatusAprobacionM = 1 
		AND IdTipoAprobacion = 2 
		AND EsVisible = 1 
		ORDER BY IdTareaOrigen DESC
-----------------------------------------------------------------------------------------------------------
PRINT 'Vacía solped'
SELECT  
		TAP.IdTipoOperacion AS 'IdTipoAprobacion',
		T.IdEstatus AS 'IdStatusAprobacionM',
		u.IdUsuarioADINCO AS 'IdUsuario',
		T.IdTarea AS 'IdTareaOrigen',		
		SP.IdContrato,
		TAP.FechaRegistro AS 'FechaCreacion',
		NULL AS 'FechaModificacion',
		TAP.IdDocumento,
        SP.MotivoUrgencia AS 'ComentarioDocumento',
		TAP.Descripcion AS 'ComentarioAprobacion',
		NULL AS 'ComentarioAprobacionRechazo',
		CASE WHEN FTA.IdTipoFlujo = 1
		THEN '1' ELSE '0' END AS [EsVisible], 
		TAP.NoVersion,
		FTA.IdTipoFlujo AS 'TipoFlujo',
		T.NoSecuencia,
		NULL AS [ActualizadoByApp]
		INTO #Read
        FROM Petrovendor.dbo.MM_SolicitudPedido AS SP
			LEFT JOIN Petrovendor.dbo.MM_Pedido AS PD
		ON PD.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN Petrovendor.dbo.TA_Operacion AS TAP
		ON SP.IdSolicitudPedido = TAP.IdDocumento
			LEFT JOIN Petrovendor.dbo.TA_Tarea AS T
		ON TAP.IdOperacion = T.IdOperacion
			LEFT JOIN Petrovendor.dbo.TA_FlujoTarea AS FTA
		ON FTA.IdFlujoTarea = TAP.IdFlujoTarea
		    RIGHT JOIN Petrovendor.dbo.S_Usuario u ON u.IdUsuario = t.IdAprobador
			WHERE 
			TAP.IdTipoOperacion = 2
			AND t.IdAprobador = @IdusuarioAprobador
			AND t.IdEstatus = 1
			AND t.IdTarea NOT IN(SELECT IdTareaOrigen FROM #IdsSolped)
			ORDER BY T.IdTarea DESC
ALTER TABLE [dbo].[AM_Aprobacion] DISABLE TRIGGER [NuevaNotificacion]
INSERT INTO dbo.AM_Aprobacion
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
	    ActualizadoByApp
	)
	SELECT IdTipoAprobacion,
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
	    ActualizadoByApp FROM #Read


----------------------------------------------------------------------------------------------------------------

	SELECT 
	o.IdTipoOperacion AS [IdTipoAprobacion] ,
	t.IdEstatus AS [IdStatusAprobacionM],
	u.IdUsuarioADINCO AS [IdUsuario],
	t.IdTarea AS [IdTareaOrigen],
	p.IdContrato,
	t.FechaRegistro AS 'FechaCreacion',
	NULL AS 'FechaModificacion',
	o.IdDocumento,
	'Nuevo pedido' AS 'ComentarioDocumento',
	o.Descripcion AS 'ComentarioAprobacion',
	NULL AS 'ComentarioAprobacionRechazo',
	1 AS [EsVisible],
	o.NoVersion,
	1 AS 'TipoFlujo',
	t.NoSecuencia,
	NULL AS [ActualizadoByApp]
	INTO #Topic 
				FROM Petrovendor.dbo.TA_Tarea t
				INNER JOIN Petrovendor.dbo.TA_Operacion o
				ON o.IdOperacion = t.IdOperacion
				AND o.IdTipoOperacion IN (2,9)
				INNER JOIN Petrovendor.dbo.MM_Pedido p
				ON p.IdSolicitudPedido = o.IdDocumento
				AND p.Version = o.NoVersion
				right JOIN Petrovendor.dbo.S_Usuario u ON u.IdUsuario = t.IdAprobador
				WHERE t.IdEstatus = 1
				AND t.IdAprobador = @IdusuarioAprobador
	--SELECT * FROM #Topic
	SELECT * 
	INTO #ready
	FROM #Topic
	WHERE IdTareaOrigen NOT IN (SELECT IdTareaOrigen FROM #Ids AS ID)
	
	--SELECT * FROM #Topic
PRINT 'Vacía Aprobación de pedido'
	INSERT INTO dbo.AM_Aprobacion
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
	    ActualizadoByApp
	)
	SELECT IdTipoAprobacion,
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
	    ActualizadoByApp FROM #ready

		ALTER TABLE [dbo].[AM_Aprobacion] ENABLE TRIGGER [NuevaNotificacion]
end
