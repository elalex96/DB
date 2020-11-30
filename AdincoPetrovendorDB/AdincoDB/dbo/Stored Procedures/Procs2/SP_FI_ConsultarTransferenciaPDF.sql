-- =============================================
-- Author:		Daniel  AC
-- Create date: 26-12-2016
-- Description:	Consulta las facturas del contrato para anexar PDF Factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultarTransferenciaPDF] 
-- [SP_FI_ConsultarTransferenciaPDF] 4311
-- Add the parameters for the stored procedure here
@IdTransferencia INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

/*SELECT PDf, 
                isnull(NombreExtencionArchivo, IdComprobantePago+'.pdf') AS NombreExtencionArchivo
         FROM [dbo].[FI_transfer] A
         WHERE A.IdTransferencia = @IdTransferencia;*/

         SELECT PDf = CASE
                          WHEN A.AWSPDFId IS NULL
                          THEN A.PDF
                          ELSE ''
                      END, 
                ISNULL(CASE NombreExtencionArchivo
                           WHEN ''
                           THEN IdComprobantePago
                       END, IdComprobantePago+'.pdf') AS NombreExtencionArchivo, 
                AWSPDFId = isnull(AWSPDFId, 0)
         FROM [dbo].[FI_transfer] A
         WHERE A.IdTransferencia = @IdTransferencia;
     END;