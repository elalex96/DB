CREATE PROC p_FI_Factura_Sel
@pUUID Varchar(50),
@pIdContrato INT
AS

	Select * 
	from FI_Factura FI
	WHERE FI.UUID = @pUUID AND
	FI.IdContrato = @pIdContrato