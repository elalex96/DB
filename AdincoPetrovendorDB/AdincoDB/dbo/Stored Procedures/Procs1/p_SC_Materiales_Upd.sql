IF OBJECT_ID('[dbo].[p_SC_Materiales_Upd]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[p_SC_Materiales_Upd]
GO

CREATE PROCEDURE [dbo].[p_SC_Materiales_Upd]
(
    @pIdSCMaterial      INT,
    @pConcepto          VARCHAR(MAX),
    @pIdUnidad          INT,
    @pCantidad          DECIMAL(14,5),
    @pPrecioUnitario    MONEY,
    @pDescripcion       VARCHAR(MAX),
    @pDescripcionCorta  VARCHAR(MAX),
    @pModificadoPor     INT,
    @pError             VARCHAR(250) OUT
)
AS
BEGIN
    DECLARE @IdSubcontrato INT,
            @idBitacora INT;

    SELECT @IdSubcontrato = IdSubContrato
    FROM SC_Materiales (NOLOCK)
    WHERE IdSCMaterial = @pIdSCMaterial;

    IF EXISTS (
        SELECT 1
        FROM OT_Solicitud (NOLOCK)
        WHERE IdSubcontrato = @IdSubcontrato 
          AND IsActivo = 1 
          AND IDOTEstatus = 9
    )
    BEGIN
        SET @pError = '[ALERTA] Hay CONVENIOS pendientes de aprobar para este contrato, no es posible actualizar esta partida. Es necesario ir a PROCURA a la sección de convenios para subcontratos';         
        RETURN;
    END

    BEGIN TRY
        BEGIN TRAN;

        UPDATE SC_Materiales
        SET     Concepto        =   @pConcepto,
                IdUnidad        =   @pIdUnidad,
                Cantidad        =   @pCantidad,
                PrecioUnitario  =   @pPrecioUnitario,
                Importe         =   @pPrecioUnitario * @pCantidad,
                Descripcion     =   @pDescripcion,
                DescripcionCorta =  @pDescripcionCorta
        WHERE   IdSCMaterial    =   @pIdSCMaterial;

        -- Obtener el proximo IdSCBitacora
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
            @pModificadoPor,
            @pCantidad,
            @pPrecioUnitario;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        SET @pError = 'Ocurrió un error inesperado: ' + ERROR_MESSAGE();
    END CATCH;
END
GO
