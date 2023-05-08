-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <26/08/2019>
-- Description:	<Descarga PR>
-- Author:		<Manuel Cruz>
-- Create date: <23/09/20219>
-- Description:	<Se agrega columna Bucket para que devuelva el select descarga estandar avance 5>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_DEA_DescargaPR] 
	-- Add the parameters for the stored procedure here
	@IdAjuntoPr INT 
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
		D.Bucket
	FROM dbo.DEA_Documento_S3 D
	INNER JOIN dbo.DEA_AdjuntoPR AS PR ON PR.IdAjuntoPr = D.IdDocumentoTabla
	WHERE PR.IdAjuntoPr = @IdAjuntoPr
	AND D.IdTipoDocumento = 1

END