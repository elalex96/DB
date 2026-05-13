-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 11/09/2017
-- Description:	Eliminar flujo de aprobación de factura 
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_EliminarFlujoFactura] 
	-- Add the parameters for the stored procedure here
 @IdProveedor int, 
 @IdFlujoTarea int,
 @IdUsuario int
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	 
    -- Insert statements for procedure here


		UPDATE [dbo].[TA_FlujoTarea]
		SET [Eliminado]= 1,
		[Activo]= 0,
		[Predeterminado] = 0,
		[IdModificadoPor]=  @IdUsuario,
		[ModificadorEl] =GETDATE()
		WHERE [IdFlujoTarea]= @IdFlujoTarea AND [IdProveedor]= @IdProveedor 
END

