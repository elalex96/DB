-- =============================================
-- Author:		Marcos Garcia
-- Create date: 26-05-2020
-- Description:	Facturas PPD con Varios Complementos de Pago
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Agregado de (NOLOCK), ajustado de orden en los join, ajuste en el nombrado de las tablas
-- ============================================= 
--[SP_FI_VariosComplementosPPD] 3,0
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_FI_VariosComplementosPPD]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    IF OBJECT_ID('tempdb..#TemporalCDP', 'U') IS NOT NULL
        DROP TABLE #TemporalCDP;
    -- ============================================= 
    CREATE TABLE #TemporalCDP
    (
        IdFacturaComplementoDePago INT,
        UUIDComplementoDePago NVARCHAR(MAX),
        UUIDDocRelacionado NVARCHAR(MAX),
        IdFacturaDoCRelacionado INT
    );
    --===================================== 
    INSERT INTO #TemporalCDP
    (
        IdFacturaComplementoDePago,
        UUIDComplementoDePago,
        UUIDDocRelacionado,
        IdFacturaDoCRelacionado
    )
    SELECT FI_ComplementoDePago.IdFactura,
           FI_Factura.UUID,
           FI_CPDocRelacionado.IdDocumento,
           FI_Factura_CPDocRelacionado.IdFactura
    FROM FI_ComplementoDePago (NOLOCK)
        JOIN FI_CPDocRelacionado (NOLOCK)
            ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
        JOIN FI_Factura (NOLOCK)
            ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
               AND FI_Factura.IdContrato = @IdContrato
        LEFT JOIN FI_Factura (NOLOCK) FI_Factura_CPDocRelacionado
            ON FI_CPDocRelacionado.IdDocumento = FI_Factura_CPDocRelacionado.UUID
    GROUP BY FI_ComplementoDePago.IdFactura,
             FI_Factura.UUID,
             FI_CPDocRelacionado.IdDocumento,
             FI_Factura_CPDocRelacionado.IdFactura
    ORDER BY FI_ComplementoDePago.IdFactura DESC;
    -- =============================================        
    SELECT #TemporalCDP.UUIDDocRelacionado AS UUID,
           CASE
               WHEN #TemporalCDP.IdFacturaDoCRelacionado IS NULL THEN
                   'UUID de Factura: [' + CONVERT(NVARCHAR(MAX), #TemporalCDP.UUIDDocRelacionado) + ']'
               ELSE
                   'Id Factura: ' + CONVERT(NVARCHAR(MAX), #TemporalCDP.IdFacturaDoCRelacionado) + ', UUID: ['
                   + CONVERT(NVARCHAR(MAX), UPPER(#TemporalCDP.UUIDDocRelacionado)) + ']'
           END AS PPD
    FROM #TemporalCDP
    GROUP BY #TemporalCDP.UUIDDocRelacionado,
             #TemporalCDP.IdFacturaDoCRelacionado
    HAVING COUNT(#TemporalCDP.UUIDDocRelacionado) >= 2
    ORDER BY #TemporalCDP.IdFacturaDoCRelacionado DESC;
END;