USE Petrovendor
GO
DROP PROC IF EXISTS SP_CC_Inst_GuardaRelacionCentroCostoIntalacion
GO
CREATE PROC SP_CC_Inst_GuardaRelacionCentroCostoIntalacion
@IdCentroCosto int,
@IdInstalacion int
as
begin
declare @IdContrato int= (select C.IdContrato
							from Adinco..CO_Contrato C
							where REPLACE(RTRIM(LTRIM(C.NumeroContrato)),' ','') = 'CNH-PICOVILLAHERMOSA')
	if ((SELECT COUNT(1) FROM CC_CentroCostoInstalacion WHERE IdCentroCosto = @IdCentroCosto and IdInstalacion = @IdInstalacion and Activo = 1) = 0) and
	((SELECT COUNT(1) FROM CC_CentroCostoInstalacion WHERE IdCentroCosto = @IdCentroCosto and IdInstalacion = @IdInstalacion and Activo = 0) = 0)
	begin
		INSERT INTO CC_CentroCostoInstalacion
		(IdCentroCosto,IdInstalacion,IdContrato,Activo,CreadoEl) values
		(@IdCentroCosto,@IdInstalacion,@IdContrato,1,GetDate())
	end
	else if (SELECT COUNT(1) FROM CC_CentroCostoInstalacion WHERE IdCentroCosto = @IdCentroCosto and IdInstalacion = @IdInstalacion and Activo = 0) = 1
	begin
		UPDATE CC_CentroCostoInstalacion
		SET Activo = 1,
		ModificadoEl = GETDATE()
		WHERE IdCentroCosto = @IdCentroCosto and IdInstalacion = @IdInstalacion and Activo = 0
	end
	else
	begin
		select 'YA_EXISTE' as Error
	end
end
