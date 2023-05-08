--Created by: Luis David De La Cruz Bautista
CREATE PROCEDURE [dbo].[SP_FACTURAS_LIMPIARPORFACTURAPADRE]
@idFacturaPadre int
AS
BEGIN
	
	DELETE
	FROM FI_RelacionRefacturas 
	WHERE idFacturaPadre =@idFacturaPadre
END;
