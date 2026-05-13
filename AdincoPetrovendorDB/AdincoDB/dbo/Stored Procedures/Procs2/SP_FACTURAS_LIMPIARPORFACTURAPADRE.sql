IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FACTURAS_LIMPIARPORFACTURAPADRE'
)
    DROP PROCEDURE SP_FACTURAS_LIMPIARPORFACTURAPADRE;
GO
CREATE PROCEDURE [dbo].[SP_FACTURAS_LIMPIARPORFACTURAPADRE] 
	@idFacturaPadre INT,
	@IdSubcontratista INT,
	@FacturaPedimento VARCHAR(100)
AS
BEGIN
	IF(@FacturaPedimento = 'Factura')
	BEGIN
		DELETE FI_RelacionRefacturas
		FROM FI_RelacionRefacturas
		INNER JOIN FI_Factura
		ON FI_RelacionRefacturas.idFacturaPadre = @idFacturaPadre
		AND FI_RelacionRefacturas.idFacturaPadre = FI_Factura.IdFactura
		INNER JOIN FI_Factura Fhijo
		ON FI_RelacionRefacturas.idFacturaHijo = Fhijo.IdFactura
		WHERE Fhijo.IdSubcontratista = @IdSubcontratista and idFacturaPadre = @idFacturaPadre
	END

	IF(@FacturaPedimento = 'Pedimento')
	BEGIN
		DELETE FI_RelacionPedimento
		FROM FI_RelacionPedimento
		INNER JOIN FI_Factura
		ON FI_RelacionPedimento.idFacturaPadre = @idFacturaPadre
		AND FI_RelacionPedimento.idFacturaPadre = FI_Factura.IdFactura
		INNER JOIN FI_PedimentoComprobante
		ON FI_RelacionPedimento.IdPedimentoHijo = FI_PedimentoComprobante.IdPedimentoComprobante
		AND FI_PedimentoComprobante.IdSubcontratistaExportador = @IdSubcontratista
		WHERE FI_PedimentoComprobante.IdSubcontratistaExportador = @IdSubcontratista AND FI_RelacionPedimento.IdFacturaPadre = @idFacturaPadre
	END
END;

