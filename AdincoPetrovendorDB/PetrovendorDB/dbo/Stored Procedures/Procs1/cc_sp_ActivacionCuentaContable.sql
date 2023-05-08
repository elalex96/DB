CREATE PROCEDURE cc_sp_ActivacionCuentaContable
@Id Int
as
BEGIN
	DECLARE @activado Bit;
	set @activado = (SELECT top 1 Activo FROM DG_CuentaContable WHERE Id = @Id);

	if @activado = 1
	begin
		set @activado = 0
	end
	else
	begin
		set @activado = 1
	end
	UPDATE DG_CuentaContable
	SET Activo = @activado
	WHERE Id = @Id
END