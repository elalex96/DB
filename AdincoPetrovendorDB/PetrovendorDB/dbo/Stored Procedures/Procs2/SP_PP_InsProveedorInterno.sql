-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06/09/2018
-- Description:	Guardado de un proveedor agregado por otro proveedor
-- =============================================
CREATE PROCEDURE [dbo].[SP_PP_InsProveedorInterno] 
	-- Add the parameters for the stored procedure here
	@IdProveedorActual INT,
	@IdUsuarioActual INT,
	@NuevoProveedor NVARCHAR(MAX),
	@Calle NVARCHAR(MAX),
	@NExt NVARCHAR(MAX),
	@NInt NVARCHAR(MAX),
	@Ciudad NVARCHAR(MAX),
	@Estado NVARCHAR(MAX),
	@CP NVARCHAR(MAX),
	@Observaciones NVARCHAR(MAX),
	@RFC NVARCHAR(MAX)=NULL,
	@IdPais INT =NULL,
	@IsCliente BIT = NULL,
	@IsProveedor BIT =NULL,
	@Etiquetas NVARCHAR(max)=NULL,
	@Colonia NVARCHAR(MAX)
        
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @IDPROVEEDORNUEVO INT;
	
	--VALIDAR NO ESTE REGISTRADO 

	SELECT @IDPROVEEDORNUEVO = IdProveedor 
	FROM DA_Proveedor 
	WHERE RFC != '' 
	AND RFC = @RFC 
	AND Activo = 1 
	AND ISNULL(ProveedorInterno,0)=1  --> VALIDAR SEA PROVEEDOR INTERNO
	AND RegistradoPorProveedor=@IdProveedorActual --> VALIDAR QUE ESTE EN EL CATÁLOGO DE PROVEEDORES INTERNOS DEL PROVEEDOR ACTUAL 
	AND ISNULL(IsEliminado,0) =  0 


	IF ISNULL(@IDPROVEEDORNUEVO,0)=0
	BEGIN 
    -- Insert statements for procedure here
	INSERT INTO dbo.DA_Proveedor
	(
	    RazonSocial,
	    NombreComercial,
	    Activo,
	    FechaRegistro,
	    IdUsuarioRegistro,
	    Descripcion,
	    FechaActivacion,
	    ProveedorInterno,
	    RegistradoPorProveedor,
		RFC,
		IsCliente,
		IsProveedor,
		Etiquetas
	)
	VALUES
	(  
	    @NuevoProveedor,       -- RazonSocial - nvarchar(max)
	    @NuevoProveedor,       -- NombreComercial - nvarchar(500)
	    1,      -- Activo - bit
	    GETDATE(), -- FechaRegistro - datetime
	    @IdUsuarioActual,         -- IdUsuarioRegistro - int
	    @Observaciones,       -- Descripcion - nvarchar(max)
	    GETDATE(), -- FechaActivacion - datetime
	    1,      -- ProveedorInterno - bit
	    @IdProveedorActual,          -- RegistradoPorProveedor - int
		@RFC,
		@IsCliente,
		@IsProveedor,
		@Etiquetas
	    )


		SET @IDPROVEEDORNUEVO = (SELECT @@IDENTITY)

		INSERT INTO dbo.DA_Domicilio
		(
		    Estado,
		    Municipio,
		    NoExterior,
		    NoInterior,
		    CodigoPostal,
		    IdTipoDomicilio,
		    IdProveedor,
		    IdCreadoPor,
		    FechaRegistro,
		    Activo,
		    Calle,
			IdPais,
			Colonia
		)
		VALUES
		(   @Estado,
			@Ciudad,
			@NExt,
			@NInt,
			@CP,
			1,---> DOMICILIO FISCAL
			@IDPROVEEDORNUEVO,
			@IdUsuarioActual,
			GETDATE(),
			1,
			@Calle,
			@IdPais,
			@Colonia
		    )

			SELECT 'SUCCESS',@IDPROVEEDORNUEVO
	END 
	ELSE
	BEGIN 
	--YA ESTABA REGISTRADO SE RETORNA EL ID DEL REGISTRO
			SELECT 'SUCCESS',@IDPROVEEDORNUEVO

	END 


END
 