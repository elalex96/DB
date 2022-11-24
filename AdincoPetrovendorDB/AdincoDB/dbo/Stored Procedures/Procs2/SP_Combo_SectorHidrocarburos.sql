CREATE    PROCEDURE [dbo].[SP_Combo_SectorHidrocarburos]
AS
BEGIN
    SELECT IdCatalogoCuentasSH,
          CONCAT ( nivel3, ' - ',  Descripcion) as Descripcion
    FROM CO_CatalogoCuentaSH
	WHERE IdVersion = (SELECT MAX(IdVersion) FROM Adinco..CO_VersionCatalogoCuentasSH)
END
