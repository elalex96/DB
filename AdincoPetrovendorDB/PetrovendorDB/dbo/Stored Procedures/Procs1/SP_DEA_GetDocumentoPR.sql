-- =============================================
-- Author:        Daniel AC
-- Create date: <18-09-18>
-- Description:    <obtiene la informacion del documento del factura ya sea xml o pdf>
-- =============================================
CREATE  PROCEDURE [dbo].[SP_DEA_GetDocumentoPR]

 

@IdProveedor INT,
@IdUsuario INT,
@IdDocumento INT,
@IdSolicitudPedido INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

 

    SELECT D.NombreDocumento,D.Extension,D.Mime,D.Carpeta,D.Identificador 
    FROM dbo.DEA_Documento_S3 D
     LEFT JOIN dbo.DEA_AdjuntoPR PR
        ON PR.IdAjuntoPr = PR.IdAjuntoPr
    WHERE PR.IdSolicitudPedido=@IdSolicitudPedido
    AND D.IdDocumento=@IdDocumento
    AND D.Activo=1

 

END