
CREATE FUNCTION getTitularCuenta
(
	@Cuenta		varchar(50)
)
RETURNS varchar(50) AS
BEGIN
	declare @titular varchar(50)
    select @titular = Titular from PV_CuentaBancaria where	NumeroCuenta = @Cuenta
    RETURN @titular
END

