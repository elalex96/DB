-- =============================================
-- Author:       Reyna Olvera
-- =============================================
CREATE PROCEDURE sp_OT_RevisarExisteUnidad @nombreUnidad VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

        SELECT  TOP 1
		ISNULL(IsActivo, 0)
        FROM Petrovendor..PV_MM_MaterialUnidad
        WHERE LTRIM(RTRIM(Unidad)) = LTRIM(RTRIM(@nombreUnidad))
		ORDER BY IsActivo DESC

END;

