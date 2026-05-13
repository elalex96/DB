-- =============================================
-- Author:		Manuel CD
-- Create date: 13-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaFacturasOperadoraRfc]
-- Add the parameters for the stored procedure here
@IdContrato INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         /**/

         DECLARE @RFC NVARCHAR(20);
         SELECT @RFC = RFC
         FROM CO_Contratista CC
              JOIN CO_Contrato C ON CC.IdContratista = C.IdContratista
         WHERE C.IdContrato = @IdContrato;
         --SELECT @RFC
         /**/

         -- Insert statements for procedure here

         SELECT F.IdFactura, 
                CONCAT(F.Serie, ' ', F.Folio) AS Folio, 
                Fecha, 
                MetodoPago, 
                format(SubTotal, '#,###.00', 'ES-mx') AS SubTotal, 
                MontoConIva, 
                Moneda, 
                CONCAT(LugarExpedicion, ' ', FC.Descripcion) AS LugarExpedicion, 
                Emisor, 
                SE.RazonSocial, 
                Receptor, 
                SR.RazonSocial, 
                FechaTimbrado
         FROM FI_Factura F
              LEFT JOIN PV_Subcontratista SE ON F.Emisor = SE.RFC
              LEFT JOIN PV_Subcontratista SR ON F.Receptor = SR.RFC
              LEFT JOIN dbo.FI_CFDIConcepto FC ON Fc.IdFactura = F.IdFactura
         WHERE F.Emisor = @RFC
               AND F.idcontrato = @IdContrato
         ORDER BY F.Fecha DESC;
     END;
         --SP_FI_ConsultaFacturasOperadoraRfc 10003