CREATE FUNCTION dbo.fn_ObtenerFechas
(	@IdSolicitudPedido	INT,
	@TipoOperacion	INT)
RETURNS DATETIME
AS
BEGIN
	DECLARE @FechaAprobacion DATETIME

	SELECT @FechaAprobacion = MAX(T.FechaCambioEstatus)
	FROM dbo.TA_Operacion AS TA (NOLOCK)
		JOIN dbo.TA_Tarea AS T (NOLOCK)
			ON TA.IdOperacion = T.IdOperacion
			AND TA.IdDocumento = @IdSolicitudPedido
			AND TA.IdEstatusOperacion = 2
			AND TA.IdTipoOperacion = @TipoOperacion
	WHERE TA.IdDocumento = @IdSolicitudPedido

	RETURN @FechaAprobacion
END