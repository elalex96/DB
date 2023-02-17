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
-- Description:			Se modifica el stored procedure para mostrar el importe correcto en el gridview de la pantalla
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
        CreadoPorTexto VARCHAR(MAX),
        ModificadoPor INT,
        ModificadoPorTexto VARCHAR(MAX),
        ClavePedimento INT,
        ClavePedimentoTexto VARCHAR(MAX),
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
    SELECT PC.IdPedimentoComprobante,
           'NO CARGADO',
           PC.CreadoPor,
           '',
           PC.ModificadoPor,
           '',
           ClavePedimento,
           ''
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
    FROM #FI_PedimentoComprobante TEMP
        JOIN dbo.FI_Documento D (NOLOCK)
            ON TEMP.IdPedimentoComprobante = D.IdPedimentoComprobante
               AND D.DocumentoByte IS NOT NULL
               AND ISNULL(D.IsEliminado, 0) = 0

    UPDATE TEMP
    SET CreadoPorTexto = UC.Nombre
    FROM #FI_PedimentoComprobante TEMP
        JOIN dbo.AP_Usuario UC (NOLOCK)
            ON TEMP.CreadoPor = UC.UsuarioID

    UPDATE TEMP
    SET ModificadoPorTexto = UM.Nombre
    FROM #FI_PedimentoComprobante TEMP
        JOIN dbo.AP_Usuario UM (NOLOCK)
            ON TEMP.ModificadoPor = UM.UsuarioID

    UPDATE TEMP
    SET ClavePedimentoTexto = CP.Clave
    FROM #FI_PedimentoComprobante TEMP
        JOIN dbo.FI_ClavesPedimento CP (NOLOCK)
            ON TEMP.ClavePedimento = CP.IdPedimento

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
           ISNULL(pc.CuentaBancaria, '') CuentaBancaria,
		   PCD.ImporteTotal
    FROM #FI_PedimentoComprobante TEMP
        JOIN FI_PedimentoComprobante PC (NOLOCK)
            ON TEMP.IdPedimentoComprobante = PC.IdPedimentoComprobante
        INNER JOIN FI_PedimentoComprobanteDetalle AS PCD (NOLOCK)
            ON PC.IdPedimentoComprobante = PCD.IdPedimentoComprobante
        INNER JOIN dbo.PV_Subcontratista SI (NOLOCK)
            ON PC.IdSubcontratistaImportador = SI.IdSubcontratista
        INNER JOIN dbo.PV_Subcontratista SE (NOLOCK)
            ON PC.IdSubcontratistaExportador = SE.IdSubcontratista
        INNER JOIN dbo.PV_TipoMoneda TM (NOLOCK)
  ON PC.IdMoneda = TM.IdMoneda
    ORDER BY TEMP.ClavePedimento DESC;
END;