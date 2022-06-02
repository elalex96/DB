-- =============================================
-- Author:		Reyna Olvera
-- Create date:07/06/2018
-- Description:	
-- =============================================
-- Modification Author:	Neri del Angel
-- Modification Date:	02 de Junio del 2022
-- Description:			Optimizacion de PROCEDURE por temas de error marcado 
--						[Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding.]
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ComprobantePedimentosConDocumentoSoporte]
    @IdContrato INT,
    @IdUsuario INT,
    @idTipoArchivo INT
AS
BEGIN
    SET NOCOUNT ON;
    IF @idTipoArchivo = 2
    BEGIN
        CREATE TABLE #FI_Pedimento
        (
            IdPedimentoComprobante INT,
            Archivo VARCHAR(50),
            CreadoPor INT,
            CreadoPorTexto VARCHAR(MAX),
            ModificadoPor INT,
            ModificadoPorTexto VARCHAR(MAX),
            ClavePedimento INT,
            ClavePedimentoTexto VARCHAR(MAX),
            TieneSoporte BIT
        )
        INSERT INTO #FI_Pedimento
        (
            IdPedimentoComprobante,
            Archivo,
            CreadoPor,
            CreadoPorTexto,
            ModificadoPor,
            ModificadoPorTexto,
            ClavePedimento,
            ClavePedimentoTexto,
            TieneSoporte
        )
        SELECT PC.IdPedimentoComprobante,
               'NO CARGADO',
               PC.CreadoPor,
               '',
               PC.ModificadoPor,
               '',
               ClavePedimento,
               '',
               0
        FROM FI_PedimentoComprobante PC (NOLOCK)
        WHERE PC.CvTipoDocFacturacion = 2
              AND PC.IdContrato = @IdContrato

        UPDATE TEMP
        SET Archivo = CASE
                          WHEN D.DocumentoByte LIKE 0x THEN
                              'NO CARGADO'
                          ELSE
                              'Cargado'
                      END
        FROM #FI_Pedimento TEMP
            JOIN dbo.FI_Documento D (NOLOCK)
                ON TEMP.IdPedimentoComprobante = D.IdPedimentoComprobante
                   AND D.DocumentoByte IS NOT NULL
                   AND ISNULL(D.IsEliminado, 0) = 0

        UPDATE TEMP
        SET CreadoPorTexto = UC.Nombre
        FROM #FI_Pedimento TEMP
            JOIN dbo.AP_Usuario UC (NOLOCK)
                ON TEMP.CreadoPor = UC.UsuarioID

        UPDATE TEMP
        SET ModificadoPorTexto = UM.Nombre
        FROM #FI_Pedimento TEMP
            JOIN dbo.AP_Usuario UM (NOLOCK)
                ON TEMP.ModificadoPor = UM.UsuarioID

        UPDATE TEMP
        SET ClavePedimentoTexto = CP.Clave
        FROM #FI_Pedimento TEMP
            JOIN dbo.FI_ClavesPedimento CP (NOLOCK)
                ON TEMP.ClavePedimento = CP.IdPedimento

        UPDATE TEMP
        SET TieneSoporte = 1
        FROM #FI_Pedimento TEMP
            JOIN FI_RelacionSoporteFactura FS (NOLOCK)
                ON TEMP.IdPedimentoComprobante = FS.IdPedimentoComprobante
                   AND FS.DocumentoSoporteId IS NOT NULL
                   AND FS.Activo = 1

        SELECT PC.IdPedimentoComprobante AS IdPedimento,
               PC.NumeroPedimento,
               TEMP.ClavePedimentoTexto AS ClavePedimento,
               PC.FolioComprobante,
               PC.FechaPago,
               PC.Regimen,
               SI.RazonSocial AS Importador,
               PC.AduanaES,
               SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador,
               PC.AcuseElectronico,
               PCD.DescripcionMercancia,
               TM.TipoMonedaCorto,
               PCD.PrecioUnitario,
               PCD.Cantidad,
               TEMP.Archivo AS 'Archivo',
               TEMP.CreadoPorTexto AS CreadoPor,
               PC.CreadoEn,
               TEMP.ModificadoPorTexto AS ModificadoPor,
               PC.ModificadoEn,
               TieneSoporte = TEMP.TieneSoporte
        FROM #FI_Pedimento TEMP
            JOIN FI_PedimentoComprobante PC (NOLOCK)
                ON TEMP.IdPedimentoComprobante = PC.IdPedimentoComprobante
            INNER JOIN FI_PedimentoComprobanteDetalle PCD (NOLOCK)
                ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
            INNER JOIN dbo.PV_Subcontratista SI (NOLOCK)
                ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
            INNER JOIN dbo.PV_Subcontratista SE (NOLOCK)
                ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
            INNER JOIN dbo.PV_TipoMoneda TM (NOLOCK)
                ON PC.IdMoneda = TM.IdMoneda
        ORDER BY IdPedimento DESC;
    END
    ELSE IF @idTipoArchivo = 3
    BEGIN

        CREATE TABLE #FI_Comprobante
        (
            IdPedimentoComprobante INT,
            Archivo VARCHAR(50),
            NumeroSerieMercancia NVARCHAR(MAX),
            ClaseBienServicio NVARCHAR(MAX),
            PrecioUnitario MONEY,
            Cantidad NUMERIC,
            ImporteTotal MONEY,
            IdUnidadMedida INT,
            IdUnidadMedidaTexto VARCHAR(MAX),
            IdSubcontratistaImportador INT,
            IdSubcontratistaImportadorTexto VARCHAR(MAX),
            IdSubcontratistaExportador INT,
            IdSubcontratistaExportadorTexto VARCHAR(MAX),
            IdMoneda INT,
            IdMonedaTexto VARCHAR(MAX),
            IdFormaPago INT,
            IdFormaPagoTexto VARCHAR(MAX),
            CreadoPor INT,
            CreadoPorTexto VARCHAR(MAX),
            ModificadoPor INT,
            ModificadoPorTexto VARCHAR(MAX),
            TieneSoporte BIT
        )

        INSERT INTO #FI_Comprobante
        (
            IdPedimentoComprobante,
            Archivo,
            NumeroSerieMercancia,
            ClaseBienServicio,
            PrecioUnitario,
            Cantidad,
            ImporteTotal,
            IdUnidadMedida,
            IdUnidadMedidaTexto,
            IdSubcontratistaImportador,
            IdSubcontratistaImportadorTexto,
            IdSubcontratistaExportador,
            IdSubcontratistaExportadorTexto,
            IdMoneda,
            IdMonedaTexto,
            IdFormaPago,
            IdFormaPagoTexto,
            CreadoPor,
            CreadoPorTexto,
            ModificadoPor,
            ModificadoPorTexto,
            TieneSoporte
        )
        SELECT PC.IdPedimentoComprobante,
               'NO CARGADO',
               '',
               '',
               NULL,
               NULL,
               NULL,
               NULL,
               NULL,
               PC.IdSubcontratistaImportador,
               '',
               PC.IdSubcontratistaExportador,
               '',
               PC.IdMoneda,
               '',
               PC.IdFormaPago,
               '',
               PC.CreadoPor,
               '',
               PC.ModificadoPor,
               '',
               0
        FROM FI_PedimentoComprobante PC (NOLOCK)
        WHERE PC.CvTipoDocFacturacion = 3
              AND PC.IdContrato = @IdContrato

        UPDATE TEMP
        SET Archivo = CASE
                          WHEN D.DocumentoByte LIKE 0x THEN
                              'NO CARGADO'
                          ELSE
                              'Cargado'
                      END
        FROM #FI_Comprobante TEMP
            JOIN dbo.FI_Documento D (NOLOCK)
                ON TEMP.IdPedimentoComprobante = D.IdPedimentoComprobante
                   AND D.DocumentoByte IS NOT NULL
                   AND ISNULL(D.IsEliminado, 0) = 0

        UPDATE TEMP
        SET TieneSoporte = 1
        FROM #FI_Comprobante TEMP
            JOIN FI_RelacionSoporteFactura FS (NOLOCK)
                ON TEMP.IdPedimentoComprobante = FS.IdPedimentoComprobante
                   AND FS.DocumentoSoporteId IS NOT NULL
                   AND FS.Activo = 1
        UPDATE TEMP
        SET CreadoPorTexto = UC.Nombre
        FROM #FI_Comprobante TEMP
            JOIN dbo.AP_Usuario UC (NOLOCK)
                ON TEMP.CreadoPor = UC.UsuarioID

        UPDATE TEMP
        SET ModificadoPorTexto = UM.Nombre
        FROM #FI_Comprobante TEMP
            JOIN dbo.AP_Usuario UM (NOLOCK)
                ON TEMP.ModificadoPor = UM.UsuarioID

        UPDATE TEMP
        SET IdFormaPagoTexto = L.Nombre
        FROM #FI_Comprobante TEMP
            JOIN dbo.AP_Lista L (NOLOCK)
                ON TEMP.IdFormaPago = L.IdClave
                   AND L.IdGrupo = 10001

        UPDATE TEMP
        SET IdMonedaTexto = M.TipoMonedaCorto
        FROM #FI_Comprobante TEMP
            JOIN PV_TipoMoneda M (NOLOCK)
                ON TEMP.IdMoneda = M.IdMoneda


        UPDATE TEMP
        SET IdSubcontratistaImportadorTexto = SI.RazonSocial
        FROM #FI_Comprobante TEMP
            JOIN dbo.PV_Subcontratista SI (NOLOCK)
                ON TEMP.IdSubcontratistaImportador = SI.IdSubcontratista

        UPDATE TEMP
        SET IdSubcontratistaExportadorTexto = SE.RazonSocial
        FROM #FI_Comprobante TEMP
            JOIN dbo.PV_Subcontratista SE (NOLOCK)
                ON TEMP.IdSubcontratistaExportador = SE.IdSubcontratista


        UPDATE TEMP
        SET NumeroSerieMercancia = PCD.NumeroSerieMercancia,
            ClaseBienServicio = PCD.ClaseBienServicio,
            PrecioUnitario = PCD.PrecioUnitario,
            Cantidad = PCD.Cantidad,
            ImporteTotal = PCD.ImporteTotal,
            IdUnidadMedida = PCD.IdUnidadMedida
        FROM #FI_Comprobante TEMP
            JOIN FI_PedimentoComprobanteDetalle PCD (NOLOCK)
                ON TEMP.IdPedimentoComprobante = PCD.IdPedimentoComprobante

        UPDATE TEMP
        SET IdUnidadMedidaTexto = MU.UMB
        FROM #FI_Comprobante TEMP
            JOIN dbo.PV_MM_MaterialUnidad MU (NOLOCK)
                ON TEMP.IdUnidadMedida = MU.IdUnidad

        SELECT PC.IdPedimentoComprobante AS IdComprobante,
               PC.FolioComprobante,
               PC.FechaPago,
               SUBSTRING(TEMP.IdSubcontratistaExportadorTexto, 0, 30) AS Exportador,
               TEMP.NumeroSerieMercancia,
               TEMP.ClaseBienServicio,
               SUBSTRING(TEMP.IdUnidadMedidaTexto, 0, 30) AS UnidadMedida,
               TEMP.IdMonedaTexto AS TipoMonedaCorto,
               TEMP.PrecioUnitario,
               TEMP.Cantidad,
               TEMP.ImporteTotal,
               TEMP.IdFormaPagoTexto AS FormaDePago,
               Archivo AS 'Archivo',
               TEMP.CreadoPorTexto AS CreadoPor,
               PC.CreadoEn,
               TEMP.ModificadoPorTexto AS ModificadoPor,
               PC.ModificadoEn,
               PC.NumFacturaC,
               TieneSoporte = TEMP.TieneSoporte
        FROM #FI_Comprobante TEMP
            JOIN FI_PedimentoComprobante PC (NOLOCK)
                ON TEMP.IdPedimentoComprobante = PC.IdPedimentoComprobante
        ORDER BY IdComprobante DESC;
    END
END;
