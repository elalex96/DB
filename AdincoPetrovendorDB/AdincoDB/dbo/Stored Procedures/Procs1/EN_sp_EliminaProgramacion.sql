CREATE PROCEDURE EN_sp_EliminaProgramacion
@idInstancia int
AS
BEGIN
	DELETE
	FROM EN_URLResponsablesEntregables
	WHERE idInstanciaEntregable = @idInstancia

	DELETE
	FROM EN_ExcepcionesActividad
	WHERE IdInstanciasEntregables = @idInstancia

	DELETE EN_HistorialAprobacionesLineaTiempo
	WHERE idInstanciaEntregable = @idInstancia

	DELETE
	FROM EN_InstanciasEntregable
	WHERE idInstanciaEntregable = @idInstancia
END