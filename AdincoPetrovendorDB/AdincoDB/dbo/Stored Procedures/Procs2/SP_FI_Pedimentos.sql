IF OBJECT_ID('[dbo].[SP_FI_Pedimentos]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[SP_FI_Pedimentos];
GO

CREATE PROCEDURE [dbo].[SP_FI_Pedimentos]  
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        PC.IdPedimentoComprobante AS IdPedimento,
        PC.NumeroPedimento,
        ISNULL(CP.Clave, '') AS ClavePedimento,
        PC.FolioComprobante,
        PC.FechaPago,
        PC.Regimen,
        SI.RazonSocial AS Importador,
        PC.AduanaES,
        LEFT(SE.RazonSocial, 30) AS Exportador,
        PC.AcuseElectronico,
        PCD.DescripcionMercancia,
        TM.TipoMonedaCorto,
        PCD.PrecioUnitario,
        PCD.Cantidad,
        CASE 
			WHEN D.DocumentoByte IS NULL OR DATALENGTH(D.DocumentoByte) = 0 THEN 'NO CARGADO'
			ELSE 'Cargado'
		END AS Archivo,
        ISNULL(UC.Nombre, '') AS CreadoPor,
        PC.CreadoEn,
        ISNULL(UM.Nombre, '') AS ModificadoPor,
        PC.ModificadoEn,
        ISNULL(PC.CuentaBancaria, '') AS CuentaBancaria,
        PCD.ImporteTotal,
		CASE 
            WHEN ISNULL(PC.EsnotaCredito, 0) = 0 THEN 'No'
            ELSE 'Sí'
        END AS EsNotaCredito
    FROM FI_PedimentoComprobante PC WITH (NOLOCK)
    INNER JOIN FI_PedimentoComprobanteDetalle PCD WITH (NOLOCK)
        ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
	INNER JOIN Cat_TipoDocumento TD
		ON PC.CvTipoDocFacturacion = TD.IdTipoDocumento
    LEFT JOIN FI_ClavesPedimento CP WITH (NOLOCK)
        ON PC.ClavePedimento = CP.IdPedimento
    LEFT JOIN FI_Documento D WITH (NOLOCK)
        ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante
        AND D.DocumentoByte IS NOT NULL
        AND ISNULL(D.IsEliminado, 0) = 0
    LEFT JOIN AP_Usuario UC WITH (NOLOCK)
        ON PC.CreadoPor = UC.UsuarioID
    LEFT JOIN AP_Usuario UM WITH (NOLOCK)
        ON PC.ModificadoPor = UM.UsuarioID
    INNER JOIN PV_Subcontratista SI WITH (NOLOCK)
        ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
    INNER JOIN PV_Subcontratista SE WITH (NOLOCK)
        ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
    INNER JOIN PV_TipoMoneda TM WITH (NOLOCK)
        ON PC.IdMoneda = TM.IdMoneda
    WHERE TD.TipoDeDocumento = 'Pedimento'
      AND PC.IdContrato = @IdContrato
    ORDER BY PC.IdPedimentoComprobante DESC;
END;
GO
	