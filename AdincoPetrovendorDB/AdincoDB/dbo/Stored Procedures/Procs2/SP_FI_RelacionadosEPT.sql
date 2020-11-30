-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-02-2020
-- Description:	Relacionados con el ept
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_RelacionadosEPT]
--[dbo].[SP_FI_RelacionadosEPT] 0,0,5
@IdContrato INT, 
@IdUsuario  INT, 
@IdEPT      INT
AS
    BEGIN
        SET NOCOUNT ON;
        IF OBJECT_ID('tempdb..#TEMPORAL', 'U') IS NOT NULL
            DROP TABLE #TEMPORAL;
        CREATE TABLE #TEMPORAL
        (Id           INT IDENTITY(1, 1), 
         IdEPT        INT, 
         Relacionados VARCHAR(MAX)
        );
        --Factura
        INSERT INTO #TEMPORAL
        (IdEPT, 
         Relacionados
        )
               SELECT @IdEPT AS IdEPT,
                      CASE
                          WHEN UUID IS NOT NULL
                          THEN 'Factura: ' + CONVERT(VARCHAR(MAX), IdFactura) + ', Con UUID: ' + UPPER(UUID)
                          ELSE 'Factura: ' + CONVERT(VARCHAR(MAX), IdFactura)
                      END AS Relacionados
               FROM dbo.FI_Factura
               WHERE IdEstudioPrecioTransfer = @IdEPT
               ORDER BY IdFactura DESC;
        --Pedimento
        INSERT INTO #TEMPORAL
        (IdEPT, 
         Relacionados
        )
               SELECT @IdEPT, 
                      'PI (Pedimento de Importació) con Id: ' + CONVERT(VARCHAR(MAX), IdPedimentoComprobante)
               FROM dbo.FI_PedimentoComprobante
               WHERE IdEstudioPrecioTransfer = @IdEPT
                     AND CvTipoDocFacturacion = 2
               ORDER BY IdPedimentoComprobante DESC;
        --Comprobante
        INSERT INTO #TEMPORAL
        (IdEPT, 
         Relacionados
        )
               SELECT @IdEPT, 
                      'PE (Comprobante de Proveedor en el Extranjero) con Id: ' + CONVERT(VARCHAR(MAX), IdPedimentoComprobante)
               FROM dbo.FI_PedimentoComprobante
               WHERE IdEstudioPrecioTransfer = @IdEPT
                     AND CvTipoDocFacturacion = 3
               ORDER BY IdPedimentoComprobante DESC;
        --Temporal
        SELECT IdEPT, 
               Relacionados
        FROM #TEMPORAL
        ORDER BY Id ASC;
    END;