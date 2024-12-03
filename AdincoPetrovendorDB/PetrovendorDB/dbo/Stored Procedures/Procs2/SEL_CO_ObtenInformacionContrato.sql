USE Petrovendor
DROP PROC IF EXISTS SEL_CO_ObtenInformacionContrato
GO
CREATE PROC SEL_CO_ObtenInformacionContrato
@IdContrato int,
@IdUsuario int
AS 
BEGIN
	select * from adinco..co_contrato as C
	join adinco..CO_TipoContrato as TC
	on C.IdTipoContrato = tc.IdTipoContrato
	where c.IdContrato = @IdContrato
END