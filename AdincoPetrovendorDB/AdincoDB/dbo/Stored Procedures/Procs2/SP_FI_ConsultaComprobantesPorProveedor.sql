IF EXISTS
(
    SELECT 1
    FROM sysobjects
    WHERE name = 'SP_FI_ConsultaComprobantesPorProveedor'
)
    DROP PROCEDURE SP_FI_ConsultaComprobantesPorProveedor;
GO

-- =============================================
-- Author:		 Marcos Garcia
-- Create date:  06-12-2019
-- Description:	 Selección de Todos los Complementos 
--				 por Proveedor y por Contratista 
-- =============================================
-- Author:		 Marcos Garcia
-- Alter date:   06-12-2019
-- Description:	 Agregar MAX a la Columna FechaDePago
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaComprobantesPorProveedor]
    @IdProveedor INT,
    @IdContrato INT,
    @IdUsuario INT,
    @Relacion INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    IF OBJECT_ID('tempdb..#ContratosTempo', 'U') IS NOT NULL
        DROP TABLE #ContratosTempo;

    --
    IF OBJECT_ID('tempdb..#Transfer', 'U') IS NOT NULL
        DROP TABLE #Transfer;

    --
    IF OBJECT_ID('tempdb..#TransferConcat', 'U') IS NOT NULL
        DROP TABLE #TransferConcat;

    --
    DECLARE @IdContratista INT;

    --
    CREATE TABLE #ContratosTempo
    (
        IdContrato INT,
        NumeroContrato NVARCHAR(50)
    );

    --
    CREATE TABLE #Transfer
    (
        IdFactura INT,
        IdTransfer INT
    );

    --
    CREATE TABLE #TransferConcat
    (
        IdFactura INT,
        IdTransferChar VARCHAR(8000),
        ConTransfer INT
    );

    --
    SET @IdContratista =
    (
        SELECT IdContratista
        FROM CO_Contrato (NOLOCK)
        WHERE IdContrato = @IdContrato
    );

    /*Solo Para Jaguar*/
    IF (@IdContratista = 10005 OR @IdContratista = 10006)
    BEGIN
        INSERT INTO #ContratosTempo
        (
            IdContrato,
            NumeroContrato
        )
        SELECT IdContrato,
               NumeroContrato
        FROM CO_Contrato (NOLOCK)
        WHERE IdContratista IN ( 10005, 10006 )
              AND ISNULL(Activo, 0) = 1;
    END;
    ELSE
    BEGIN
        INSERT INTO #ContratosTempo
        (
            IdContrato,
            NumeroContrato
        )
        SELECT IdContrato,
               NumeroContrato
        FROM CO_Contrato (NOLOCK)
        WHERE IdContratista = @IdContratista
              AND ISNULL(Activo, 0) = 1;
    END;

    /*Selección  de Complementos de Todos los Contratos Relacionados */
    IF (@Relacion = 0)
    BEGIN
        SELECT FI_Factura.IdFactura AS IdCompReciboPago,
               #ContratosTempo.NumeroContrato,
               FI_Factura.Serie,
               FI_Factura.Folio,
               FI_Factura.Fecha,
               FI_Factura.FormaPago AS MetodoDePago,
               FI_Factura.SubTotal,
               FI_Factura.Moneda,
               FI_Factura.MontoConIva,
               FI_Factura.TipoComprobante,
               FI_ComplementoDePago.FormaDePagoP AS FormaDePago,
               FI_Factura.LugarExpedicion,
               FI_Factura.UUID,
               FI_Factura.FechaTimbrado,
               FI_Factura.FechaRecepcion,
               SUBSTRING(PV_Subcontratista.RazonSocial, 0, 30) AS RazonSocial,
               FI_Factura.Emisor,
               MAX(CAST(FI_ComplementoDePago.FechaDePago AS DATE)) AS FechaDePago,
               FI_ComplementoDePago.MonedaP,
               SUM(FI_ComplementoDePago.Monto) AS MontoPagado
        FROM FI_ComplementoDePago (NOLOCK)
            JOIN FI_Factura (NOLOCK)
                ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
                   AND FI_Factura.IdSubcontratista = @IdProveedor
                   AND FI_Factura.TipoComprobante = 'P'
                   AND ISNULL(FI_Factura.VarTransfer, 0) = 0
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
            INNER JOIN #ContratosTempo
                ON FI_Factura.IdContrato = #ContratosTempo.IdContrato
        GROUP BY SUBSTRING(PV_Subcontratista.RazonSocial, 0, 30),
                 FI_Factura.IdFactura,
                 #ContratosTempo.NumeroContrato,
                 FI_Factura.Serie,
                 FI_Factura.Folio,
                 FI_Factura.Fecha,
                 FI_Factura.FormaPago,
                 FI_Factura.SubTotal,
                 FI_Factura.Moneda,
                 FI_Factura.MontoConIva,
                 FI_Factura.TipoComprobante,
                 FI_ComplementoDePago.FormaDePagoP,
                 FI_Factura.LugarExpedicion,
                 FI_Factura.UUID,
                 FI_Factura.FechaTimbrado,
                 FI_Factura.FechaRecepcion,
                 FI_Factura.Emisor,
                 FI_ComplementoDePago.MonedaP
        ORDER BY IdCompReciboPago DESC;
    END;

    --
    IF (@Relacion <> 0)
    BEGIN
        INSERT INTO #Transfer
        (
            IdFactura,
            IdTransfer
        )
        SELECT FI_TransferFactura.IdFactura,
               FI_TransferFactura.IdTransfer
        FROM FI_Factura (NOLOCK)
            INNER JOIN FI_TransferFactura (NOLOCK)
                ON FI_Factura.IdSubcontratista = @IdProveedor
                   AND FI_Factura.TipoComprobante = 'P'
                   AND ISNULL(FI_Factura.VarTransfer, 0) = 1
                   AND FI_Factura.IdFactura = FI_TransferFactura.IdFactura
            INNER JOIN #ContratosTempo
                ON FI_Factura.IdContrato = #ContratosTempo.IdContrato
        GROUP BY FI_TransferFactura.IdFactura,
                 FI_TransferFactura.IdTransfer;

        --
        INSERT INTO #TransferConcat
        (
            IdFactura,
            IdTransferChar,
            ConTransfer
        )
        SELECT DISTINCT
            B.IdFactura,
            STUFF(
            (
                SELECT ' | ' + RTRIM(LTRIM(CONVERT(NVARCHAR(MAX), u.IdTransfer)))
                FROM #Transfer u
                WHERE B.IdFactura = u.IdFactura
                FOR XML PATH('')
            ),
            1,
            2,
            ''
                 ),
            COUNT(B.IdFactura)
        FROM #Transfer B
        GROUP BY B.IdFactura;

        --
        SELECT FI_Factura.IdFactura AS IdCompReciboPago,
               #ContratosTempo.NumeroContrato,
               ISNULL(#TransferConcat.IdTransferChar, 'Sin Transferencia(s) Relacionada(s)') AS Transferencia,
               FI_Factura.UUID,
               ISNULL(#TransferConcat.ConTransfer, 0) AS ConTransfer
        FROM FI_ComplementoDePago (NOLOCK)
            JOIN FI_Factura (NOLOCK)
                ON FI_ComplementoDePago.IdFactura = FI_Factura.IdFactura
                   AND FI_Factura.IdSubcontratista = @IdProveedor
                   AND FI_Factura.TipoComprobante = 'P'
                   AND ISNULL(FI_Factura.VarTransfer, 0) = 1
            JOIN PV_Subcontratista (NOLOCK)
                ON FI_Factura.IdSubcontratista = PV_Subcontratista.IdSubcontratista
            INNER JOIN #ContratosTempo
                ON FI_Factura.IdContrato = #ContratosTempo.IdContrato
            LEFT JOIN #TransferConcat
                ON FI_Factura.IdFactura = #TransferConcat.IdFactura
        GROUP BY ISNULL(#TransferConcat.IdTransferChar, 'Sin Transferencia(s) Relacionada(s)'),
                 FI_Factura.IdFactura,
                 #ContratosTempo.NumeroContrato,
                 FI_Factura.UUID,
                 #TransferConcat.ConTransfer
        ORDER BY IdCompReciboPago DESC;
    END;
END;