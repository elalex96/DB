
-- =============================================
-- Author:       Pedro Acuna
-- Fecha Modificado: 2020-10-26
-- Description:     Se revisa si el rfc existe en la BD
-- =============================================
CREATE PROCEDURE RevisarExisteProveedor @RFC NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.PV_Subcontratista
        WHERE LTRIM(RTRIM(RFC)) = LTRIM(RTRIM(@RFC))
		AND IsActivo = 1
    )
    BEGIN
        SELECT 1;
    END;
    ELSE
    BEGIN
        SELECT 0;
    END;

END;
