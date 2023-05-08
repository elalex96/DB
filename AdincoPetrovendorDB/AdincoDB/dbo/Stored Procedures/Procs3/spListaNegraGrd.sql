CREATE PROC spListaNegraGrd
AS
BEGIN
	SELECT	RFC,
			Contribuyente,
			Situacion,
			NoFechaOficioGlobalPresuncion,
			PublicacionPaginaSATPresuntos,
			PublicacionDOFpresuntos,
			PublicacionPaginaSATDesvirtuados,
			NoFechaOficioGlobalContribuyentesDesvirtuaron,
			PublicacionDOFDesvirtuados,
			NoFechaOficioGlobalDefinitivos,
			PublicacionPaginaSATDefinitivos,
			PublicacionDOFDefinitivos,
			NoFechaOficioGlobalSentenciaFavorable,
			PublicacionPaginaSATSentenciaFavorable,
			PublicacionDOFSentenciaFavorable
	FROM	ListaNegra
END