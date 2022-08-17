-- =============================================
-- Author:		Marcos Garcia
-- Create date: 26-05-2020
-- Description:	Complementos de Pago
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Agregado de (NOLOCK), ajustado de orden en los join, renombrado de las tablas
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_VariosComplementosPPDPorUUID]
    @IdContrato INT,
    @IdUsuario INT,
    @UUID VARCHAR(100)
AS
BEGIN
    SELECT FI_ComplementoDePago.IdFactura,
           FI_Factura.UUID
    FROM FI_ComplementoDePago (NOLOCK)
        JOIN FI_CPDocRelacionado (NOLOCK)
            ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
        JOIN FI_Factura (NOLOCK)
            ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
    WHERE FI_CPDocRelacionado.IdDocumento = @UUID
    GROUP BY FI_ComplementoDePago.IdFactura,
             FI_Factura.UUID
    ORDER BY FI_ComplementoDePago.IdFactura DESC;
END;