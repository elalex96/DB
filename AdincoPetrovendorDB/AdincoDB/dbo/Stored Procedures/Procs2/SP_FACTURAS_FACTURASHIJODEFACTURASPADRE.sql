--Created by: Luis David De La Cruz Bautista
CREATE PROCEDURE [dbo].[SP_FACTURAS_FACTURASHIJODEFACTURASPADRE]
@IdFacturaPadre int
AS
BEGIN
	SELECT 
	IdFacturahijo,IdFacturaPadre 
	FROM FI_RelacionRefacturas 
	WHERE idFacturaPadre = @IdFacturaPadre
END;

