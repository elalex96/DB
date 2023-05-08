-- =============================================
-- Author:		Alexander G
-- Create date: 27-06-17
-- Description:	Consultar Detalles de flujo tarea especifico 
-- =============================================
CREATE PROCEDURE [dbo].[sp_ConsultaDetallesFlujoTarea]
	-- Add the parameters for the stored procedure here
	@IdFlujoTarea int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
		
	SELECT FT.Nombre, FT.Descripcion, TOF.NombreOperacion AS TipoOperacion, TFT.Nombre AS TipoFlujo, UT.Nombre AS CreadoPor
	 FROM TA_FlujoTarea AS FT
	 INNER JOIN TA_TipoOperacion AS TOF ON TOF.IdTipoOperacion = FT.IdTipoOperacion
	 INNER JOIN TA_TipoFlujoTarea AS TFT ON TFT.IdTipoFlujoTarea = FT.IdTipoFlujo
	 LEFT JOIN S_Usuario AS UT ON UT.IdUsuario = FT.CreadorPor
	 WHERE FT.IdFlujoTarea =  @IdFlujoTarea

END


