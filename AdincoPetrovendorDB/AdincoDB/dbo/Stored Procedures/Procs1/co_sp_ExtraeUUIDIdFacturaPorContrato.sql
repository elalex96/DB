CREATE PROCEDURE [dbo].[co_sp_ExtraeUUIDIdFacturaPorContrato]--1,10038
    @IdUsuario INT,
    @IdContrato INT
AS
BEGIN
		SELECT 
			F.IdFactura, F.UUID, F.Moneda,ISNULL(SubTotal,0) AS SubTotal,ISNULL(MontoConIva,0) as ImporteTotal
		FROM
			FI_Factura	F
		WHERE 
			F.IdContrato =	@IdContrato
			ORDER BY IDFACTURA DESC
END;
---------------------------------------------------------------------------------