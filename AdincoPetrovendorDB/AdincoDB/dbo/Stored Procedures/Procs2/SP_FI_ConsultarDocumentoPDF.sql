-- =============================================
-- Author:		Daniel  AC
-- Create date: 26-12-2016
-- Description:	Consulta las facturas del contrato para anexar PDF Factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultarDocumentoPDF] 
-- Add the parameters for the stored procedure here
@IdFactura INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
 
			select A.Documento,A.NombreExtensionArchivo, B.IdDocFacturacionSIPAC
			from
			[dbo].[FI_Documento] A
			Inner join  [dbo].[FI_Factura] B on A.IdFactura = B.IdFactura
			 where  
			A.IdFactura = @IdFactura
			and A.IdTipoDocumento = 1

     END