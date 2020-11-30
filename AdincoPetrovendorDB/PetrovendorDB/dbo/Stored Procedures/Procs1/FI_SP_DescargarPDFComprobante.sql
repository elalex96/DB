-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <15-07-2019>
-- Description:	<Se obtiene el comprobante de pago>
-- Author:		Daniel Ac
-- Create date:13/12/2019
-- Description:	Referencias al s3
-- =============================================

CREATE PROCEDURE FI_SP_DescargarPDFComprobante @IdTransferencia INT, 
                                              @IdContrato      INT      = NULL, 
                                              @IdUsuario       INT      = NULL, 
                                              @FechaRegistro   DATETIME = NULL
AS
    BEGIN
        SELECT ISNULL(T.PDF, '') AS PDF, 
               ISNULL(AWSPDFId, 0) AS AWSPDFId, 
               aws.Bucket, 
               aws.Folder, 
               UPPER(aws.UUIDAmazon) AS UUIDAmazon, 
               aws.NombreArchivo, 
               aws.Meta
        FROM Adinco.dbo.FI_Transfer AS T
             LEFT JOIN Adinco.dbo.AWS_Documentos aws ON aws.AWSDocumentoId = T.AWSPDFId
        WHERE T.IdTransferencia = @IdTransferencia;
    END;
