-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <04/09/2020>
-- Description:	<Consulta a detalle de un Pedimento/Comprobante de Procura>
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ConsultaDocPedimentoCompr_CD_Procura] 

	-- Add the parameters for the stored procedure here
	@IdPedimentoComprobante INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT
		CASE
			WHEN DS3.IdDocumento IS NOT NULL THEN 1
			ELSE 0
		END AS DocumentoS3,
		DOP.DocumentoByte,
		DOP.NombreExtensionArchivo,
		DS3.NombreDocumento,
		DS3.Extension,
		DS3.Mime,
		DS3.Carpeta,
		DS3.Identificador
	FROM dbo.FI_PedimentoComprobante AS PC
		JOIN dbo.FI_PedimentoComprobanteDetalle AS PCD
			ON PCD.IdPedimentoComprobante = PC.IdPedimentoComprobante
		LEFT JOIN dbo.FI_Documento AS DOP
			ON DOP.IdPedimentoComprobante = PC.IdPedimentoComprobante
		LEFT JOIN dbo.S_Documento_S3 AS DS3
			ON DS3.IdDocumentoTabla = PC.IdPedimentoComprobante
			AND DS3.IdTipoDocumento = 53
			AND DS3.Activo = 1
			AND DS3.IdTipoValidacionDocumento = 1003
	WHERE PC.IdPedimentoComprobante = @IdPedimentoComprobante

END
