CREATE PROCEDURE [dbo].[SP_FACTURAS_COMPROBARSIEXISTE]
@idFacturaHijo int
AS
BEGIN
	SELECT 
	*
	FROM FI_RelacionRefacturas 
	WHERE idFacturaHijo = @idFacturaHijo
END;
