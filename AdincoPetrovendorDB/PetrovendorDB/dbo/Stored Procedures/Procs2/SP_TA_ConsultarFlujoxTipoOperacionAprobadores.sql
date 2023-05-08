-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 26/036/2018
-- Description:	Permite consultar los aprobadores de un flujo de operación por tipo de operación
-- =============================================
CREATE  PROCEDURE  [dbo].[SP_TA_ConsultarFlujoxTipoOperacionAprobadores] 
	-- Add the parameters for the stored procedure here
 @IdProveedor INT, 
 @IdFlujoAprobacion INT,
 @IdTipoOperacion INT,
 @IdContrato INT,
 @IdUsuario INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here

	SELECT
	AP.IdAprobador,
	U.Nombre AS Aprobador,
	U.Correo,
	AP.NoSecuencia,
	FT.IdFlujoTarea
	FROM
	TA_FlujoTarea AS FT
	INNER JOIN TA_TipoOperacion AS OPE ON OPE.IdTipoOperacion= FT.IdTipoOperacion
	INNER JOIN TA_TipoFlujoTarea AS TF ON TF.IdTipoFlujoTarea = FT.IdTipoFlujo
	INNER JOIN TA_Aprobador AS AP ON AP.IdFlujoTarea = FT.IdFlujoTarea 
	INNER JOIN S_Usuario AS U ON U.IdUsuario = AP.IdUsuario
	WHERE OPE.IdTipoOperacion=@IdTipoOperacion AND (FT.Eliminado =  0 OR FT.Eliminado IS NULL) AND FT.IdProveedor= @IdProveedor  
	AND FT.[IdFlujoTarea] = @IdFlujoAprobacion


END
