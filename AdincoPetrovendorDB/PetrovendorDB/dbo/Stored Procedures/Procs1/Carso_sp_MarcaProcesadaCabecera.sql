DROP PROCEDURE IF EXISTS Carso_sp_MarcaProcesadaCabecera
go
CREATE PROCEDURE Carso_sp_MarcaProcesadaCabecera
@IdCabecera int
AS
BEGIN 
	UPDATE Carso_Items_comparativaCabecera
	SET PROCESADO = 1,
	ProcesadoEl = GETDATE()
	WHERE Id = @IdCabecera
END