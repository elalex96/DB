-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07-10-2019
-- Description:	Consulta para el combo de tipo producción
-- =============================================
CREATE PROCEDURE sp_Pr_extraeTipoProduccion
AS
BEGIN
	SELECT ISNULL(TipoProduccion,0) AS ID, ISNULL(TipoProduccion,0) AS TipoProduccion
	FROM dbo.PR_Pozo
	GROUP BY ISNULL(TipoProduccion,0)
END