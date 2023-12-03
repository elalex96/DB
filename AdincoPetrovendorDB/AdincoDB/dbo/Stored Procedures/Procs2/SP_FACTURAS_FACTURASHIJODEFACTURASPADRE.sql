IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FACTURAS_FACTURASHIJODEFACTURASPADRE'
)
    DROP PROCEDURE SP_FACTURAS_FACTURASHIJODEFACTURASPADRE;
GO
CREATE PROCEDURE [dbo].[SP_FACTURAS_FACTURASHIJODEFACTURASPADRE] 
	@IdFacturaPadre INT,
	@IdSubcontratista INT,
	@FacturaPedimento VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

	IF(@FacturaPedimento = 'Factura')
	BEGIN
		SELECT IdFacturahijo,
			   IdFacturaPadre
		FROM FI_RelacionRefacturas (NOLOCK)
		INNER JOIN FI_Factura (NOLOCK)
		ON FI_RelacionRefacturas.idFacturaPadre = @idFacturaPadre
		AND FI_RelacionRefacturas.idFacturaPadre = FI_Factura.IdFactura
		INNER JOIN FI_Factura Fhijo (NOLOCK)
		ON FI_RelacionRefacturas.idFacturaHijo = Fhijo.IdFactura
		WHERE Fhijo.IdSubcontratista = @IdSubcontratista and idFacturaPadre = @idFacturaPadre
	END

	IF(@FacturaPedimento = 'Pedimento')
	BEGIN
		SELECT IdPedimentoHijo,
			   IdFacturaPadre
		FROM FI_RelacionPedimento (NOLOCK)
		INNER JOIN FI_Factura (NOLOCK)
		ON FI_RelacionPedimento.idFacturaPadre = @idFacturaPadre
		AND FI_RelacionPedimento.idFacturaPadre = FI_Factura.IdFactura
		INNER JOIN FI_PedimentoComprobante (NOLOCK)
		ON FI_RelacionPedimento.IdPedimentoHijo = FI_PedimentoComprobante.IdPedimentoComprobante
		AND FI_PedimentoComprobante.IdSubcontratistaExportador = @IdSubcontratista
		WHERE FI_PedimentoComprobante.IdSubcontratistaExportador = @IdSubcontratista AND FI_RelacionPedimento.IdFacturaPadre = @idFacturaPadre
	END
END;