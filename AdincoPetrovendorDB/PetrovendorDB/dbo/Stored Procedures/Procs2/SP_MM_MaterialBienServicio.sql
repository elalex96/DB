-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/07/2017
-- Description:	Metodo que obtiene los nombres de un grupo, familia, tipo, unidad y subfamilia de un material
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_MaterialBienServicio]
	-- Add the parameters for the stored procedure here
	@IdBienServicio int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdMaestro,TextoCorto AS TextoLargo
	FROM MM_Maestro
	WHERE IdTipoCatalogoMaestro = @IdBienServicio 
	ORDER BY  TextoCorto ASC 
END


