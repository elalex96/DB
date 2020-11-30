
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 29-01-2018
-- Description:	Consultar Pedido Detalle 
-- =============================================


CREATE PROCEDURE [dbo].[SP_MPY_MM_ConsultarPedidosDetalleCompras_MV1_5]
    -- Add the parameters for the stored procedure here
    @IdProveedorSubC NVARCHAR(100),
    @IdPedido NVARCHAR(100),

    /*--------------------
    parametros contrato 
   --------------------*/
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
/*--------------------
   --------------------*/

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here

    SELECT DISTINCT
		PO.ItemNumber,
		PO.SAPMaterialNumber,
		M.MaterialDescription,
		PO.Quantity,
		PO.UnitPrice,
		PO.Currency,
		PO.Deliveryaddress
	FROM Adinco.dbo.CO_SAPPO AS PO
		LEFT JOIN Adinco.dbo.CO_SAPMaterial AS M ON M.SAPMaterialNumber = PO.SAPMaterialNumber
	WHERE PO.SAPPONumber = @IdPedido
	AND PO.SAPVendorNumber = @IdProveedorSubC


END;



