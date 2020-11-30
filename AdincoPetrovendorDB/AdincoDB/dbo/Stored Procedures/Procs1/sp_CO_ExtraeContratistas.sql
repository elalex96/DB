-- =============================================
-- Author:		Reyna Olvera
-- =============================================
CREATE PROCEDURE sp_CO_ExtraeContratistas
AS
BEGIN

    SET NOCOUNT ON;

Select 
IdContratista,
NombreContratista,
LogoHTML,
--,Logo
Abreviatura
FROM
	CO_Contratista 
ORDER BY NombreContratista;

END
