-- =============================================
-- Author:		Alexander Gomez
-- Create date: 29-01-2019
-- Description:	Consultar Pedido Detalle  Encabezado
-- =============================================

CREATE  PROCEDURE [dbo].[SP_MPY_TA_ConsultarEncabezadoPrePedidoGral]
	-- Add the parameters for the stored procedure here
	---execute  SP_TA_ConsultarEncabezadoPrePedidoGral 420, 1343
	@IdProveedor NVARCHAR(100), 
	@IdPedido NVARCHAR(100)
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
 
    -- Insert statements for procedure here
	

	SELECT
		PO.SAPPONumber,
		PO.Deliveryaddress,
		PO.CreadoEl,
		V.VendorName
	FROM Adinco.dbo.CO_SAPPO AS PO
	LEFT JOIN Adinco.dbo.CO_SAPVendor AS V ON V.VendorIDSAP = PO.SAPVendorNumber
	WHERE PO.SAPPONumber = @IdPedido
		AND PO.SAPVendorNumber = @IdProveedor
	GROUP BY PO.SAPPONumber,
             PO.Deliveryaddress,
             PO.CreadoEl,
             V.VendorName

END
