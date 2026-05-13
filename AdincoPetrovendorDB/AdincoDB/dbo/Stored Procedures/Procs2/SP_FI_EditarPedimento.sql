IF OBJECT_ID('dbo.SP_FI_EditarPedimento', 'P') IS NOT NULL
    DROP PROCEDURE dbo.SP_FI_EditarPedimento;
GO

CREATE PROCEDURE [dbo].[SP_FI_EditarPedimento]
    @IdPedimentoComprobante     INT,
    @IdContrato                 INT,
    @NumeroPedimento            VARCHAR(5000),
    @ClavePedimento             INT,
    @FolioComprobante           VARCHAR(5000),
    @FechaPago                  DATE,
    @Regimen                    VARCHAR(5000),
    @AduanaES                   VARCHAR(5000),
    @IdSubcontratistaExportador INT,
    @IdMoneda                   INT,
    @AcuseElectronico           VARCHAR(5000),
    @DescripcionMercancia       VARCHAR(5000),
    @SubTotal                   MONEY,
    @IdUsuario                  INT,
    @CvTipoDoc                  INT,
    @DocumentoPDF               VARCHAR(100), -- texto como "Cargado" o vacío
    @IdFiscal                   VARCHAR(50),
    @RazonSocial                VARCHAR(5000),
    @ImporteInco                MONEY,
    @CuentaBancaria             VARCHAR(500) = '',
    @EsNotaCredito              BIT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IdSubcontratistaImportador INT;
    DECLARE @HayPDF BIT = CASE WHEN ISNULL(@DocumentoPDF, '') <> '' THEN 1 ELSE 0 END;

    BEGIN TRY
        BEGIN TRAN;

        -- Obtener proveedor importador
        SELECT @IdSubcontratistaImportador = C.IdProveedor
        FROM CO_Contrato CT WITH(NOLOCK)
        JOIN CO_Contratista C WITH(NOLOCK) ON CT.IdContratista = C.IdContratista
        WHERE CT.IdContrato = @IdContrato;


        -- Actualizar cabecera
        UPDATE dbo.FI_PedimentoComprobante
        SET
            NumeroPedimento = @NumeroPedimento,
            ClavePedimento = @ClavePedimento,
            FolioComprobante = @FolioComprobante,
            FechaPago = @FechaPago,
            Regimen = @Regimen,
            IdSubcontratistaImportador = @IdSubcontratistaImportador,
            AduanaES = @AduanaES,
            IdSubcontratistaExportador = @IdSubcontratistaExportador,
            IdMoneda = @IdMoneda,
            AcuseElectronico = @AcuseElectronico,
            CvTipoDocFacturacion = @CvTipoDoc,
            ModificadoPor = @IdUsuario,
            ModificadoEn = GETDATE(),
            IdFiscalP = @IdFiscal,
            RazonSocialP = @RazonSocial,
            CuentaBancaria = @CuentaBancaria,
            EsNotaCredito = @EsNotaCredito
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante;

        -- Actualizar detalle
        UPDATE dbo.FI_PedimentoComprobanteDetalle
        SET
            DescripcionMercancia = @DescripcionMercancia,
            PrecioUnitario = @SubTotal,
            ModificadoPor = @IdUsuario,
            ModificadoEn = GETDATE(),
            ImporteTotal = @ImporteInco
        WHERE IdPedimentoComprobante = @IdPedimentoComprobante;

        -- Actualizar documento si viene archivo nuevo
        IF @HayPDF = 1
        BEGIN
            UPDATE dbo.FI_Documento
            SET
                ModificadoPor = @IdUsuario,
                ModificadoEn = GETDATE()
            WHERE IdPedimentoComprobante = @IdPedimentoComprobante;
        END

        COMMIT;
        SELECT 'true' AS msj, @IdPedimentoComprobante;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @msg NVARCHAR(MAX);
        SET @msg = CONCAT(
            'Error en SP [SP_FI_EditarPedimento]: ',
            ERROR_MESSAGE()
        );

        -- Lanzar mensaje personalizado con nombre del SP
        THROW 51000, @msg, 1;
    END CATCH
END;
GO
