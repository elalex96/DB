-- =============================================
-- Author: DANIEL AC
-- Create date: 18/08/2017
-- Description:	ACTUALIZACIÓN DE REFRENCIA DE S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_EditarDistribuidorAutorizadoDe] 
	-- Add the parameters for the stored procedure here
@IdProveedor int,
@IdUsuario int, 
@NombreEmpresa nvarchar(MAX),
@FechaIniciooperaciones nvarchar(200),
@RFC nvarchar(300),
@DocumentoAutorizacion nvarchar(max),
@Descripcion nvarchar(max),
@IdDistribuidorAutorizado int,
@IdDocumento int,
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
	[FechaInicioDistribucion]=@FechaIniciooperaciones,
	[Descripcion]=@Descripcion,
	[EditadoEl]=GETDATE(),
	[IdEditadoPor]=@IdUsuario,
	Correo = @Correo,
	Telefono = @Telefono
	WHERE [IdDistribuidorAutorizado]=@IdDistribuidorAutorizado
	

	UPDATE [S_Documento_S3]
	SET [Documento]=@DocumentoAutorizacion,
	[ModificadoPor]=@IdUsuario,
	[ModificadoEl]=GETDATE()
	WHERE [IdDocumento]=@IdDocumento 

	SELECT 'Update'
END