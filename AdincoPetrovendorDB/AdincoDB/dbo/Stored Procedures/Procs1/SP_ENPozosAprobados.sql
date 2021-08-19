-- =============================================
-- Author:		Luis David
-- Create date: 18/08/2021
-- Description:	SP para conteo de pozos aprobados
-- =============================================
CREATE PROCEDURE SP_ENPozosAprobados
@IdContrato Int,
@IdUsuario Int
AS
BEGIN
	SELECT 'Existen ## pozos aprobados' AS PozosAprobados
END