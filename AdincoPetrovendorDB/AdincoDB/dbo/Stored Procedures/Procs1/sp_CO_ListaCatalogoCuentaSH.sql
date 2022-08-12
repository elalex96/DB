-- =============================================
-- Author:		Manuel Cruz
-- Create date: 24-05-17
-- Description:	
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	09 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK y la llamada de columnas con nombre especifico de la tabla durante su llamado.
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ListaCatalogoCuentaSH]
-- Add the parameters for the stored procedure here
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- Insert statements for procedure here
    SELECT LTRIM(CO_CatalogoCuentaSH.IdCatalogoCuentasSH) AS IdCatalogoCuentasSH,
           CO_CatalogoCuentaSH.Nivel3,
           concat(CO_CatalogoCuentaSH.Nivel3, '-', CO_CatalogoCuentaSH.Descripcion) AS Descripcion
    FROM CO_CatalogoCuentaSH (NOLOCK)
        JOIN CO_VersionCatalogoCuentasSH (NOLOCK)
            ON CO_CatalogoCuentaSH.IdVersion = CO_VersionCatalogoCuentasSH.IdVersion
    WHERE CO_VersionCatalogoCuentasSH.IdVersion = 10002;
END;