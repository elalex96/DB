-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-06-2020
-- Description:	Consulta PPD's y Complementos con CPDR.ImpPagado < CPDR.ImpSaldoAnt
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaPPDComplementos] 
-- ============================================= 
--[SP_FI_ConsultaPPDComplementos] 3,0
-- ============================================= 
@IdContrato INT, 
@IdUsuario  INT
AS
    BEGIN
        SET LANGUAGE Spanish;
        --

        IF OBJECT_ID('tempdb..#TemporalIdCP', 'U') IS NOT NULL
            DROP TABLE #TemporalIdCP;
        --
        CREATE TABLE #TemporalIdCP
        (IdComplementoDePago INT, 
         UUID                NVARCHAR(MAX)
        );
        --
        INSERT INTO #TemporalIdCP
        (IdComplementoDePago, 
         UUID
        )
               SELECT MAX(CPDR.IdComplementoDePago) AS IdComplementoDePago, 
                      UPPER(F.UUID) AS UUID
               FROM dbo.FI_Factura F
                    JOIN dbo.FI_CPDocRelacionado CPDR ON F.UUID = CPDR.IdDocumento
               WHERE F.IdContrato = @IdContrato
                     AND CPDR.ImpPagado < CPDR.ImpSaldoAnt
                     AND F.IdFactura NOT IN
               (
                   SELECT IdFactura
                   FROM dbo.FI_ControlPPDComplementos
               )
               GROUP BY UPPER(F.TipoComprobante), 
                        UPPER(F.UUID), 
                        F.IdFactura;
        --
        SELECT F.IdFactura, 
               UPPER(F.TipoComprobante) AS TipoComprobante, 
               UPPER(F.UUID) AS UUID,
               CASE
                   WHEN(MAX(CR.MesPresentacion) IS NULL)
                   THEN 'Sin Especificar'
                   ELSE DATENAME(MONTH, MAX(CR.MesPresentacion)) + ' de ' + CONVERT(NVARCHAR(MAX), DATENAME(YEAR, MAX(CR.MesPresentacion)))
               END AS MesPresentacion
        FROM dbo.FI_Factura F
             JOIN dbo.FI_ComplementoDePago CP ON F.IdFactura = CP.IdFactura
             LEFT JOIN #TemporalIdCP T ON CP.IdComplementoDePago = T.IdComplementoDePago
             LEFT JOIN dbo.FI_CPDocRelacionado DR ON CP.IdComplementoDePago = DR.IdComplementoDePago
             LEFT JOIN dbo.FI_Factura FI ON DR.IdDocumento = FI.UUID
             LEFT JOIN dbo.CO_Registro CR ON FI.IdFactura = CR.IdFactura
        WHERE F.IdFactura NOT IN
        (
            SELECT IdFactura
            FROM dbo.FI_ControlPPDComplementos
        )
        GROUP BY UPPER(F.TipoComprobante), 
                 UPPER(F.UUID), 
                 F.IdFactura
        UNION
        SELECT F.IdFactura, 
               UPPER(F.TipoComprobante) AS TipoComprobante, 
               UPPER(F.UUID) AS UUID,
               CASE
                   WHEN(MAX(CR.MesPresentacion) IS NULL)
                   THEN 'Sin Especificar'
                   ELSE DATENAME(MONTH, MAX(CR.MesPresentacion)) + ' de ' + CONVERT(NVARCHAR(MAX), DATENAME(YEAR, MAX(CR.MesPresentacion)))
               END AS MesPresentacion
        FROM dbo.FI_Factura F
             JOIN dbo.FI_CPDocRelacionado CPDR ON F.UUID = CPDR.IdDocumento
             JOIN dbo.FI_ComplementoDePago CP ON CPDR.IdComplementoDePago = CP.IdComplementoDePago
             LEFT JOIN dbo.CO_Registro CR ON F.IdFactura = CR.IdFactura
        WHERE F.IdContrato = @IdContrato
              --AND CPDR.ImpPagado < CP.Monto
              --AND CPDR.ImpPagado < CPDR.ImpSaldoAnt
              AND F.IdFactura NOT IN
        (
            SELECT IdFactura
            FROM dbo.FI_ControlPPDComplementos
        )
        GROUP BY UPPER(F.TipoComprobante), 
                 UPPER(F.UUID), 
                 F.IdFactura
        ORDER BY F.IdFactura DESC;
    END;