-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 24/Marzo/2017 
-- Description:	Consultar flujo de compra directa 
-- Update 27/02/2018 Agregue activo = 1
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ConsultarFlujoCompraDirecta] 
	-- Add the parameters for the stored procedure here
 @IdProveedor int 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here

	SELECT 
	ft.IdFlujoTarea,
	ft.Nombre AS Nombreflujo,
	Descripcion,	
	TF.Nombre AS TipoFlujo	
	FROM
	TA_FlujoTarea AS FT
	INNER JOIN TA_TipoOperacion AS OPE ON OPE.IdTipoOperacion= FT.IdTipoOperacion
	LEFT JOIN TA_FlujoTareaCondicion AS CO ON CO.IdFlujoTarea = FT.IdFlujoTarea
	INNER JOIN TA_TipoFlujoTarea AS TF ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
	WHERE OPE.IdTipoOperacion=14 AND FT.Activo=1 AND FT.IdProveedor= @IdProveedor
END
