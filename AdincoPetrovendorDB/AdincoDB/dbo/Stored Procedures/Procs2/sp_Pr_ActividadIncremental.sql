-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07-10-2019
-- Description:	Consulta para el combo de Actividad Incremental
-- =============================================
CREATE PROCEDURE sp_Pr_ActividadIncremental
AS
BEGIN
    SELECT ISNULL(ActividadIncremental, '-') AS ID,
           ISNULL(ActividadIncremental, '-') AS ActividadIncremental
    FROM dbo.PR_Pozo
    GROUP BY ISNULL(ActividadIncremental, '-');
END;

