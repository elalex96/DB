
CREATE FUNCTION getBancoID 
(
	@Cuenta		varchar(50)
)
RETURNS int AS
BEGIN
	declare @id int
    select @id = BancoID from PV_CuentaBancaria where	NumeroCuenta = @Cuenta
    RETURN @id
END

