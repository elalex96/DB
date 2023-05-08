-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20191029
-- Description:	Guarda relacion de procesos entregables
-- =============================================

CREATE PROCEDURE [dbo].[sp_EN_GuardaProcesosEntregables]
    @IdContrato INT,
    @IdUsuario INT,
    @IdEntregable INT,
    @IdCatProceso INT,
    @Seleccionado BIT,
	@BitPrincipal BIT
AS
BEGIN

    IF (@Seleccionado = 0)
    BEGIN
        DELETE [dbo].EN_CatalogoProcesosEntregables
        WHERE IdCatProceso = @IdCatProceso
              AND IdEntregable = @IdEntregable;
    END;
    ELSE
    BEGIN
        IF NOT EXISTS
        (
            SELECT 1
            FROM [dbo].EN_CatalogoProcesosEntregables
            WHERE IdCatProceso = @IdCatProceso
                  AND IdEntregable = @IdEntregable
        )
        BEGIN
            INSERT INTO EN_CatalogoProcesosEntregables (IdCatProceso, IdEntregable, CreadoPor, CreadoEn, ModificadoPor,
                                                        ModificadoEn)
            VALUES
            (@IdCatProceso, @IdEntregable, @IdUsuario, GETDATE(), @IdUsuario, GETDATE());
        END;

		UPDATE EN_CatalogoProcesosEntregables SET BitPrincipal=@BitPrincipal WHERE IdEntregable=@IdEntregable AND IdCatProceso=@IdCatProceso;

		IF @@ERROR <> 0
		BEGIN
			SELECT @@ERROR  AS ERROR
		END
		ELSE
		BEGIN
			SELECT '' AS ERROR
        END
    END;
END;

