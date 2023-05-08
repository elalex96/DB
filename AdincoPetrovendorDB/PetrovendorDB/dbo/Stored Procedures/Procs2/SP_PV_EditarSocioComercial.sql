
-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_EditarSocioComercial] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int, 
@IdUsuario int,
@IdSocioComercial int,
@RazonSocial nvarchar(max),
@RFC  nvarchar(max),
@Correo nvarchar(50),
@Nombre nvarchar(100),
@Telefono nvarchar(10)
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE PV_SocioComercial
	SET RazonSocial = @RazonSocial,
	[EditadoPor] = @IdUsuario,
    [EditadoEl] = GETDATE(),
	[RFC] = @RFC,
	[Correo] = @Correo,
	[Nombre] = @Nombre,
	[Telefono] = @Telefono
	WHERE IdProveedor = @IdProveedor
	AND  IdSocioComercial = @IdSocioComercial
	
END


