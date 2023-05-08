-- =============================================
-- Author:		DANIEL AC
-- Create date: 05/06/2017
-- Description:	ACTUALIZAR DOMICILIO FISCAL , MATRIZ O SUCURSAL
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_ActualizarDomicilio]
	-- Add the parameters for the stored procedure here
	@IdDomicilio int, 
	@IdPais int,
	@Estado nvarchar(300),
	@Municipio nvarchar(300),
	@Colonia nvarchar(500), 
	@Calle nvarchar(300),
	@NoExterior nvarchar(300),
	@NoInterior nvarchar(300),
	@NombreViabilidad nvarchar(500),
	--@TipoViabilidad nvarchar(500),
	@IdProveedor int, 
	@IdUsuario int, 
	@CodigoPostal nvarchar(150),
	@IdTipoDomicilio int
	 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	UPDATE  DG_Domicilio
	SET IdPais=@IdPais, 
	Estado=@Estado,
	Municipio=@Municipio,
	Colonia=@Colonia, 
	--TipoViabilidad=@TipoViabilidad, 
	NombreViabilidad=@NombreViabilidad,
	NoExterior=@NoExterior, 
	NoInterior=@NoInterior, 
	CodigoPostal=@CodigoPostal,
	IdActualizadoPor = @IdUsuario,
	FechaCambio = GETDATE(), 
	Calle = @Calle

	WHERE IdDomicilio = @IdDomicilio AND IdProveedor=@IdProveedor
	
	--- Actualizar Tabla de S_Proveedor ---
	DECLARE @IdTipoSolicitud int = (SELECT IdTipoDomicilio 
								FROM DG_Domicilio
								WHERE IdDomicilio =@IdDomicilio)

   IF @IdTipoSolicitud = 1 
   BEGIN 
	UPDATE S_Proveedor
	SET IdPais=@IdPais, 
	Entidad=@Estado,
	Municipio=@Municipio,
	Colonia=@Colonia, 
	--TipoVialidad=@TipoViabilidad, 
	NombreVialidad=@NombreViabilidad,
	NumExterior=@NoExterior, 
	NumInterior=@NoInterior, 
	CodigoPostal=@CodigoPostal
	WHERE IdProveedor=@IdProveedor
	END 

END

