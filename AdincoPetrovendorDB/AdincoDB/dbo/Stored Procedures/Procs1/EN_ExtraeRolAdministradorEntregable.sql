-- =============================================
-- Author:		Reyna O.
-- Create date: 2019-01-19
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[EN_ExtraeRolAdministradorEntregable] --10010,10090
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @Count INT;
    SELECT @Count = COUNT(*)
      FROM dbo.EN_Actividad
     WHERE Estadoid  = 10002
       AND idUsuario = @IdUsuario;

    IF @Count > 0
    BEGIN
        SELECT 2;
    END;
    ELSE
        SELECT 0;
END;
