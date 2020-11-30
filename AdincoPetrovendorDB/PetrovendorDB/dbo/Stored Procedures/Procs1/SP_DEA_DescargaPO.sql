-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <26/08/2019>
-- Description:	<Descarga PO>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_DescargaPO]
	-- Add the parameters for the stored procedure here
	@IdAdjuntoPO NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT 
		D.NombreDocumento,
		D.Extension,
		D.Mime,
		D.Carpeta,
		D.Identificador,
		D.IdDocumento
	FROM dbo.DEA_Documento_S3 D
	LEFT JOIN dbo.DEA_AdjuntoPO AS PO ON PO.IdDocumento = D.IdDocumento
	WHERE PO.IdAdjuntoPO = @IdAdjuntoPO AND D.IdTipoDocumento = 2

END

