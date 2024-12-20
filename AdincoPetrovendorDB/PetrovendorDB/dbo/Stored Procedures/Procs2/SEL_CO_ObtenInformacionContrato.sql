USE Petrovendor
DROP PROC IF EXISTS SEL_CO_ObtenInformacionContrato
GO
-- =============================================
-- Author:		Luis David
-- Create date: 4/12/2024
-- Description:	Se obtiene la información del contrato
-- =============================================
CREATE PROC SEL_CO_ObtenInformacionContrato
@IdContrato int,
@IdUsuario int
AS 
BEGIN
	select * from adinco..co_contrato as C (NOLOCK)
	join adinco..CO_TipoContrato as TC (NOLOCK)
	on C.IdTipoContrato = tc.IdTipoContrato
	where c.IdContrato = @IdContrato
END
