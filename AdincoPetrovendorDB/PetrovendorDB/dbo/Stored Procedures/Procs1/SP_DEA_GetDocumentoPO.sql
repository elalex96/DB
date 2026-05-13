-- =============================================
-- Author:      Daniel AC
-- Create date: <18-09-18>
-- Description: <obtiene la informacion del documento del factura ya sea xml o pdf>
-- Author:		<Manuel Cruz>
-- Create date: <23/09/20219>
-- Description:	<Se agrega columna Bucket para que devuelva el select descarga estandar avance 5>
-- =============================================
CREATE PROCEDURE [dbo].[SP_DEA_GetDocumentoPO]
@IdProveedor INT,
@IdUsuario INT,
@IdDocumento INT,
@IdPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    SELECT D.NombreDocumento,D.Extension,D.Mime,D.Carpeta,D.Identificador,RPO.IdPedido,D.IdDocumento,D.Bucket
    FROM dbo.DEA_Documento_S3 D
    INNER JOIN dbo.DEA_AdjuntoPO APO ON APO.IdDocumento=D.IdDocumento
    LEFT JOIN dbo.DEA_Relacion_PR_PO RPO ON RPO.IdAdjuntoPO= APO.IdAdjuntoPO
    WHERE RPO.IdPedido = @IdPedido
    AND D.IdDocumento = @IdDocumento
     
END