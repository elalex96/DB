IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_UPD_CO_ActualizarPresupuestoConBitacora'
)
    DROP PROCEDURE USP_UPD_CO_ActualizarPresupuestoConBitacora;
GO

CREATE PROCEDURE USP_UPD_CO_ActualizarPresupuestoConBitacora
    @Table_CO_Type_Pressupuesto CO_Type_Pressupuesto READONLY,
    @ContratoId INT,
    @UsuarioId INT
AS
BEGIN
    BEGIN TRY
        BEGIN TRAN

        SET NOCOUNT ON;

        DECLARE @ErrorMessage VARCHAR(4000),
                @FechaHoy DATETIME = GETDATE(),
                @CuentaPresupuestoCNH INT = 0,
                @ContratoIdSeleccionado INT = 0,
                @IdPresupuestoCNH VARCHAR(500) = '',
                @IdPresupuesto INT = 0,
                @DetalleBitacora VARCHAR(4000) = '';

        CREATE TABLE #Temporal_Presupuesto
        (
            IdPresupuesto INT NULL,
            Nombre VARCHAR(500) NULL,
            IdPresupuestoCNH VARCHAR(500) NULL,
            Actual BIT NULL,
            ActivoProcura BIT NULL,
            InicioPresupuesto DATE NULL,
            FinPresupuesto DATE NULL,
            IdContratoSeleccionado INT NULL
        );

        CREATE TABLE #Temporal_PresupuestoNoEditado
        (
            IdPresupuesto INT NULL,
            Nombre VARCHAR(500) NULL,
            IdPresupuestoCNH VARCHAR(500) NULL,
            Actual BIT NULL,
            ActivoProcura BIT NULL,
            InicioPresupuesto DATE NULL,
            FinPresupuesto DATE NULL
        );

        CREATE TABLE #Temporal_PresupuestoDelContrato
        (
            [IdPresupuesto] INT NULL,
            [IdPresupuestoCNH] VARCHAR(100) NULL
        );

        INSERT INTO #Temporal_Presupuesto
        (
            IdPresupuesto,
            Nombre,
            IdPresupuestoCNH,
            Actual,
            ActivoProcura,
            InicioPresupuesto,
            FinPresupuesto,
            IdContratoSeleccionado
        )
        SELECT TOP 1
            IdPresupuesto,
            LTRIM(RTRIM(ISNULL(Nombre, ''))),
            LTRIM(RTRIM(ISNULL(IdPresupuestoCNH, ''))),
            ISNULL(Actual, 0),
            ISNULL(ActivoProcura, 0),
            InicioPresupuesto,
            FinPresupuesto,
            IdContratoSeleccionado
        FROM @Table_CO_Type_Pressupuesto;

        SELECT TOP 1
            @IdPresupuesto = IdPresupuesto,
            @ContratoIdSeleccionado = IdContratoSeleccionado,
            @IdPresupuestoCNH = LTRIM(RTRIM(ISNULL(IdPresupuestoCNH, '')))
        FROM #Temporal_Presupuesto;

        INSERT INTO #Temporal_PresupuestoNoEditado
        (
            IdPresupuesto,
            Nombre,
            IdPresupuestoCNH,
            Actual,
            ActivoProcura,
            InicioPresupuesto,
            FinPresupuesto
        )
        SELECT TOP 1
            IdPresupuesto,
            LTRIM(RTRIM(ISNULL(Nombre, ''))),
            LTRIM(RTRIM(ISNULL(IdPresupuestoCNH, ''))),
            ISNULL(Actual, 0),
            ISNULL(ActivoProcura, 0),
            InicioPresupuesto,
            FinPresupuesto
        FROM CO_Presupuesto (NOLOCK)
        WHERE IdPresupuesto = @IdPresupuesto;

        INSERT INTO #Temporal_PresupuestoDelContrato
        (
            IdPresupuesto,
            IdPresupuestoCNH
        )
        SELECT CO_Presupuesto.IdPresupuesto,
               ISNULL(CO_Presupuesto.IdPresupuestoCNH, '')
        FROM CO_PeriodoContrato (NOLOCK)
            JOIN CO_ProgramaActividad (NOLOCK)
                ON CO_PeriodoContrato.IdContrato = @ContratoIdSeleccionado
                   AND CO_PeriodoContrato.IdPeriodo = CO_ProgramaActividad.IdPeriodoContrato
            JOIN CO_Presupuesto (NOLOCK)
                ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
                   AND LTRIM(RTRIM(ISNULL(CO_Presupuesto.IdPresupuestoCNH, ''))) = LTRIM(RTRIM(ISNULL(
                                                                                                         @IdPresupuestoCNH,
                                                                                                         ''
                                                                                                     )
                                                                                              )
                                                                                        )
                   AND CO_Presupuesto.IdPresupuesto <> @IdPresupuesto;

        IF NOT EXISTS
        (
            SELECT TOP 1
                IdPresupuesto
            FROM CO_Presupuesto (NOLOCK)
            WHERE CO_Presupuesto.IdPresupuesto = @IdPresupuesto
                  AND LTRIM(RTRIM(ISNULL(CO_Presupuesto.IdPresupuestoCNH, ''))) = LTRIM(RTRIM(ISNULL(
                                                                                                        @IdPresupuestoCNH,
                                                                                                        ''
                                                                                                    )
                                                                                             )
                                                                                       )
        )
        BEGIN
            SELECT @CuentaPresupuestoCNH = COUNT(1)
            FROM #Temporal_PresupuestoDelContrato
            WHERE IdPresupuestoCNH <> ''
                  AND IdPresupuestoCNH <> 'FALTA ID'
        END;

        IF (@CuentaPresupuestoCNH = 0)
        BEGIN
            SELECT TOP 1
                @DetalleBitacora
                    = CONCAT(
                                @DetalleBitacora,
                                ' IdPresupuestoCNH: Antes [',
                                #Temporal_PresupuestoNoEditado.IdPresupuestoCNH,
                                '], Despues [',
                                #Temporal_Presupuesto.IdPresupuestoCNH,
                                ']'
                            )
            FROM #Temporal_Presupuesto
                JOIN #Temporal_PresupuestoNoEditado
                    ON #Temporal_Presupuesto.IdPresupuesto = #Temporal_PresupuestoNoEditado.IdPresupuesto
                       AND #Temporal_Presupuesto.IdPresupuestoCNH <> #Temporal_PresupuestoNoEditado.IdPresupuestoCNH;

            SELECT TOP 1
                @DetalleBitacora
                    = CONCAT(
                                @DetalleBitacora,
                                ' Nombre: Antes [',
                                #Temporal_PresupuestoNoEditado.Nombre,
                                '], Despues [',
                                #Temporal_Presupuesto.Nombre,
                                ']'
                            )
            FROM #Temporal_Presupuesto
                JOIN #Temporal_PresupuestoNoEditado
                    ON #Temporal_Presupuesto.IdPresupuesto = #Temporal_PresupuestoNoEditado.IdPresupuesto
                       AND #Temporal_Presupuesto.Nombre <> #Temporal_PresupuestoNoEditado.Nombre;

            SELECT TOP 1
                @DetalleBitacora
                    = CONCAT(
                                @DetalleBitacora,
                                ' Actual: Antes [',
                                CASE
                                    WHEN #Temporal_PresupuestoNoEditado.Actual = 0 THEN
                                        'Inactivo'
                                    ELSE
                                        'Activo'
                                END,
                                '], Despues [',
                                CASE
                                    WHEN #Temporal_Presupuesto.Actual = 0 THEN
                                        'Inactivo'
                                    ELSE
                                        'Activo'
                                END,
                                ']'
                            )
            FROM #Temporal_Presupuesto
                JOIN #Temporal_PresupuestoNoEditado
                    ON #Temporal_Presupuesto.IdPresupuesto = #Temporal_PresupuestoNoEditado.IdPresupuesto
                       AND #Temporal_Presupuesto.Actual <> #Temporal_PresupuestoNoEditado.Actual;

            SELECT TOP 1
                @DetalleBitacora
                    = CONCAT(
                                @DetalleBitacora,
                                ' ActivoProcura: Antes [',
                                CASE
                                    WHEN #Temporal_PresupuestoNoEditado.ActivoProcura = 0 THEN
                                        'Inactivo'
                                    ELSE
                                        'Activo'
                                END,
                                '], Despues [',
                                CASE
                                    WHEN #Temporal_Presupuesto.ActivoProcura = 0 THEN
                                        'Inactivo'
                                    ELSE
                                        'Activo'
                                END,
                                ']'
                            )
            FROM #Temporal_Presupuesto
                JOIN #Temporal_PresupuestoNoEditado
                    ON #Temporal_Presupuesto.IdPresupuesto = #Temporal_PresupuestoNoEditado.IdPresupuesto
                       AND #Temporal_Presupuesto.ActivoProcura <> #Temporal_PresupuestoNoEditado.ActivoProcura;

            SELECT TOP 1
                @DetalleBitacora
                    = CONCAT(
                                @DetalleBitacora,
                                ' InicioPresupuesto: Antes [',
                                CASE
                                    WHEN #Temporal_PresupuestoNoEditado.InicioPresupuesto IS NULL THEN
                                        'Sin Fecha'
                                    ELSE
                                        FORMAT(#Temporal_PresupuestoNoEditado.InicioPresupuesto, 'dd/MM/yyyy')
                                END,
                                '], Despues [',
                                CASE
                                    WHEN #Temporal_Presupuesto.InicioPresupuesto IS NULL THEN
                                        'Inactivo'
                                    ELSE
                                        FORMAT(#Temporal_Presupuesto.InicioPresupuesto, 'dd/MM/yyyy')
                                END,
                                ']'
                            )
            FROM #Temporal_Presupuesto
                JOIN #Temporal_PresupuestoNoEditado
                    ON #Temporal_Presupuesto.IdPresupuesto = #Temporal_PresupuestoNoEditado.IdPresupuesto
                       AND #Temporal_Presupuesto.InicioPresupuesto <> #Temporal_PresupuestoNoEditado.InicioPresupuesto;

            SELECT TOP 1
                @DetalleBitacora
                    = CONCAT(
                                @DetalleBitacora,
                                ' FinPresupuesto: Antes [',
                                CASE
                                    WHEN #Temporal_PresupuestoNoEditado.FinPresupuesto IS NULL THEN
                                        'Sin Fecha'
                                    ELSE
                                        FORMAT(#Temporal_PresupuestoNoEditado.FinPresupuesto, 'dd/MM/yyyy')
                                END,
                                '], Despues [',
                                CASE
                                    WHEN #Temporal_Presupuesto.FinPresupuesto IS NULL THEN
                                        'Inactivo'
                                    ELSE
                                        FORMAT(#Temporal_Presupuesto.FinPresupuesto, 'dd/MM/yyyy')
                                END,
                                ']'
                            )
            FROM #Temporal_Presupuesto
                JOIN #Temporal_PresupuestoNoEditado
                    ON #Temporal_Presupuesto.IdPresupuesto = #Temporal_PresupuestoNoEditado.IdPresupuesto
                       AND #Temporal_Presupuesto.FinPresupuesto <> #Temporal_PresupuestoNoEditado.FinPresupuesto;

            IF (@DetalleBitacora <> '')
            BEGIN
                UPDATE dbo.CO_Presupuesto
                SET CO_Presupuesto.IdPresupuestoCNH = LTRIM(RTRIM(ISNULL(#Temporal_Presupuesto.IdPresupuestoCNH, ''))),
                    CO_Presupuesto.Nombre = LTRIM(RTRIM(ISNULL(#Temporal_Presupuesto.Nombre, ''))),
                    CO_Presupuesto.Actual = ISNULL(#Temporal_Presupuesto.Actual, 0),
                    CO_Presupuesto.ActivoProcura = ISNULL(#Temporal_Presupuesto.ActivoProcura, 0),
                    CO_Presupuesto.InicioPresupuesto = #Temporal_Presupuesto.InicioPresupuesto,
                    CO_Presupuesto.FinPresupuesto = #Temporal_Presupuesto.FinPresupuesto,
                    CO_Presupuesto.ModificadoPor = @UsuarioId,
                    CO_Presupuesto.ModificadoEl = @FechaHoy
                FROM #Temporal_Presupuesto
                    JOIN CO_Presupuesto
                        ON #Temporal_Presupuesto.IdPresupuesto = CO_Presupuesto.IdPresupuesto;

                INSERT INTO AP_Bitacora
                (
                    [Fecha],
                    [Tipo],
                    [Mensaje],
                    [Detalle],
                    [UsuarioId],
                    [ContratoId]
                )
                VALUES
                (@FechaHoy,
                 'Edición',
                 'Edición de Valores de CO_Presupuesto en la página AdministrarPresupuesto.aspx',
                 CONCAT(
                           'Del contrato con id: ',
                           CONVERT(VARCHAR(10), @ContratoIdSeleccionado),
                           ' - ',
                           ' y del Presupuesto con id: ',
                           CONVERT(VARCHAR(10), @IdPresupuesto),
                           ' -',
                           @DetalleBitacora
                       ),
                 @UsuarioId,
                 @ContratoId
                );
            END;

            SELECT 'CORRECTO';
        END
        ELSE
        BEGIN
            SELECT 'ALERTAIDPRESUPUESTOCNH';
        END;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        SELECT @ErrorMessage = CONCAT('Error: USP_UPD_CO_ActualizarPresupuestoConBitacora - ', ERROR_MESSAGE());

        ROLLBACK TRAN;

        RAISERROR(@ErrorMessage, 17, 1);
    END CATCH;
END;