IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_AbrirCapturaPrograma'
    )
    DROP PROCEDURE p_OT_AbrirCapturaPrograma;
GO
CREATE PROCEDURE p_OT_AbrirCapturaPrograma 
    @pSemanaID       varchar(50),
    @pIdOTSolicitud  int,
    @pModificadoPor  varchar(50),
    @pMotivoApertura varchar(250),
    @pError          varchar(500) OUT
as
    BEGIN
		CREATE TABLE #CalendarioDiasSemana(IdFecha DATE);

		CREATE TABLE #CalendarioDiasEstimaciones(IdFecha DATE);

        /***********Validar que la semana que se quiere abrir no esté ya en una estimación**************/
        declare
            @fechaInicioSemana        datetime,
            @fechaFinCiclo            datetime,
            @fechaInicioEstimaciones  datetime,
            @fechaFinEstimaciones     datetime,
            @usuarioid                int,
            @descripcionTarea         varchar(150),
            @id                       int,
            @DiasConsideradasEnSemana INT = 0;

        select
            @fechaInicioSemana = min(FechaSemanaIni),
            @fechaFinCiclo     = max(FechaSemanaFin)
        from
            OT_ProgramaSemanaCerrada (NOLOCK)
        where
            idOTSolicitud = @pIdOTSolicitud
            and SemanaID = @pSemanaID
            and isActivo = 1;

        --DIAS DE LA SEMANA INVOLUCRADA

        INSERT INTO #CalendarioDiasSemana
            (
                IdFecha
            )
                    SELECT
                        IdFecha
                    FROM
                        AP_Calendario
                    where
                        IdFecha >= @fechaInicioSemana
                        AND IdFecha <= @fechaFinCiclo;

        --Inicio de las estimaciones generadas de la ot
        select
            @fechaInicioEstimaciones = MIN(FechaCorteInicio),
			@fechaFinEstimaciones = MAX(FechaCorteFin)
        from
            OT_Estimacion (NOLOCK)
        where
            IdOTSolicitud = @pIdOTSolicitud
            and isnull(Cancelada, 0) = 0;

        -- DÍAS ANTERIORES A LA FECHA FIN DE SEMANA QUE PUEDEN ESTAR INVOLUCRADOS EN ALGUNA ESTIMACION DE LA OT
        INSERT INTO #CalendarioDiasEstimaciones
            (
                IdFecha
            )
                    SELECT
                        IdFecha
                    FROM
                        AP_Calendario
                    where
                        IdFecha >= @fechaInicioEstimaciones
                        AND IdFecha <= @fechaFinEstimaciones;

        SELECT
            @DiasConsideradasEnSemana = COUNT(1)
        FROM
            #CalendarioDiasSemana           AS semana
            JOIN
                #CalendarioDiasEstimaciones estimaciones
                    ON semana.IdFecha = estimaciones.IdFecha;

        if (@DiasConsideradasEnSemana > 0)
            begin
                SET @pError ='No es posible abrir la semana, ya se encuentra considerada en una estimación';
                RETURN;
            end


        begin tran

        update
            OT_ProgramaSemanaCerrada
        set
            isActivo = 0,
            ModificadoPor = @pModificadoPor,
            ModificadoEl = getdate(),
            MotivoApertura = @pMotivoApertura
        where
            SemanaID = @pSemanaID
            and IdOTSolicitud = @pIdOTSolicitud

        if @@error <> 0
            begin
                rollback tran
                goto fin
            end

        select
            @id = isnull(max(IdOTProgramaBitacoraSemana), 0) + 1
        from
            [OT_ProgramaBitacoraSemana] (NOLOCK);

        select
            @usuarioid = UsuarioID
        from
            AP_Usuario (NOLOCK)
        where
            Usuario = @pModificadoPor;
        insert into [dbo].[OT_ProgramaBitacoraSemana]
            (
                IdOTProgramaBitacoraSemana,
                IdOTSolicitud,
                SemanaID,
                FechaRegistro,
                Comentarios,
                CreadoPor,
                UsuarioPetrovendorID,
                UsuarioAdincoID,
                TipoUsuario
            )
        values
            (
                @id,
                @pIdOTSolicitud,
                @pSemanaID,
                getdate(),
                'Apertura de semana por motivo de:' + isnull(@pMotivoApertura, ''),
                @pModificadoPor,
                null,
                @usuarioid,
                1
            )

        if @@error <> 0
            begin
                rollback tran
                goto fin
            end

        set @descripcionTarea = 'Reapertura de semana ' + @pSemanaID
        exec p_OT_SolicitudBitacora_ins
            @pIdOTSolicitud,
            null,
            @descripcionTarea,
            @usuarioid,
            null

        if @@error <> 0
            begin
                rollback tran
                goto fin
            end

        commit tran

        exec p_OT_CorreoProgramacion_flujo
            @pIdOTSolicitud,
            @usuarioid,
            '',
            103 /*ABRIR*/

        fin:
		
    END;
