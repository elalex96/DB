CREATE PROCEDURE [dbo].RevisarFacturaPerteneceAContrato @IdFactura INT, @IdContrato INT 
AS    
BEGIN
		IF EXISTS(SELECT 1 FROM FI_FACTURA WHERE IdFactura = @IdFactura AND IdContrato = @IdContrato)
		BEGIN
			SELECT 1
		END
		ELSE
		BEGIN
			SELECT 0
		END
END



