-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017 - UPDATE 13/08/2017
-- Description:	Permite agregar un condicion a un flujo de tareas
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ConsultarFlujoFactura] 
	-- Add the parameters for the stored procedure here
 @IdProveedor int 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here
	SELECT 
	FT.IdFlujoTarea,
	FT.Nombre AS Nombreflujo,
	FT.Descripcion,
	TF.Nombre AS TipoFlujo,
	ISNULL(FT.Predeterminado,0) AS Predeterminado
	FROM TA_FlujoTarea AS FT
	INNER JOIN TA_TipoOperacion AS OPE ON OPE.IdTipoOperacion= FT.IdTipoOperacion
	INNER JOIN TA_TipoFlujoTarea AS TF ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
	WHERE OPE.IdTipoOperacion=10 AND (FT.Eliminado =  0 OR FT.Eliminado IS NULL) AND FT.IdProveedor= @IdProveedor

 
END

