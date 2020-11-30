-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <29/06/2020>
-- Description:	<Consultar los ducumentos agregados por el operadora>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DG_DocumentosOperadoraPROCURA]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT,
	@Page INT,
	@Buscar NVARCHAR(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @AllRecords INT;
	DECLARE @RecordsByPage INT = 10;

	SET @AllRecords = (SELECT
							COUNT(1)
						FROM dbo.S_DocumentoPlantillaOperadora AS DOP
							LEFT JOIN dbo.S_Documento_S3 AS DS3 ON DS3.IdDocumento = DOP.IdDocumentoS3
							LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = DOP.CreadoPor
						WHERE DOP.Activo = 1 
							AND DOP.IdProveedor = @IdProveedor 
							AND DS3.Activo = 1
							AND DOP.NombreDocumentoObligatorio LIKE '%' + @Buscar + '%');

    SELECT *,
		  @AllRecords AS Records,
		  @RecordsByPage AS RecordsByPage
	FROM
	(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY DOP.IdDocumentoPlantilla ORDER BY DOP.IdDocumentoPlantilla DESC) AS R,
			DOP.IdDocumentoPlantilla,
			DOP.NombreDocumentoObligatorio,
			DOP.DescripcionDocumento,
			DOP.Obligatorio,
			US.Nombre,
			DOP.CreadoEl,
			DS3.IdDocumento,
			(ROW_NUMBER() OVER(ORDER BY DOP.CreadoEl DESC) - 1) / @RecordsByPage AS _Page
		FROM dbo.S_DocumentoPlantillaOperadora AS DOP
			LEFT JOIN dbo.S_Documento_S3 AS DS3 ON DS3.IdDocumento = DOP.IdDocumentoS3
			LEFT JOIN dbo.S_Usuario AS US ON US.IdUsuario = DOP.CreadoPor
		WHERE DOP.Activo = 1 
			AND DOP.IdProveedor = @IdProveedor 
			AND DS3.Activo = 1
			AND DOP.NombreDocumentoObligatorio LIKE '%' + @Buscar + '%'
	) AS R
	WHERE R.R = 1 AND
		R._Page = (@Page - 1)
	ORDER BY R.CreadoEl DESC;

END
