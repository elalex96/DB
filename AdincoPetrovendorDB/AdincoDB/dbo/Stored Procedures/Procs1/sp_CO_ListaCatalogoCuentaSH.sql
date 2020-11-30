-- =============================================
-- Author:		Manuel Cruz
-- Create date: 24-05-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ListaCatalogoCuentaSH] 
-- Add the parameters for the stored procedure here
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         SELECT LTRIM(IdCatalogoCuentasSH) AS IdCatalogoCuentasSH, 
                Nivel3, 
                concat(Nivel3, '-', CC.Descripcion) AS Descripcion
         FROM CO_CatalogoCuentaSH CC
              JOIN CO_VersionCatalogoCuentasSH VCC ON CC.IdVersion = VCC.IdVersion
         WHERE vcc.IdVersion = 10002; --Activo = 1;
     END;