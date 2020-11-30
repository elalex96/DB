-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_ConsultarTitulo]
	-- Add the parameters for the stored procedure here
	@IdModulo INT,
	@IdIdioma INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT T.NombreTitulo, T.NombreSubtitulo 
  FROM dbo.Titulos AS T
  LEFT JOIN dbo.TituloModulo AS TM ON TM.IdTitulo = T.IdTitulo
  WHERE TM.IdModulo = @IdModulo AND T.IdIdioma = @IdIdioma
END
