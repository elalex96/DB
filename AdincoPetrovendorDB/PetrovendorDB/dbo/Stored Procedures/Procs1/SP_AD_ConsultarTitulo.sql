-- =============================================
-- Author:		DAC
-- Modified date: <07/03/2023>
-- Description:	CONSULTA DE TITULO DEL MODULO
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
  FROM dbo.Titulos AS T (NOLOCK)
  LEFT JOIN dbo.TituloModulo AS TM (NOLOCK)
  ON T.IdTitulo = TM.IdTitulo 
  WHERE TM.IdModulo = @IdModulo 
  AND T.IdIdioma = @IdIdioma

END
