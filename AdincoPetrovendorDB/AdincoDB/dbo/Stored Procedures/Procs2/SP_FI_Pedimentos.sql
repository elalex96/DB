
IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'SP_FI_Pedimentos'
    )
    DROP PROCEDURE SP_FI_Pedimentos
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:		Manuel CD
-- Create date: 15-11-17
-- Description:	
-- =============================================
-- Modification Author:	Neri del Angel
-- Modification Date:	02 de Junio del 2022
-- Description:			Optimizacion de PROCEDURE por temas de error marcado 
--						[Execution Timeout Expired.  The timeout period elapsed prior to completion of the operation or the server is not responding.]
-- =============================================
-- Modification Author:	Reyna Olvera
-- Modification Date:	16 de Febrero del 2023
-- Description:			Se modifica el stored procedure para mostrar el 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_Pedimentos]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    CREATE TABLE #FI_PedimentoComprobante
    (
        IdPedimentoComprobante INT,
        Archivo VARCHAR(50),
        CreadoPor INT,
        CreadoPorTexto VARCHAR(5000),
        ModificadoPor INT,
        ModificadoPorTexto VARCHAR(5000),
        ClavePedimento INT,
        ClavePedimentoTexto VARCHAR(5000),
		PRIMARY KEY (IdPedimentoComprobante)
    )

    INSERT INTO #FI_PedimentoComprobante
    (
        IdPedimentoComprobante,
        Archivo,
        CreadoPor,
        CreadoPorTexto,
        ModificadoPor,
        ModificadoPorTexto,
        ClavePedimento,
        ClavePedimentoTexto
    )
    SELECT FI_PedimentoComprobante.IdPedimentoComprobante,
           'NO CARGADO',
           FI_PedimentoComprobante.CreadoPor,
           '',
           FI_PedimentoComprobante.ModificadoPor,
           '',
           ClavePedimento,
           ''
    FROM 
		FI_PedimentoComprobante  (NOLOCK)
    WHERE 
		FI_PedimentoComprobante.CvTipoDocFacturacion = 2
    AND 
		FI_PedimentoComprobante.IdContrato = @IdContrato

    UPDATE TEMP
    SET Archivo = CASE
                      WHEN FI_Documento.DocumentoByte LIKE 0x THEN
                          'NO CARGADO'
                      ELSE
                          'Cargado'
                  END
    FROM #FI_PedimentoComprobante TEMP
	JOIN 
		dbo.FI_Documento 
	ON 
		TEMP.IdPedimentoComprobante = FI_Documento.IdPedimentoComprobante
               AND FI_Documento.DocumentoByte IS NOT NULL
               AND ISNULL(FI_Documento.IsEliminado, 0) = 0

    UPDATE TEMP
    SET CreadoPorTexto = AP_Usuario.Nombre
    FROM #FI_PedimentoComprobante TEMP
        JOIN dbo.AP_Usuario 
            ON TEMP.CreadoPor = AP_Usuario.UsuarioID

    UPDATE TEMP
    SET ModificadoPorTexto = AP_Usuario.Nombre
    FROM #FI_PedimentoComprobante TEMP
        JOIN dbo.AP_Usuario  
            ON TEMP.ModificadoPor = AP_Usuario.UsuarioID

    UPDATE TEMP
    SET ClavePedimentoTexto = FI_ClavesPedimento.Clave
    FROM #FI_PedimentoComprobante TEMP
        JOIN dbo.FI_ClavesPedimento  
            ON TEMP.ClavePedimento = FI_ClavesPedimento.IdPedimento

    SELECT FI_PedimentoComprobante.IdPedimentoComprobante AS IdPedimento,
           FI_PedimentoComprobante.NumeroPedimento,
           TEMP.ClavePedimentoTexto AS ClavePedimento,
           FI_PedimentoComprobante.FolioComprobante,
           FI_PedimentoComprobante.FechaPago,
           FI_PedimentoComprobante.Regimen,
           SI.RazonSocial AS Importador,
           FI_PedimentoComprobante.AduanaES,
           SUBSTRING(SE.RazonSocial, 0, 30) AS Exportador,
           FI_PedimentoComprobante.AcuseElectronico,
           FI_PedimentoComprobanteDetalle.DescripcionMercancia,
           PV_TipoMoneda.TipoMonedaCorto,
           FI_PedimentoComprobanteDetalle.PrecioUnitario,
           FI_PedimentoComprobanteDetalle.Cantidad,
           TEMP.Archivo AS 'Archivo',
           TEMP.CreadoPorTexto AS CreadoPor,
           FI_PedimentoComprobante.CreadoEn,
           TEMP.ModificadoPorTexto AS ModificadoPor,
           FI_PedimentoComprobante.ModificadoEn,
           ISNULL(FI_PedimentoComprobante.CuentaBancaria, '') CuentaBancaria,
		   FI_PedimentoComprobanteDetalle.ImporteTotal
    FROM #FI_PedimentoComprobante TEMP
        JOIN FI_PedimentoComprobante (NOLOCK)
            ON TEMP.IdPedimentoComprobante = FI_PedimentoComprobante.IdPedimentoComprobante
        INNER JOIN FI_PedimentoComprobanteDetalle (NOLOCK)
            ON FI_PedimentoComprobante.IdPedimentoComprobante = FI_PedimentoComprobanteDetalle.IdPedimentoComprobante
        INNER JOIN dbo.PV_Subcontratista SI (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaImportador = SI.IdSubcontratista
        INNER JOIN dbo.PV_Subcontratista SE (NOLOCK)
            ON FI_PedimentoComprobante.IdSubcontratistaExportador = SE.IdSubcontratista
        INNER JOIN dbo.PV_TipoMoneda  (NOLOCK)
			ON FI_PedimentoComprobante.IdMoneda = PV_TipoMoneda.IdMoneda
    ORDER BY TEMP.IdPedimentoComprobante DESC;
END;

