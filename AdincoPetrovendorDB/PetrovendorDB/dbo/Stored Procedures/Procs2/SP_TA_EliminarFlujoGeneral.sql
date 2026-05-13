-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 06/03/2018
-- Description:	Eliminar flujo de cualquier tipo de operación
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_EliminarFlujoGeneral] 
	-- Add the parameters for the stored procedure here
 @IdProveedor int, 
 @IdFlujoTarea int,
 @IdUsuario INT,
 @IdContrato INT = 0
	 
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

		SELECT 'SUCCESS'
END
