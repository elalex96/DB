
-- =============================================
-- Author:		<Ronal>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CantadorMaterialesServicios] 
	-- Add the parameters for the stored procedure here
@IdProveedor int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	select count(*) AS CANT_MATERIAL from MM_Material where IdProveedor = @IdProveedor AND Activo = 1

END
