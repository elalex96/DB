CREATE procedure AD_SP_UpdateProveedores
	@IdProveedor INT,
	@RFC NVARCHAR(max),
	@IdNacionalidad INT,
	@RazonSocial NVARCHAR(max),
	@IdTipoRegimen INT,
	@IsEliminado BIT,
	@Activo bit
AS
BEGIN
	UPDATE dbo.S_Proveedor 
		SET	RFC = @RFC,
			IdNacionalidad = @IdNacionalidad,
			RazonSocial = @RazonSocial,
			IdTipoRegimen = @IdTipoRegimen,
			IsEliminado = @IsEliminado,
			Activo = @Activo
		WHERE IdProveedor = @IdProveedor
END