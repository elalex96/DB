
-- =============================================
-- Author:		<Alexander G>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_CantadorBienesServicios] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @MATERIALESTOTAL INT = (select count(*) from MM_Material)
	DECLARE @MATERIALESACTIVO INT = (SELECT COUNT(*) FROM MM_Material WHERE Activo = 1)
	DECLARE @MATERUALESINACTIVO INT = (SELECT COUNT(*) FROM MM_Material WHERE Activo = 0)
	DECLARE @MATERUALESCOMPRAS INT = (SELECT COUNT(*) FROM MM_MaterialesCompraProveedor)
	DECLARE @MATERUALESVENTAS INT = (SELECT COUNT(*) FROM MM_MaterialesVentaProveedor)

	SELECT @MATERIALESTOTAL AS MATERIALESTOTAL,
			@MATERIALESACTIVO AS MATERIALESACTIVO,
			@MATERUALESINACTIVO AS MATERUALESINACTIVO,
			@MATERUALESCOMPRAS AS MATERUALESCOMPRAS,
			@MATERUALESVENTAS AS MATERUALESVENTAS

END
