
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 27-03-17
-- Description:	Regresa los flujo de tarea por tipo de operacion
-- Update: Daniel AC 30/08/2017
-- Description: Agregue validación que solo me muestre Flujos no Eliminados 
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_TA_ConsultarFlujosTareaXTipoOperacion] 
	-- Add the parameters for the stored procedure here
	 @IdTipoOperacion int,
	 @IdProveedor int
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT IdFlujoTarea, Concat(Nombre , ' - ',Descripcion) as Descripcion
	 FROM TA_FlujoTarea
	 WHERE IdTipoOperacion = @IdTipoOperacion
	 AND IdProveedor = @IdProveedor
	 and ( Activo is null or Activo = 1) And (Eliminado = 0 OR Eliminado is null)
END



