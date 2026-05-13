-- =============================================
-- Author:		Manuel CD
-- Create date: 05-12-17
-- Description:	
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	10 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK y la llamada de columnas con nombre especifico de la tabla durante su llamado.
--							Ajustes de left joins
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaPedimentosPorContrato]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE spanish;
    DECLARE @NombreAreaContractual VARCHAR(100) = '';
    --
    CREATE TABLE #PedimentosPorContrato
    (
        IdPedimento INT,
        NumeroPedimento VARCHAR(50),
        ClavePedimento VARCHAR(10),
        FolioComprobante VARCHAR(50),
        FechaPago DATE,
        Regimen VARCHAR(200),
        Importador VARCHAR(150),
        AduanaES VARCHAR(50),
        Exportador VARCHAR(150),
        AcuseElectronico VARCHAR(100),
        DescripcionMercancia VARCHAR(1000),
        TipoMonedaCorto VARCHAR(10),
        PrecioUnitario MONEY,
        Cantidad NUMERIC(15, 0),
        ClavePedimentoId INT,
        EsDePetrovendor BIT
    )

    SELECt TOP 1
        @NombreAreaContractual = ISNULL(CO_AreaContractual.NombreAreaContractual, '')
    FROM CO_Contrato
        JOIN CO_AreaContractual
            ON CO_Contrato.IdContrato = @IdContrato
               AND CO_Contrato.IdAreaContractual = CO_AreaContractual.IdAreaContractual

    INSERT INTO #PedimentosPorContrato
    (
        IdPedimento,
        NumeroPedimento,
        ClavePedimento,
        FolioComprobante,
        FechaPago,
        Regimen,
        Importador,
        AduanaES,
        Exportador,
        AcuseElectronico,
        DescripcionMercancia,
        TipoMonedaCorto,
        PrecioUnitario,
        Cantidad,
        ClavePedimentoId,
        EsDePetrovendor
    )
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante,
           FI_PedimentoComprobante.NumeroPedimento,
           '',
           FI_PedimentoComprobante.FolioComprobante,
           FI_PedimentoComprobante.FechaPago,
           FI_PedimentoComprobante.Regimen,
           PV_Subcontratista.RazonSocial,
           FI_PedimentoComprobante.AduanaES,
           PV_Subcontratista_Exportador.RazonSocial,
           FI_PedimentoComprobante.AcuseElectronico,
           FI_PedimentoComprobanteDetalle.DescripcionMercancia,
           PV_TipoMoneda.TipoMonedaCorto,
           FI_PedimentoComprobanteDetalle.PrecioUnitario,
           FI_PedimentoComprobanteDetalle.Cantidad,
           FI_PedimentoComprobante.ClavePedimento,
           EsDePetrovendor = CAST(CASE
                                      WHEN FI_PedimentoComprobante.IdPedimentoComprobantePetrovendor IS NULL THEN
                                          0
                                      ELSE
                                          1
                                  END AS BIT)
    FROM FI_PedimentoComprobante (NOLOCK)
        INNER JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
        INNER JOIN dbo.PV_Subcontratista (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaImportador = PV_Subcontratista.IdSubcontratista
        INNER JOIN dbo.PV_Subcontratista PV_Subcontratista_Exportador (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = PV_Subcontratista_Exportador.IdSubcontratista
        INNER JOIN dbo.PV_TipoMoneda (NOLOCK)
            ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
    WHERE FI_PedimentoComprobante.CvTipoDocFacturacion = 2
          AND FI_PedimentoComprobante.IdContrato = @IdContrato

    UPDATE #PedimentosPorContrato
    SET #PedimentosPorContrato.ClavePedimento = FI_ClavesPedimento.Clave
    FROM #PedimentosPorContrato
        JOIN dbo.FI_ClavesPedimento (NOLOCK)
            ON #PedimentosPorContrato.ClavePedimentoId = FI_ClavesPedimento.IdPedimento

    SELECT IdPedimento,
           NumeroPedimento,
           ClavePedimento,
           FolioComprobante,
           FechaPago,
           Regimen,
           Importador,
           AduanaES,
           Exportador,
           AcuseElectronico,
           DescripcionMercancia,
           TipoMonedaCorto,
           PrecioUnitario,
           Cantidad,
           CAST(CASE
                    WHEN @NombreAreaContractual = 'Amatitlán' THEN
                        ISNULL(EsDePetrovendor, 0)
                    ELSE
                        1
                END AS BIT) AS EsDePetrovendor
    FROM #PedimentosPorContrato
    ORDER BY IdPedimento DESC
END;