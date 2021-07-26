drop procedure if exists EN_sp_EliminaProgramacion
go
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


	DELETE
	FROM EN_InstanciasEntregable
	WHERE idInstanciaEntregable = @idInstancia
END