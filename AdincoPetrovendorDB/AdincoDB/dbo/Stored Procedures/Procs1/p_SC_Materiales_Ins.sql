IF OBJECT_ID('[dbo].[p_SC_Materiales_Ins]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Materiales_Ins]
GO

CREATE PROCEDURE [dbo].[p_SC_Materiales_Ins]
(
    @pIdSubContrato     INT,
    @pConcepto          VARCHAR(MAX),
    @pIdUnidad          INT,
    @pCantidad          DECIMAL(14,5),
    @pPrecioUnitario    MONEY,
    @pDescripcion       VARCHAR(MAX),
    @pDescripcionCorta  VARCHAR(MAX),
    @pIdUsuario         INT,
    @pError             VARCHAR(250) OUT
)
AS
BEGIN
    DECLARE @pIdSCMaterial INT,
            @idBitacora INT;

    -- Obtener el próximo IdSCMaterial
    SELECT @pIdSCMaterial = ISNULL(MAX(IdSCMaterial), 0) + 1 
    FROM SC_Materiales (NOLOCK);

    BEGIN TRY
        BEGIN TRAN;

        INSERT INTO SC_Materiales 
        (
            IdSCMaterial,
            Concepto,
            IdUnidad,
            Cantidad,
            PrecioUnitario,
            Descripcion,
            DescripcionCorta,
            IdSubContrato,
            IdMaestro,
            Importe,
            CreadoPor,
            CreadoEl
        )
        VALUES
        (
            @pIdSCMaterial,
            @pConcepto,
            @pIdUnidad,
            @pCantidad,
            @pPrecioUnitario,
            @pDescripcion,
            @pDescripcionCorta,
            @pIdSubContrato,
            NULL,
            @pCantidad * @pPrecioUnitario,
            @pIdUsuario,
            GETDATE()
        );

        -- Obtener el próximo IdSCBitacora
        SELECT @idBitacora = ISNULL(MAX(IdSCBitacora), 0) + 1 
        FROM SC_MaterialesBitacora (NOLOCK);

        INSERT INTO SC_MaterialesBitacora
        (
            IdSCBitacora,
            IdSCMaterial,
            CantidadRespaldo,
            FechaRespaldo,
            ModificadoPor,
            Cantidad,
            PrecioUnitario
        )
        SELECT 
            @idBitacora,
            @pIdSCMaterial,
            @pCantidad,
            GETDATE(),
            @pIdUsuario,
            @pCantidad,
            @pPrecioUnitario;

        -- Ejecutar procedimiento para generar materiales
        EXEC [dbo].[p_SC_Materiales_Gen] @pIdSubContrato, '';

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        SET @pError = 'Ocurrió un error inesperado: ' + ERROR_MESSAGE();
    END CATCH;
END
GO
