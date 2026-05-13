IF OBJECT_ID('[dbo].[SP_FI_Comprobantes]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[SP_FI_Comprobantes];
GO

CREATE PROCEDURE [dbo].[SP_FI_Comprobantes]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @GrupoId INT = 10001;

    SELECT 
        PC.IdPedimentoComprobante AS IdComprobante,
        PC.FolioComprobante,
        PC.FechaPago,
        LEFT(SE.RazonSocial, 30) AS Exportador,
        PCD.NumeroSerieMercancia,
        PCD.ClaseBienServicio,
        LEFT(MU.Unidad, 30) AS UnidadMedida,
        TM.TipoMonedaCorto AS TipoMonedaCorto,
        CASE 
            WHEN PCD.PrecioUnitario IS NOT NULL AND PCD.PrecioUnitario > 0 
                THEN PCD.PrecioUnitario
            ELSE PCD.ImporteTotal 
        END AS PrecioUnitario,
        PCD.Cantidad,
        PCD.ImporteTotal,
        ISNULL(FP.Nombre, '') AS FormaDePago,
        CASE 
			WHEN D.DocumentoByte IS NULL OR DATALENGTH(D.DocumentoByte) = 0 THEN 'NO CARGADO'
			ELSE 'Cargado'
		END AS Archivo,
        ISNULL(UC.Nombre, '') AS CreadoPor,
        PC.CreadoEn,
        ISNULL(UM.Nombre, '') AS ModificadoPor,
        PC.ModificadoEn,
        PC.NumFacturaC,
        CASE 
            WHEN ISNULL(PC.EsnotaCredito, 0) = 0 THEN 'No'
            ELSE 'Sí'
        END AS EsNotaCredito
    FROM FI_PedimentoComprobante PC WITH (NOLOCK)
    INNER JOIN FI_PedimentoComprobanteDetalle PCD WITH (NOLOCK)
        ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
	INNER JOIN Cat_TipoDocumento TD
		ON PC.CvTipoDocFacturacion = TD.IdTipoDocumento
    INNER JOIN PV_Subcontratista SE WITH (NOLOCK)
        ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
    LEFT JOIN PV_MM_MaterialUnidad MU WITH (NOLOCK)
        ON PCD.IdUnidadMedida = MU.IdUnidad
    LEFT JOIN PV_TipoMoneda TM WITH (NOLOCK)
        ON PC.IdMoneda = TM.IdMoneda
    LEFT JOIN AP_Lista FP WITH (NOLOCK)
        ON PC.IdFormaPago = FP.IdClave AND FP.IdGrupo = @GrupoId
    LEFT JOIN FI_Documento D WITH (NOLOCK)
        ON PC.IdPedimentoComprobante = D.IdPedimentoComprobante 
        AND D.DocumentoByte IS NOT NULL 
        AND ISNULL(D.IsEliminado, 0) = 0
    LEFT JOIN AP_Usuario UC WITH (NOLOCK)
        ON PC.CreadoPor = UC.UsuarioID
    LEFT JOIN AP_Usuario UM WITH (NOLOCK)
        ON PC.ModificadoPor = UM.UsuarioID
    WHERE TD.TipoDeDocumento = 'Comprobante'
      AND PC.IdContrato = @IdContrato
	GROUP BY PC.IdPedimentoComprobante,
        PC.FolioComprobante,
        PC.FechaPago,
        LEFT(SE.RazonSocial, 30),
        PCD.NumeroSerieMercancia,
        PCD.ClaseBienServicio,
        LEFT(MU.Unidad, 30),
        TM.TipoMonedaCorto,
        PCD.PrecioUnitario,
        PCD.Cantidad,
        PCD.ImporteTotal,
        ISNULL(FP.Nombre, ''),
        CASE 
            WHEN D.DocumentoByte IS NOT NULL AND ISNULL(D.IsEliminado, 0) = 0 
                THEN 'Cargado'
            ELSE 'NO CARGADO'
        END,
        ISNULL(UC.Nombre, ''),
        PC.CreadoEn,
        ISNULL(UM.Nombre, ''),
        PC.ModificadoEn,
        PC.NumFacturaC,
        PC.EsnotaCredito,
		CASE 
			WHEN D.DocumentoByte IS NULL OR DATALENGTH(D.DocumentoByte) = 0 THEN 'NO CARGADO'
			ELSE 'Cargado'
		END
    ORDER BY PC.IdPedimentoComprobante DESC
END;
GO
