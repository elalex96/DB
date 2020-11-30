-- =============================================
-- Author:		Alexander Gomez
-- Create date: 29/10/2018
-- Description:	Consulta los detalles de una PO
-- =============================================
CREATE PROCEDURE [dbo].[SP_MPY_DetallesPO] --'4500095797'
	-- Add the parameters for the stored procedure here
@PONumber     NVARCHAR(20),
@RFCProveedor NVARCHAR(20)
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT PO.SAPPONumber,
                    PO.ItemNumber,
                    CASE
                        WHEN PO.POItemCategory = 9
                        THEN 0
                        ELSE PO.Total
                    END AS Total,
                    PO.Quantity,
                    PO.DeliveryDate,
                    PO.MaterialGroup,
                    PO.Currency,
                    CASE
                        WHEN PO.POItemCategory = 9
                        THEN 0
                        ELSE PO.UnitPrice
                    END AS UnitPrice,
                    CASE
                        WHEN SM.Unit IS NULL
                        THEN PO.ParentLineUOM
                        WHEN SM.Unit = ''
                        THEN PO.ParentLineUOM
                        ELSE SM.Unit
                    END AS Unit,
                    PO.SAPMaterialNumber,
                    CASE
                        WHEN SM.MaterialDescription IS NULL
                        THEN PO.ShortText
                        WHEN SM.MaterialDescription = ''
                        THEN PO.ShortText
                        ELSE SM.MaterialDescription
                    END AS MaterialDescription,
                    SM.MaterialDescription,
                    SM.MaterialLongText,
                    PO.Deliveryaddress
             FROM Adinco.dbo.CO_SAPPO AS PO
                  LEFT JOIN Adinco.dbo.CO_SAPMaterial AS SM ON SM.SAPMaterialNumber = PO.SAPMaterialNumber
                  LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP = PO.SAPVendorNumber
             WHERE PO.SAPPONumber = @PONumber
                   AND sv.TaxID = @RFCProveedor
             ORDER BY PO.ItemNumber ASC;
         END;