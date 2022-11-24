-- =============================================
-- Author:		Daniel AC
-- Create date: <18-09-18>
-- Description:	<obtiene la informacion del documento del factura ya sea xml o pdf>
-- Author:		<Manuel Cruz>
-- Create date: <23/09/20219>
-- Description:	<Se agrega columna Bucket para que devuelva el select descarga estandar avance 5>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_DEA_GetDocumentoPO_V2]
@IdProveedor INT,
@IdUsuario INT,
@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 
	D.NombreDocumento,
	D.Extension,
	D.Mime,
	D.Carpeta,
	D.Identificador,
	RPO.IdPedido,
	ISNULL(RPO.PO,'') AS PO,
	D.Bucket
	FROM dbo.DEA_Documento_S3 D
	INNER JOIN dbo.DEA_AdjuntoPO APO ON APO.IdDocumento = D.IdDocumento
 	LEFT JOIN dbo.DEA_Relacion_PR_PO RPO ON RPO.PO = APO.ID_PO AND RPO.IdAdjuntoPO = APO.IdAdjuntoPO
	WHERE RPO.IdPedido = @IdPedido
	AND D.Activo=1

END