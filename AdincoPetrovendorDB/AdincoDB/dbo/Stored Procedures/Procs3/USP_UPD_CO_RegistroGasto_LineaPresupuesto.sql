iF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_UPD_CO_RegistroGasto_LineaPresupuesto'
    )
    DROP PROCEDURE USP_UPD_CO_RegistroGasto_LineaPresupuesto;
GO
CREATE PROCEDURE [dbo].[USP_UPD_CO_RegistroGasto_LineaPresupuesto]
    @GastosCsv         NVARCHAR(MAX),
    @IdLineaPresupuesto INT,         
    @Justificacion     NVARCHAR(500),
    @IdUsuario         INT,
    @IdContrato        INT,
   @IdContratoSeleccionado INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF NULLIF(LTRIM(RTRIM(@GastosCsv)), '') IS NULL
        BEGIN
            RAISERROR('No se recibieron gastos a actualizar.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @GastosTemp TABLE (IdRegistro INT NOT NULL PRIMARY KEY);

		INSERT INTO @GastosTemp (IdRegistro)
		SELECT DISTINCT TRY_CONVERT(INT, LTRIM(RTRIM(s.splitdata))) AS IdRegistro
		FROM dbo.fnSplitString(@GastosCsv, ',') s
		WHERE TRY_CONVERT(INT, LTRIM(RTRIM(s.splitdata))) IS NOT NULL;

        IF NOT EXISTS (SELECT 1 FROM @GastosTemp)
        BEGIN
            RAISERROR('No se encontraron gastos válidos en el CSV', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        IF NOT EXISTS (
            SELECT 1
            FROM CO_LineaPresupuestoMes
            WHERE IdLineaPresupuestoMes = @IdLineaPresupuesto
        )
        BEGIN
            RAISERROR('La línea de presupuesto no existe', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @Cambios TABLE
        (
            IdRegistro                  INT NOT NULL,
            IdLineaPresupuestoAnterior  INT NULL,
            IdLineaPresupuestoNuevo     INT NULL
        );

        UPDATE r
        SET r.IdPrograma = @IdLineaPresupuesto
        OUTPUT
            inserted.IdRegistro,
            deleted.IdPrograma,
            inserted.IdPrograma
        INTO @Cambios (IdRegistro, IdLineaPresupuestoAnterior, IdLineaPresupuestoNuevo)
        FROM CO_Registro r
        INNER JOIN @GastosTemp gt ON r.IdRegistro = gt.IdRegistro
        INNER JOIN FI_Factura f ON r.IdFactura = f.IdFactura
        WHERE f.IdContrato = @IdContratoSeleccionado;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('No se actualizaron gastos. Verifique IDs o contrato.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        INSERT INTO dbo.CO_Registro_Bitacora
        (
            IdRegistro,
            CreadoPor,
            Justificacion,
            IdLineaPresupuestoAnterior,
            IdLineaPresupuestoNuevo,
            CreadoEn
        )
        SELECT
            c.IdRegistro,
            @IdUsuario,
            @Justificacion,
            c.IdLineaPresupuestoAnterior,
            c.IdLineaPresupuestoNuevo,
            GETDATE()
        FROM @Cambios c;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END
