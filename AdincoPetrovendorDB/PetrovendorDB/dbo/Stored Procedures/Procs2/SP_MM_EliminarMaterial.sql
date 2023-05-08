-- =============================================
-- Author:		Daniel Cruz 
-- Create date: 22-03-17
-- Description:	Eliminar Material = Producto - Servicio
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_EliminarMaterial] 
	-- Add the parameters for the stored procedure here
	@IdMaterial int

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	
    -- Insert statements for procedure here
	UPDATE MM_Material SET
	Activo = 0
	WHERE IdMaterial=@IdMaterial


	SELECT 'Material Eliminado' AS Respose

END


