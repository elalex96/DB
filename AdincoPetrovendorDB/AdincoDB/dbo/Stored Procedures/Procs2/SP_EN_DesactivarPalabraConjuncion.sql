CREATE PROC SP_EN_DesactivarPalabraConjuncion
@Id int,
@idContrato int,
@IdUsuario int
AS
BEGIN
	UPDATE EN_ConjuncionesDocumentos
	SET Activo = 0,
	ModificadoEl = GETDATE(),
	ModificacdoPor = @IdUsuario
	WHERE ID = @Id
END