

-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_EditarRepresentacionMarcaProveedor] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int ,
@IdMarca	int ,
@IdUsuario int, 
@NombreMarca nvarchar(MAX),
@LogoMarca varbinary(max),
@Correo nvarchar(50),
@Telefono nvarchar(10)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--INSERT INTO [dbo].[PV_ProveedorRepresentaMarca]
	--([IdProveedor],[IdCredorPor],[CreadoEl],[NombreMarca],[LogoMarca],[Activo])
	--VALUES(@IdProveedor,@IdUsuario,GETDATE(),@NombreMarca,@LogoMarca,1)

	UPDATE [PV_ProveedorRepresentaMarca] 
	SET [NombreMarca] = @NombreMarca,
	[LogoMarca]=@LogoMarca,
	[IdEditadoPor]=@IdUsuario,
	[EditadoEl] = GETDATE(),
	[Correo] = @Correo,
	[Telefono] = @Telefono
	WHERE [IdMarca]= @IdMarca
	 
END
 
	


