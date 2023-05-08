-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 26/03/2018
-- Description:	CONSULTAR LOS FLUJO DE UN TIPO DE OPERACIÓN
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ConsultarFlujoListaxTipoOperacion] 
	-- Add the parameters for the stored procedure here

 @IdProveedor INT, 
 @IdTipoOperacion INT,
 @IdContrato INT = 0,
 @IdUsuario INT	 = 0 

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
	WHERE OPE.IdTipoOperacion=@IdTipoOperacion AND (FT.Eliminado =  0 OR FT.Eliminado IS NULL) AND FT.IdProveedor= @IdProveedor

 
END
