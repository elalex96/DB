

-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_AltaRepresentacionMarcaProveedor] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int ,
@IdUsuario int, 
@NombreMarca nvarchar(MAX),
@LogoMarca varbinary(max),
@Correo nvarchar(50),
@Telefono nvarchar(10)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	INSERT INTO [dbo].[PV_ProveedorRepresentaMarca]
	([IdProveedor],[IdCredorPor],[CreadoEl],[NombreMarca],[LogoMarca],[Activo],Correo, Telefono)
	VALUES(@IdProveedor,@IdUsuario,GETDATE(),@NombreMarca,@LogoMarca,1,@Correo,@Telefono)
	
END
 
	


