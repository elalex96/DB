-- =============================================
-- Author:		Manuel Cruz
-- Create date: 28-07-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_Factura]
-- Add the parameters for the stored procedure here
@IdFactura INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here

         SELECT F.IdFactura, 
                F.Serie, 
                F.Folio, 
                F.Fecha, 
                F.FormaPago, 
                F.SubTotal, 
                F.TipoCambio, 
                F.Moneda, 
                F.MontoConIva, 
                F.TipoComprobante, 
                F.MetodoPago, 
                F.LugarExpedicion, 
                F.NumCtaPago, 
                F.Emisor, 
                S.RazonSocial, 
                F.Receptor, 
				SR.RazonSocial AS RazonSocialReceptora,
                F.UUID, 
                F.FechaTimbrado, 
                F.SelloCFD, 
                F.NoCertificadoSAT, 
                F.SelloSAT, 
                F.FechaRecepcion
         FROM dbo.FI_Factura F
              LEFT JOIN dbo.PV_Subcontratista S ON F.IdSubcontratista = S.IdSubcontratista
			  LEFT JOIN dbo.PV_Subcontratista SR ON F.Receptor = SR.RFC
         WHERE F.IdFactura = @IdFactura;
     END;