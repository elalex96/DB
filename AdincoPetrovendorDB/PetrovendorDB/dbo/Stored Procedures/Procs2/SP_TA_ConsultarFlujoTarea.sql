
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 27-03-17
-- Description:	Regresa los aprobadores de un flujo de tarea
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_TA_ConsultarFlujoTarea] 
	-- Add the parameters for the stored procedure here
	 @IdFlujoTarea int 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT IdFlujoTarea, Condicion, Mensaje, IdTipoFlujo, NombreOperacion, TO_.IdTipoOperacion, IdProveedor, CreadorPor as IsAsignador, Descripcion
	 FROM TA_FlujoTarea AS FT
	 INNER JOIN TA_TipoOperacion AS TO_ ON TO_.IdTipoOperacion = FT.IdTipoOperacion
	 WHERE IdFlujoTarea = @IdFlujoTarea;

END



