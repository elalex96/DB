-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_TA_ConsultarTipoOperacion_Desarrollo
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	 SELECT TTO.IdTipoOperacion, TTO.NombreOperacion
	 FROM TA_TipoOperacion AS TTO
	 WHERE TTO.Activo = 1

END
