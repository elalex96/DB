-- =============================================
-- Author:		JG
-- Create date: 11-10-2017
-- Description:	Consulta los comprobantes de transferencia de una factura 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultarDocumentoPDFTransferencia] 
-- Add the parameters for the stored procedure here
@IdTransferencia INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
 
			select A.PDF ,A.NombreExtencionArchivo
			from
			[dbo].[FI_Transfer] A
			 where  
			A.IdTransferencia = @IdTransferencia

     END