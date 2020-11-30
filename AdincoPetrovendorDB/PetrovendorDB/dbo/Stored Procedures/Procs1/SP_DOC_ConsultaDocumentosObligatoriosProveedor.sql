-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <23-07-2020>
-- Description:	<Cosnulta de los documentos obligatorios de la operadora>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DOC_ConsultaDocumentosObligatoriosProveedor] --670,1,'Anexo E'
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
						FROM dbo.S_DocumentoPlantillaOperadora AS DPO
							LEFT JOIN dbo.S_Proveedor AS OP 
								ON OP.IdProveedor = DPO.IdProveedor
							LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP 
								ON ADP.IdTipoDocumentoOperadora = DPO.IdDocumentoPlantilla
									AND ADP.IdProveedor = 670
							LEFT JOIN dbo.S_Documento_S3 AS DPR 
								ON DPR.IdDocumento = ADP.IdDocumentoS3Proveedor
							LEFT JOIN dbo.S_Documento_S3 AS DPOD 
								ON DPOD.IdDocumento = DPO.IdDocumentoS3
									AND DPOD.Activo = 1
							LEFT JOIN dbo.TA_Estatus AS EST
								ON EST.IdEstatus = ADP.IdEstatus
							LEFT JOIN dbo.TA_Operacion AS OPE
								ON OPE.IdDocumento = ADP.IdAceptacionDocumento
								AND OPE.IdTipoOperacion = 18
								AND OPE.IdProveedor = DPO.IdProveedor
						WHERE DPO.Activo= 1
						AND DPO.NombreDocumentoObligatorio LIKE '%' + @Buscar + '%');

	SELECT *,
		  @AllRecords AS Records,
		  @RecordsByPage AS RecordsByPage
	FROM
	(
		SELECT
			ROW_NUMBER() OVER(PARTITION BY DPO.IdDocumentoPlantilla ORDER BY DPO.IdDocumentoPlantilla DESC) AS R,
			DPO.IdDocumentoPlantilla,
			DPO.NombreDocumentoObligatorio,
			DPO.DescripcionDocumento,
			OP.RazonSocial,
			DPR.IdDocumento AS IdDocumentoProveedor,
			DPOD.IdDocumento AS DocumentoOperadora,
			ISNULL(EST.Nombre,'Sin Documento') AS EstatusAprobacion,
			ISNULL(ADP.IdEstatus,1) AS IdEstatus,
			DPO.Obligatorio,
			ISNULL(ADP.IdAceptacionDocumento,0) AS IdAceptacionDocumento,
			ISNULL(OPE.IdOperacion,0) AS IdOperacion,
			(ROW_NUMBER() OVER(ORDER BY DPO.CreadoEl DESC) - 1) / @RecordsByPage AS _Page
		FROM dbo.S_DocumentoPlantillaOperadora AS DPO
			LEFT JOIN dbo.S_Proveedor AS OP 
				ON OP.IdProveedor = DPO.IdProveedor
			LEFT JOIN dbo.MM_AceptacionDocumento_Proveedor AS ADP 
				ON ADP.IdTipoDocumentoOperadora = DPO.IdDocumentoPlantilla
					AND ADP.IdProveedor = @IdProveedor
			LEFT JOIN dbo.S_Documento_S3 AS DPR 
				ON DPR.IdDocumento = ADP.IdDocumentoS3Proveedor
			LEFT JOIN dbo.S_Documento_S3 AS DPOD 
				ON DPOD.IdDocumento = DPO.IdDocumentoS3
					AND DPOD.Activo = 1
			LEFT JOIN dbo.TA_Estatus AS EST
				ON EST.IdEstatus = ADP.IdEstatus
			LEFT JOIN dbo.TA_Operacion AS OPE
				ON OPE.IdDocumento = ADP.IdAceptacionDocumento
				AND OPE.IdTipoOperacion = 18
				AND OPE.IdProveedor = DPO.IdProveedor
		WHERE DPO.Activo= 1
		AND DPO.NombreDocumentoObligatorio LIKE '%' + @Buscar + '%'
		GROUP BY DPO.IdDocumentoPlantilla,
				 DPO.NombreDocumentoObligatorio,
				 DPO.DescripcionDocumento,
				 OP.RazonSocial,
				 DPR.IdDocumento,
				 DPOD.IdDocumento,
				 EST.Nombre,
				 DPO.Obligatorio,
				 ADP.IdEstatus,
				 ADP.IdAceptacionDocumento,
				 OPE.IdOperacion,
				 DPO.CreadoEl
		) AS R
		WHERE R.R = 1 AND
			R._Page = (@Page - 1)
		ORDER BY R.IdDocumentoPlantilla DESC;

END
