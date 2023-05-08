-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07-10-2019
-- Description:	Consulta para el combo de Actividad Incremental
-- =============================================
CREATE PROCEDURE sp_Pr_ExtraeLineaDescarga
AS
BEGIN
	SELECT ISNULL(LDD,'0') AS ID, ISNULL(LDD,'0') AS LDD
	FROM dbo.PR_Pozo
	GROUP BY ISNULL(LDD,'0')
END
