-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultarModuloAgregado]
	-- Add the parameters for the stored procedure here
	@idmodulo INT,
	@ididioma INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT IdTitulosModulo
  FROM dbo.TituloModulo AS TM 
  INNER JOIN dbo.Titulos AS T ON T.IdTitulo = TM.IdTitulo
  WHERE TM.IdModulo = @idmodulo AND T.IdIdioma = @ididioma
  
END
