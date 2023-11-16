USE Petrovendor
GO
DROP PROC IF EXISTS SP_CC_Inst_DesactivaCentroCostoInstalacion
GO
CREATE PROC SP_CC_Inst_DesactivaCentroCostoInstalacion
@Id INT
AS
BEGIN
	UPDATE CC_CentroCostoInstalacion
	SET ACTIVO = 0,
	ModificadoEl = GETDATE()
	WHERE IdCentroCostoInstalacion = @Id
END
