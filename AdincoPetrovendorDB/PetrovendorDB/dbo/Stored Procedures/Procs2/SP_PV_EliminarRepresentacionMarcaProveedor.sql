

-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_EliminarRepresentacionMarcaProveedor] 
	-- Add the parameters for the stored procedure here

@IdProveedor	int ,
@IdMarca	int ,
@IdUsuario int
 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	--INSERT INTO [dbo].[PV_ProveedorRepresentaMarca]
	--([IdProveedor],[IdCredorPor],[CreadoEl],[NombreMarca],[LogoMarca],[Activo])
	--VALUES(@IdProveedor,@IdUsuario,GETDATE(),@NombreMarca,@LogoMarca,1)

	UPDATE [PV_ProveedorRepresentaMarca] 
	SET [Activo]=0,
	[IdEditadoPor]=@IdUsuario,
	[EditadoEl] = GETDATE()
	WHERE [IdMarca]= @IdMarca
	 
END
 
	


