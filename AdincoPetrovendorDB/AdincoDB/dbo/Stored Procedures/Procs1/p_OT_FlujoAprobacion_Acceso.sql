IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'p_OT_FlujoAprobacion_Acceso'
)
    DROP PROCEDURE p_OT_FlujoAprobacion_Acceso
GO
CREATE PROC [dbo].[p_OT_FlujoAprobacion_Acceso]
@pTipoFlujoAprobacionId INT,
@pIdContrato INT,
@pUsuarioId INT,
@pIdOTSolicitud INT
AS
BEGIN

	DECLARE @idCC INT

	SELECT @idCC = ISNULL(IdCentroCosto,0)
	FROM OT_Solicitud 
	WHERE IdOTSolicitud = @pIdOTSolicitud

	SELECT  CreadorOT  = CAST( ISNULL(MAX(CASE WHEN AP_FlujoAprobacionEstatus.Orden = 1 THEN 1 ELSE 0 END),0) AS BIT),
			AprobadorOT =CAST(ISNULL(MAX(CASE WHEN AP_FlujoAprobacionEstatus.Orden = 2 THEN 1 ELSE 0 END),0) AS BIT),
			ValidadorCantOT = CAST(ISNULL(MAX(CASE WHEN AP_FlujoAprobacionEstatus.Orden = 3 THEN 1 ELSE 0 END),0) AS BIT),
			GeneradorEstimacion = CAST(ISNULL(MAX(CASE WHEN AP_FlujoAprobacionEstatus.Orden = 4 THEN 1 ELSE 0 END),0) AS BIT),
			AceptacionServicioOT = CAST(ISNULL(MAX(CASE WHEN AP_FlujoAprobacionEstatus.Orden = 5 THEN 1 ELSE 0 END),0) AS BIT)	,
			AdminContratos = CAST(ISNULL(MAX(CASE WHEN AP_FlujoAprobacionEstatus.Orden = 6 THEN 1 ELSE 0 END),0) AS BIT),
			ConsultaContratos = CAST(ISNULL(MAX(CASE WHEN AP_FlujoAprobacionEstatus.Orden = 7 THEN 1 ELSE 0 END),0) AS BIT)
	FROM AP_FlujoAprobacionEstatus (NOLOCK)
	INNER JOIN AP_FlujoAprobacionEstatusUsuarios (NOLOCK) 
		ON AP_FlujoAprobacionEstatusUsuarios.usuarioId = @pUsuarioId 
			AND AP_FlujoAprobacionEstatus.FlujoAprobacionEstatusId = AP_FlujoAprobacionEstatusUsuarios.FlujoAprobacionEstatusId
	INNER JOIN AP_FlujoAprobacionContratos (NOLOCK) 
		ON AP_FlujoAprobacionContratos.IdContrato = @pIdContrato
	INNER JOIN AP_FlujoAprobacion (NOLOCK) 
		ON AP_FlujoAprobacionContratos.FlujoAprobacionId = AP_FlujoAprobacion.FlujoAprobacionId 
			AND AP_FlujoAprobacionEstatus.TipoFlujoAprobacionId = AP_FlujoAprobacion.TipoFlujoAprobacionId
	INNER JOIN AP_UsuarioCentroCosto (NOLOCK) 
		ON AP_FlujoAprobacionEstatusUsuarios.usuarioId = AP_UsuarioCentroCosto.IdUsuario 
			AND ISNULL(@idCC, 0) in (0, AP_UsuarioCentroCosto.IdCentroCosto )
	WHERE AP_FlujoAprobacionEstatus.TipoFlujoAprobacionId = @pTipoFlujoAprobacionId  
		AND AP_FlujoAprobacionContratos.IdContrato = @pIdContrato 
		AND AP_FlujoAprobacionEstatusUsuarios.usuarioId = @pUsuarioId
END
	