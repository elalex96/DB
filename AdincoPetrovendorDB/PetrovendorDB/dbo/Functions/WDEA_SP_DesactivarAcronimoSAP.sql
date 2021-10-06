DROP PROCEDURE IF EXISTS WDEA_SP_DesactivarAcronimoSAP
GO
CREATE PROCEDURE WDEA_SP_DesactivarAcronimoSAP
@IdSelected int,
@Idusuario int
AS
BEGIN
	UPDATE WDEA_SAP_CentroCostos
	SET Activo = 0,
	ModificadoEl = GETDATE(),
	ModificadoPor = @Idusuario
	WHERE Id = @IdSelected
END