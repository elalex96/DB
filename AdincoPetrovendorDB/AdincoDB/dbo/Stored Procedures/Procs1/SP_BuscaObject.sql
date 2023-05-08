-- =============================================
-- Author:		Reyna Olvera
-- Create date: 28/06/2018
-- Description:	Busca Objetos
-- =============================================
CREATE PROCEDURE SP_BuscaObject @Nombre NVARCHAR(MAX)
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID(N'' + @Nombre))
    BEGIN
        SELECT 'El objeto existe ' + @Nombre AS EXISTE;
    END;
    ELSE
    BEGIN
        SELECT 'El NO objeto existe ' + @Nombre AS NoEXISTE;
    END;

END;
