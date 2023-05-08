-- =============================================
-- Author:		Daniel  AC
-- Create date: 26-12-2016
-- Description:	Consulta las facturas del contrato para anexar PDF Factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultarCargaDocumentoPDF] 
-- Add the parameters for the stored procedure here
@IdFactura INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
		 DECLARE @IsValidoArchivo NVARCHAR(50)
         -- Insert statements for procedure here
 
	 SET @IsValidoArchivo =(  SELECT
                CASE ISNULL(D.IdFactura, 0)
                    WHEN 0
                    THEN 'No'
                    ELSE 'Si'
                END AS Cargado
              
         FROM FI_Factura AS F
              LEFT OUTER JOIN FI_Documento AS D ON F.IdFactura = D.IdFactura
         WHERE(F.IdFactura = @IdFactura AND D.IdTipoDocumento=1))

		 SELECT ISNULL(@IsValidoArchivo,'No') AS Cargo



     END