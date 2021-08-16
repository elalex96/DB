DROP FUNCTION IF EXISTS fnObtenCentroCosto
GO
CREATE FUNCTION fnObtenCentroCosto
(
	@IdFactura int
)
RETURNS varchar(MAX)
as
BEGIN 
	DECLARE @CentrosDeCosto VARCHAR (MAX) = ''

	SELECT distinct @CentrosDeCosto = @CentrosDeCosto + '['+ RTRIM(LTRIM(ISNULL( CC.CentroCosto,''))) + '] '
	FROM Petrovendor..CO_Registro R
	JOIN CC_CentroCosto CC
	ON CC.IdCentroCosto = R.CentroCostos
	WHERE R.IdFactura = @IdFactura
	RETURN @CentrosDeCosto
END