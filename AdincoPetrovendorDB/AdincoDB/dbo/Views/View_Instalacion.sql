CREATE VIEW [dbo].[View_Instalacion]
AS
SELECT        IdInstalacion, NombreInstalacion, IdInstalacionPemex, EsBolsa, IdActividad, FecMovto, NombreInstalacionAlterno, IdCatalogoSCIEP, IdAreaContractual, CUIP, WelIID, IdYacimiento, IdCampo, UTMX, UTMY, IdEstatus, 
                         Activo
FROM            dbo.CO_Instalacion