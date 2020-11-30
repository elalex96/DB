-- =============================================
-- Author:		<Jose Roman>
-- Create date: <20-03-2018>
-- Description:	<Se registra un nuevo proveedor y se relaciona con el usuario registrado anteriormente>
-- ============================================
CREATE procedure S_SP_RegistrarProveedor
	@IdUsuario INT,
	@IdNacionalidad INT,
	@RFC VARCHAR(30),
	@IdTipoRegimen INT,
	@RazonSocial NVARCHAR(max),
	@IdPais INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    --@IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	INSERT INTO dbo.S_Proveedor
	(
	    IdNacionalidad,
	    RFC,
	    IdTipoRegimen,
	    RazonSocial,
		IdPais,
		Activo
	)
	VALUES
	(   @IdNacionalidad,        -- IdNacionalidad - int
	    @RFC,					-- RFC - varchar(30)
	    @IdTipoRegimen,         -- IdTipoRegimen - int
	    @RazonSocial,			-- RazonSocial - nvarchar(max)
		@IdPais,
		0
	)

	DECLARE @IdProveedor INT = @@IDENTITY

	INSERT INTO dbo.S_UsuarioProveedor
	(
	    IdUsuario,
	    IdProveedor,
	    IsAdmin
	)
	VALUES
	(   @IdUsuario,		 -- IdUsuario - int
	    @IdProveedor,    -- IdProveedor - int
	    1				 -- IsAdmin - bit
	)

	declare @pais varchar(100)
	select @pais = Pais from CAT_Paises

	insert into Adinco..PV_Subcontratista
	(
		IdPetroVendor,
		NacionalidadID,
		RFC,
		TipoPersonaFiscalID,
		RazonSocial,
		UsuarioID,
		Pais,
		IsEliminado,
		IsActivo
	)
	values
	(
		@IdProveedor,
		@IdNacionalidad,
		@RFC,
		@IdTipoRegimen,
		@RazonSocial,
		null,
		@pais,
		0,
		1
	)


	--PV_Subcontratista
END