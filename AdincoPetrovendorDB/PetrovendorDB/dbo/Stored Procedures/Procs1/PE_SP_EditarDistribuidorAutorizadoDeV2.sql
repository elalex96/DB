
-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[PE_SP_EditarDistribuidorAutorizadoDeV2] 
	-- Add the parameters for the stored procedure here
	@IdProveedor int,
	@IdUsuario int, 
	@NombreEmpresa nvarchar(MAX),
	@FechaInicioDistribucion DATETIME,
	@RFC nvarchar(300),
	--@DocumentoAutorizacion nvarchar(max),
	@Descripcion nvarchar(max),
	@IdDistribuidorAutorizado int,
	--@IdDocumento int,
	@Correo nvarchar(50),
	@Telefono nvarchar(10)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	UPDATE 
	[dbo].[PV_DistribuidorAutorizado]
    SET 
	[RFC]=@RFC,
	[NombreEmpresa]=@NombreEmpresa,
	[FechaInicioDistribucion]=@FechaInicioDistribucion,
	[Descripcion]=@Descripcion,
	[EditadoEl]=GETDATE(),
	[IdEditadoPor]=@IdUsuario,
	Correo = @Correo,
	Telefono = @Telefono
	WHERE [IdDistribuidorAutorizado]=@IdDistribuidorAutorizado
	
END
