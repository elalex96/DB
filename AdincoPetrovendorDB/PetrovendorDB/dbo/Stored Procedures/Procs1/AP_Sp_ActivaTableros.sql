--USE Petrovendor
--GO
CREATE PROCEDURE AP_Sp_ActivaTableros
	@IdTablero INT,
	@IdContrato INT
AS
BEGIN
	DECLARE @Activo Bit;

	set @Activo = (SELECT Activo from AP_Tableros where Id = @IdTablero)
	if @Activo = 1
	begin
		set @Activo = 0
	end
	else
	begin
		set @Activo = 1
	end
	UPDATE Ap_tableros
	SET Activo = @Activo
	where Id = @IdTablero and IdContrato = @IdContrato
END