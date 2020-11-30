-- =============================================
-- Author:		<Pedro ,,Acuña >
-- Modified date: <16-01-2018>
-- Description:	<Revisar que el correo no este dado de alta >
-- =============================================
CREATE PROCEDURE [dbo].SP_RevisarCorreo (@Correo NVARCHAR(MAX))
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @cuenta INT

    SELECT @cuenta = COUNT(U.Correo)
    FROM dbo.S_Usuario AS U
    WHERE U.Correo = @Correo
          AND U.Activo = 1

    IF (@cuenta > 0)
        SELECT 'NoDisponible'
    ELSE
        SELECT 'Disponible'
END