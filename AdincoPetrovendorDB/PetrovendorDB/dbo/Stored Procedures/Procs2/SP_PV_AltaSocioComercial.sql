
-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_AltaSocioComercial] 
	-- Add the parameters for the stored procedure here

@IdProveedor int, 
@IdUsuario int,
@RazonSocial NVARCHAR(350),
@RFC  NVARCHAR(350),
@Correo nvarchar(50),
@Nombre nvarchar(100),
@Telefono nvarchar(10)
 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO [dbo].[PV_SocioComercial](RazonSocial, IdProveedor, Activo, IdCreadoPor, CreadoEl,RFC, Correo, Nombre, Telefono)
	VALUES(@RazonSocial,@IdProveedor,1,@IdUsuario,GETDATE(),@RFC,@Correo,@Nombre,@Telefono)
	
END


