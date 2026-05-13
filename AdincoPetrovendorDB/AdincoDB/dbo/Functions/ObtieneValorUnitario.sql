CREATE FUNCTION dbo.ObtieneValorUnitario
(
    @pIdFactura INT
)
RETURNS FLOAT
AS
BEGIN
DECLARE @VALOR FLOAT

	    SELECT @VALOR = SUM(ValorUnitario)
	    FROM FI_CFDIConcepto
	    WHERE IdFactura = @pIdFactura

	    RETURN @VALOR
END