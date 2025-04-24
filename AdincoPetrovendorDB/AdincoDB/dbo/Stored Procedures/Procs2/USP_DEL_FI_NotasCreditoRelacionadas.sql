IF OBJECT_ID('[dbo].[USP_DEL_FI_NotasCreditoRelacionadas]', 'P') IS NOT NULL
    DROP PROCEDURE [dbo].[USP_DEL_FI_NotasCreditoRelacionadas];
GO

CREATE PROCEDURE [dbo].[USP_DEL_FI_NotasCreditoRelacionadas]
    @IdNotaCredito INT,
    @IdUsuario INT,
    @IdContrato INT,
	@TipoDocumento VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Detalle NVARCHAR(MAX);

        -- Concatenar los registros relacionados con FOR XML PATH
        SELECT @Detalle = 
        ISNULL(@Detalle, '') +
        @TipoDocumento + ' ' + CAST(IdComprobanteRelacionado AS VARCHAR) +
        ', Monto: ' + CAST(Monto AS VARCHAR) + CHAR(13) + CHAR(10)
        FROM FI_NotaCredito_REL_Comprobantes
        WHERE IdNotaCredito = @IdNotaCredito;

        -- Insertar en bitácora si hay detalle
        IF @Detalle IS NOT NULL
        BEGIN
            INSERT INTO AP_Bitacora (Fecha, Tipo, Mensaje, Detalle, UsuarioId, ContratoId)
            VALUES (
                GETDATE(),
                'Eliminación',
                CONCAT('Se eliminaron relaciones de la nota de crédito Id: ', @IdNotaCredito),
                @Detalle,
                @IdUsuario,
                @IdContrato
            );
        END

        -- Eliminar las relaciones
        DELETE FROM FI_NotaCredito_REL_Comprobantes
        WHERE IdNotaCredito = @IdNotaCredito;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @msg NVARCHAR(MAX);
        SET @msg = CONCAT(
            'Error en SP [USP_DEL_FI_NotasCreditoRelacionadas]: ',
            ERROR_MESSAGE()
        );

        -- Lanzar mensaje personalizado con nombre del SP
        THROW 51000, @msg, 1;
    END CATCH
END;
GO
