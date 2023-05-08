-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-02-2020
-- Description:	Validaciones del Estudio de Precio de Transfer
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ValidacionesEPT]
--[dbo].[SP_FI_ValidacionesEPT] 0,0,5
@IdContrato INT, 
@IdUsuario  INT, 
@IdEPT      INT
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @Texto VARCHAR(MAX) = '', @Count INT= 0;
        --Factura
        IF EXISTS
        (
            SELECT *
            FROM dbo.FI_Factura
            WHERE IdEstudioPrecioTransfer = @IdEPT
        )
            BEGIN                
                SET @Texto = @Texto +
                (
                    SELECT CASE
                               WHEN COUNT(IdFactura) > 1
                               THEN '(' + CONVERT(NVARCHAR(MAX), COUNT(IdFactura)) + ') Facturas'
                               ELSE 'una Factura'
                           END AS Validacion
                    FROM dbo.FI_Factura
                    WHERE IdEstudioPrecioTransfer = @IdEPT
                );
				SET @Count = @Count + 1;
            END;
        --Pedimento
        IF EXISTS
        (
            SELECT *
            FROM dbo.FI_PedimentoComprobante
            WHERE IdEstudioPrecioTransfer = @IdEPT
                  AND CvTipoDocFacturacion = 2
        )
            BEGIN                
                IF @Count > 0
                    BEGIN
                        SET @Texto = @Texto + ', ';
                    END;
                SET @Texto = @Texto +
                (
                    SELECT CASE
                               WHEN COUNT(IdEstudioPrecioTransfer) > 1
                               THEN ' a (' + CONVERT(NVARCHAR(MAX), COUNT(IdEstudioPrecioTransfer)) + ') Pedimentos de Importación'
                               ELSE 'un Pedimento de Importación'
                           END
                    FROM dbo.FI_PedimentoComprobante
                    WHERE IdEstudioPrecioTransfer = @IdEPT
                          AND CvTipoDocFacturacion = 2
                );
				SET @Count = @Count + 1;
            END;
        --Comprobante
        IF EXISTS
        (
            SELECT *
            FROM dbo.FI_PedimentoComprobante
            WHERE IdEstudioPrecioTransfer = @IdEPT
                  AND CvTipoDocFacturacion = 3
        )
            BEGIN                
                IF @Count > 0
                    BEGIN
                        SET @Texto = @Texto + ' y ';
                    END;
                SET @Texto = @Texto +
                (
                    SELECT CASE
                               WHEN COUNT(IdEstudioPrecioTransfer) > 1
                               THEN 'a (' + CONVERT(NVARCHAR(MAX), COUNT(IdEstudioPrecioTransfer)) + ') Comprobantes de Proveedor en el Extranjero'
                               ELSE ' un Comprobante de Proveedor en el Extranjero'
                           END
                    FROM dbo.FI_PedimentoComprobante
                    WHERE IdEstudioPrecioTransfer = @IdEPT
                          AND CvTipoDocFacturacion = 3
                );
				SET @Count = @Count + 1;
            END;
        --
        IF @Count > 0
            BEGIN
                SELECT 'El estudio de precios de transferencia con id: ' + CONVERT(NVARCHAR(MAX), @IdEPT) + ' esta ligado ' + @Texto + '.' AS Validacion;
            END;
    END;