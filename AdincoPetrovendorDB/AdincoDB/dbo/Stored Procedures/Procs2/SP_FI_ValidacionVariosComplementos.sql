-- =============================================
-- Author:		Marcos Garcia
-- Create date: 26-05-2020
-- Description:	Validaciones de PPD con más de un Complemento de Pago 
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Aagregado de (NOLOCK), se quitan VARCHAR (MAX), ajuste de sub querys, se ajusta nombrado de tablas
-- =============================================
--[SP_FI_ValidacionVariosComplementos] 3,10113,1
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ValidacionVariosComplementos]
    @IdContrato INT,
    @IdUsuario INT,
    @IntTop INT
AS
BEGIN
    DECLARE @Consulta VARCHAR(500);
    --==============================
    SET @Consulta
        = CAST('SELECT TOP ' + CAST(@IntTop AS VARCHAR(50))
               + '
								    FI_Factura.IdFactura, 
									FI_Factura.TipoComprobante, 
									FI_ComplementoDePago.IdComplementoDePago
							FROM FI_Factura (NOLOCK)
								  JOIN FI_ComplementoDePago (NOLOCK) ON FI_Factura.IdFactura = FI_ComplementoDePago.IdFactura
							WHERE FI_Factura.IdContrato = ' + CAST(@IdContrato AS VARCHAR(50))
               + ' 
								  AND FI_Factura.CreadoPor = ' + CAST(@IdUsuario AS VARCHAR(50))
               + '
							ORDER BY FI_Factura.IdFactura DESC' AS VARCHAR(500));
    --==============================
    IF OBJECT_ID('tempdb..#TemporalTopFacturtas', 'U') IS NOT NULL
        DROP TABLE #TemporalTopFacturtas;
    /**/
    IF OBJECT_ID('tempdb..#TemporalIdDocumento', 'U') IS NOT NULL
        DROP TABLE #TemporalIdDocumento;
    --==============================
    CREATE TABLE #TemporalTopFacturtas
    (
        IdFacturaTOP INT,
        TipoComprobanteTOP VARCHAR(10),
        IdComplementoDePagoTOP INT
    );
    /**/
    CREATE TABLE #TemporalIdDocumento (IdDocumento VARCHAR(100));
    --==============================
    INSERT INTO #TemporalTopFacturtas
    (
        IdFacturaTOP,
        TipoComprobanteTOP,
        IdComplementoDePagoTOP
    )
    EXEC (@Consulta);
    --==============================
    INSERT INTO #TemporalIdDocumento
    (
        IdDocumento
    )
    SELECT CAST(FI_CPDocRelacionado.IdDocumento AS VARCHAR(100))
    FROM #TemporalTopFacturtas
        JOIN FI_CPDocRelacionado (NOLOCK)
            ON #TemporalTopFacturtas.IdComplementoDePagoTOP = FI_CPDocRelacionado.IdComplementoDePago
    WHERE #TemporalTopFacturtas.TipoComprobanteTOP = 'P'
    GROUP BY FI_CPDocRelacionado.IdDocumento
    HAVING COUNT(#TemporalTopFacturtas.IdFacturaTOP) < 2
    /**/
    IF EXISTS
    (
        SELECT FI_CPDocRelacionado.IdDocumento
        FROM FI_CPDocRelacionado (NOLOCK)
            JOIN #TemporalIdDocumento
                ON FI_CPDocRelacionado.IdDocumento = #TemporalIdDocumento.IdDocumento
        GROUP BY FI_CPDocRelacionado.IdDocumento
        HAVING COUNT(*) >= 2
    )
    BEGIN
        SELECT 'Ya existe un complemento de pago relacionado aun PPD revisa el detalle en la tabla inferior.' AS Resultado;
    END;
END;