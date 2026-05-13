-- =============================================
-- Author:		Manuel CD
-- Create date: 26-02-2018
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarFacturaNoLigada] 
-- Add the parameters for the stored procedure here
@IdFactura  INT, 
@IdUsuario  INT, 
@IdContrato INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         DELETE dbo.FI_CFDIConceptoImpuesto
         WHERE IdFacturaConcepto IN
         (
             SELECT IdFacturaConcepto
             FROM FI_CFDIConcepto
             WHERE IdFactura = @IdFactura
         );

         /**/

         DELETE dbo.FI_CFDIConcepto
         WHERE IdFactura = @IdFactura;

         /**/

         DELETE dbo.FI_CFDIImpuesto
         WHERE IdFactura = @IdFactura;

         /**/

         DELETE dbo.FI_Documento
         WHERE IdFactura = @IdFactura;

         /**/

         DELETE dbo.FI_ArchivoXml
         WHERE IdFactura = @IdFactura;

         /**/

         DELETE dbo.FI_CPDocRelacionado
         WHERE IdComplementoDePago IN
         (
             SELECT IdComplementoDePago
             FROM dbo.FI_ComplementoDePago
             WHERE IdFactura = @IdFactura
         );

         /**/

         DELETE dbo.FI_ComplementoDePago
         WHERE IdFactura = @IdFactura;

         /**/

         DELETE dbo.FI_CFDIRelacionados
         WHERE CFDIId = @IdFactura;

         /**/

         DELETE dbo.FI_PPD_MesPresentacion
         WHERE idFactura = @IdFactura;

         /**/

         DELETE dbo.FI_Factura
         WHERE IdFactura = @IdFactura;

         --
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;