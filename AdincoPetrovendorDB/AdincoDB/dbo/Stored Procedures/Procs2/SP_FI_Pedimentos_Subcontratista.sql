IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_Pedimentos_Subcontratista'
)
    DROP PROCEDURE SP_FI_Pedimentos_Subcontratista;
GO
-- =============================================
-- Author:		DANIEL MORENO
-- Create date: 03-11-21
-- Description:	
-- =============================================

CREATE PROCEDURE [dbo].[SP_FI_Pedimentos_Subcontratista]
    @IdContrato INT,
    @IdUsuario INT,
    @IdSubcontratista INT
AS
BEGIN
    SET NOCOUNT ON;

    --
    DECLARE @Pedimento INT = 2,
            @Comprobante INT = 3;

    --
    CREATE TABLE #TemporalPedimentos
    (
        IdPedimento INT NULL,
        NumeroPedimento VARCHAR(500) NULL,
        ClavePedimento VARCHAR(500) NULL,
        FolioComprobante VARCHAR(500) NULL,
        FechaPago DATE NULL,
        Regimen VARCHAR(500) NULL,
        Importador VARCHAR(500) NULL,
        AduanaES VARCHAR(500) NULL,
        Exportador VARCHAR(500) NULL,
        AcuseElectronico VARCHAR(500) NULL,
        DescripcionMercancia VARCHAR(500) NULL,
        TipoMonedaCorto VARCHAR(500) NULL,
        PrecioUnitario MONEY,
        Cantidad NUMERIC,
        Archivo VARCHAR(100) NULL,
        CreadoPor VARCHAR(500) NULL,
        CreadoEn DATETIME NULL,
        ModificadoPor VARCHAR(500) NULL,
        ModificadoEn DATETIME NULL,
        CuentaBancaria VARCHAR(500) NULL,
        IdSubcontratistaImportador INT NULL,
        CreadoPorId INT NULL,
        ModificadoPorId INT NULL,
        ClavePedimentoId INT NULL
    );

    --
    INSERT INTO #TemporalPedimentos
    (
        IdPedimento,
        NumeroPedimento,
        FolioComprobante,
        FechaPago,
        Regimen,
        AduanaES,
        Exportador,
        AcuseElectronico,
        DescripcionMercancia,
        TipoMonedaCorto,
        PrecioUnitario,
        Cantidad,
        Archivo,
        CreadoEn,
        ModificadoEn,
        CuentaBancaria,
        IdSubcontratistaImportador,
        CreadoPorId,
        ModificadoPorId,
        ClavePedimentoId
    )
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante AS IdPedimento,
           FI_PedimentoComprobante.NumeroPedimento,
           FI_PedimentoComprobante.FolioComprobante,
           FI_PedimentoComprobante.FechaPago,
           FI_PedimentoComprobante.Regimen,
           FI_PedimentoComprobante.AduanaES,
           SUBSTRING(PV_Subcontratista.RazonSocial, 0, 30) AS Exportador,
           FI_PedimentoComprobante.AcuseElectronico,
           FI_PedimentoComprobanteDetalle.DescripcionMercancia,
           PV_TipoMoneda.TipoMonedaCorto,
           FI_PedimentoComprobanteDetalle.PrecioUnitario,
           FI_PedimentoComprobanteDetalle.Cantidad,
           'Cargado' AS 'Archivo',
           FI_PedimentoComprobante.CreadoEn,
           FI_PedimentoComprobante.ModificadoEn,
           FI_PedimentoComprobante.CuentaBancaria,
           FI_PedimentoComprobante.IdSubcontratistaImportador,
           FI_PedimentoComprobante.CreadoPor CreadoPorId,
           FI_PedimentoComprobante.ModificadoPor ModificadoPorId,
           FI_PedimentoComprobante.ClavePedimento ClavePedimentoId
    FROM FI_PedimentoComprobante (NOLOCK)
        INNER JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON FI_PedimentoComprobante.CvTipoDocFacturacion IN ( @Pedimento, @Comprobante )
               AND FI_PedimentoComprobante.IdContrato = @IdContrato
               AND FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
        INNER JOIN dbo.PV_Subcontratista (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista.IdSubcontratista
               AND PV_Subcontratista.IdSubcontratista = @IdSubcontratista
        INNER JOIN dbo.PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda;

    --
    UPDATE #TemporalPedimentos
    SET #TemporalPedimentos.Importador = PV_Subcontratista.RazonSocial
    FROM #TemporalPedimentos
        JOIN PV_Subcontratista
            ON #TemporalPedimentos.IdSubcontratistaImportador = PV_Subcontratista.IdSubcontratista;

    UPDATE #TemporalPedimentos
    SET #TemporalPedimentos.CreadoPor = AP_Usuario.Nombre
    FROM #TemporalPedimentos
        JOIN AP_Usuario
            ON #TemporalPedimentos.CreadoPorId = AP_Usuario.UsuarioID;

    UPDATE #TemporalPedimentos
    SET #TemporalPedimentos.ModificadoPor = AP_Usuario.Nombre
    FROM #TemporalPedimentos
        JOIN AP_Usuario
            ON #TemporalPedimentos.ModificadoPorId = AP_Usuario.UsuarioID;

    UPDATE #TemporalPedimentos
    SET #TemporalPedimentos.Archivo = 'NO CARGADO'
    FROM #TemporalPedimentos
        JOIN FI_Documento
            ON #TemporalPedimentos.IdPedimento = FI_Documento.IdPedimentoComprobante
               AND (
                       FI_Documento.DocumentoByte IS NULL
                       OR FI_Documento.DocumentoByte LIKE 0x
                   );

    UPDATE #TemporalPedimentos
    SET #TemporalPedimentos.ClavePedimento = FI_ClavesPedimento.Clave
    FROM #TemporalPedimentos
        JOIN FI_ClavesPedimento
            ON #TemporalPedimentos.ClavePedimentoId = FI_ClavesPedimento.IdPedimento;

    --
    SELECT IdPedimento,
           ISNULL(LTRIM(RTRIM(NumeroPedimento)), '') NumeroPedimento,
           ISNULL(LTRIM(RTRIM(ClavePedimento)), '') ClavePedimento,
           ISNULL(LTRIM(RTRIM(FolioComprobante)), '') FolioComprobante,
           FechaPago,
           ISNULL(LTRIM(RTRIM(Regimen)), '') Regimen,
           ISNULL(LTRIM(RTRIM(Importador)), '') Importador,
           ISNULL(LTRIM(RTRIM(AduanaES)), '') AduanaES,
           ISNULL(LTRIM(RTRIM(Exportador)), '') Exportador,
           ISNULL(LTRIM(RTRIM(AcuseElectronico)), '') AcuseElectronico,
           ISNULL(LTRIM(RTRIM(DescripcionMercancia)), '') DescripcionMercancia,
           ISNULL(LTRIM(RTRIM(TipoMonedaCorto)), '') TipoMonedaCorto,
           ISNULL(PrecioUnitario, 0) PrecioUnitario,
           ISNULL(Cantidad, 0) Cantidad,
           ISNULL(LTRIM(RTRIM(Archivo)), 'NO CARGADO') Archivo,
           ISNULL(LTRIM(RTRIM(CreadoPor)), '') CreadoPor,
           CreadoEn,
           ISNULL(LTRIM(RTRIM(ModificadoPor)), '') ModificadoPor,
           ModificadoEn,
           ISNULL(LTRIM(RTRIM(CuentaBancaria)), '') CuentaBancaria
    FROM #TemporalPedimentos
    ORDER BY IdPedimento DESC;
END;