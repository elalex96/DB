IF OBJECT_ID('dbo.SP_FI_EditarComprobante', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_FI_EditarComprobante;
GO

CREATE PROCEDURE [dbo].[SP_FI_EditarComprobante]
    @IdPedimentoComprobante      INT,
    @IdContrato                  INT,
    @FolioComprobante            VARCHAR(5000),
    @FechaPago                   DATE,
    @IdSubcontratistaExportador INT,
    @IdMoneda                    INT,
    @IdUnidadMedida              INT,
    @NumFac                      VARCHAR(50),
    @ClaseBienServicio           VARCHAR(5000),
    @Subtotal                    MONEY,
    @IdUsuario                   INT,
    @CvTipoDoc                   INT,
    @EsNotaCredito               BIT,
    @DocumentoPDF                VARCHAR(100) -- texto como "Cargado" o vacío
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;

        ---------------------------------------------------------
        -- Validación: revisar si hay documento cargado
        ---------------------------------------------------------
        DECLARE @HayPDF BIT = CASE WHEN ISNULL(@DocumentoPDF, '') <> '' THEN 1 ELSE 0 END;

        ---------------------------------------------------------
        -- Actualizar encabezado del comprobante
        ---------------------------------------------------------
        UPDATE dbo.FI_PedimentoComprobante
        SET
            FolioComprobante           = @FolioComprobante,
            FechaPago                  = @FechaPago,
            IdSubcontratistaExportador = @IdSubcontratistaExportador,
            IdMoneda                   = @IdMoneda,
            CvTipoDocFacturacion       = @CvTipoDoc,
            NumFacturaC                = @NumFac,
            EsnotaCredito              = @EsNotaCredito,
            ModificadoPor              = @IdUsuario,
            ModificadoEn               = SYSDATETIME()
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante;

        ---------------------------------------------------------
        -- Insertar o actualizar el detalle
        ---------------------------------------------------------
        IF EXISTS (
            SELECT 1
            FROM dbo.FI_PedimentoComprobanteDetalle
            WHERE IdPedimentoComprobante = @IdPedimentoComprobante
        )
        BEGIN
            UPDATE dbo.FI_PedimentoComprobanteDetalle
            SET
                IdUnidadMedida    = @IdUnidadMedida,
                ClaseBienServicio = @ClaseBienServicio,
                PrecioUnitario    = @Subtotal,
                ModificadoPor     = @IdUsuario,
                ModificadoEn      = SYSDATETIME()
            WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
        END
        ELSE
        BEGIN
            INSERT INTO dbo.FI_PedimentoComprobanteDetalle (
                IdPedimentoComprobante,
                IdUnidadMedida,
                ClaseBienServicio,
                PrecioUnitario,
                ModificadoPor,
                ModificadoEn,
                CreadoPor,
                CreadoEn
            )
            VALUES (
                @IdPedimentoComprobante,
                @IdUnidadMedida,
                @ClaseBienServicio,
                @Subtotal,
                @IdUsuario,
                SYSDATETIME(),
                @IdUsuario,
                SYSDATETIME()
            );
        END;

        ---------------------------------------------------------
        -- Si hay documento cargado, actualizar 
        ---------------------------------------------------------
        IF @HayPDF = 1
        BEGIN
            UPDATE dbo.FI_Documento
            SET
                ModificadoPor = @IdUsuario,
                ModificadoEn  = SYSDATETIME()
            WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
        END;

        COMMIT;

        SELECT 'true' AS msj, @IdPedimentoComprobante;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @msg NVARCHAR(MAX);
        SET @msg = CONCAT(
            'Error en SP [SP_FI_EditarComprobante]: ',
            ERROR_MESSAGE()
        );

        -- Lanzar mensaje personalizado con nombre del SP
        THROW 51000, @msg, 1;
    END CATCH;
END;
GO
