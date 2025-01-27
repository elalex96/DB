IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_CerrarCapturaPrograma'
    )
    DROP PROCEDURE p_OT_CerrarCapturaPrograma;
GO
CREATE PROC [dbo].[p_OT_CerrarCapturaPrograma]
    @pIdOTSolicitud INT,
    @pSemana        VARCHAR(21),
    @pUsuarioId     INT
AS
    BEGIN
	    CREATE TABLE #tmpSemana (Fecha VARCHAR(10));

        DECLARE
            @fechaIni         DATETIME,
            @fechaFin         DATETIME,
            @usuario          VARCHAR(100),
            @idAux            INT,
            @para             VARCHAR(500),
            @mensaje          VARCHAR(500),
            @pError           VARCHAR(250),
            @descripcionTarea VARCHAR(150);

        SELECT
            @usuario = Usuario
        FROM
            dbo.AP_Usuario (NOLOCK)
        WHERE
            UsuarioID = @pUsuarioId;

        INSERT INTO #tmpSemana
                    SELECT
                        *
                    FROM
                        [dbo].[fnSplitString](@pSemana, '-');
        IF EXISTS
            (
                SELECT
                    1
                FROM
                    #tmpSemana
            )
            BEGIN
                SELECT
                    @fechaIni = MIN(Fecha),
                    @fechaFin = MAX(fecha)
                FROM
                    #tmpSemana;
            END;
        IF EXISTS
            (
                SELECT
                    1
                FROM
                    OT_ProgramaSemanaCerrada (NOLOCK)
                WHERE
                    IdOTSolicitud = @pIdOTSolicitud
                    AND SemanaID = @pSemana
                    AND isActivo = 1
            )
            BEGIN
                RAISERROR(15600, -1, -1, '[ALERTA]: No es posible volver a cerrar la semana');
                RETURN;
            END;

        IF NOT EXISTS
            (
                SELECT
                    1
                FROM
					OT_SolicitudMaterial    sm (NOLOCK)
                JOIN
					OT_SolicitudProgramaCaptura spc (NOLOCK)
                    ON sm.IdOTSolicitudMaterial = spc.IdOTSolicitudMaterial
					AND	sm.IdOTSolicitud = @pIdOTSolicitud
                WHERE
                    sm.IdOTSolicitud = @pIdOTSolicitud
            )
            BEGIN
                RAISERROR(
                             15600, -1, -1,
                             '[ALERTA]: No es posible cerrar la semana, Aún no hay captura de actividades por el Subcontratista'
                         );
                RETURN;
            END;
        BEGIN TRAN;
        IF NOT EXISTS
            (
                SELECT
                    1
                FROM
                    OT_ProgramaSemanaCerrada (NOLOCK)
                WHERE
                    IdOTSolicitud = @pIdOTSolicitud
                    AND SemanaID = @pSemana
            )
            BEGIN
                INSERT INTO OT_ProgramaSemanaCerrada
                    (
                        IdOTSolicitud,
                        SemanaID,
                        FechaSemanaIni,
                        FechaSemanaFin,
                        CreadoPor,
                        CreadoEl,
                        isActivo
                    )
                            SELECT
                                @pIdOTSolicitud,
                                @pSemana,
                                @fechaIni,
                                @fechaFin,
                                @usuario,
                                GETDATE(),
                                1;
            END;
        ELSE
            BEGIN
                UPDATE
                    OT_ProgramaSemanaCerrada
                SET
                    isActivo = 1
                WHERE
                    IdOTSolicitud = @pIdOTSolicitud
                    AND SemanaID = @pSemana;
            END;
        IF @@error <> 0
            BEGIN
                ROLLBACK TRAN;
                GOTO fin;
            END;

        UPDATE
            dbo.OT_SolicitudProgramaCaptura
        SET
            Cerrado = 1,
            FechaCierre = GETDATE(),
            CerradoPor = @pUsuarioId
        FROM
			dbo.OT_SolicitudMaterial sm
        JOIN
             OT_SolicitudProgramaCaptura  SP 
			 ON sm.IdOTSolicitudMaterial = sp.IdOTSolicitudMaterial
			 AND sm.IdOTSolicitud = @pIdOTSolicitud
        WHERE
            CONVERT(VARCHAR, sp.Fecha, 112)
            BETWEEN CONVERT(VARCHAR, @fechaIni, 112) AND CONVERT(VARCHAR, @fechaFin, 112)
            AND sm.IdOTSolicitud = @pIdOTSolicitud;

        IF @@error <> 0
            BEGIN
                ROLLBACK TRAN;
                GOTO fin;
            END;
        --Generar Bitacora  
        SET @descripcionTarea = 'Cierre de semana ' + @pSemana;

        EXEC p_OT_SolicitudBitacora_ins
            @pIdOTSolicitud,
            NULL,
            @descripcionTarea,
            @pUsuarioId,
            NULL;
        IF @@error <> 0
            BEGIN
                ROLLBACK TRAN;
                GOTO fin;
            END;
        /*********Enviar Correo******************************/
        SELECT
            @idAux = ISNULL(MAX(IdNotificacion), 0) + 1
        FROM
            S_Notificacion (NOLOCK);

        SET @para = '';

        SELECT
            @para = @para + ';' + ISNULL(Correo, '')
        FROM
            OT_Solicitud                           ot (NOLOCK)
            JOIN
                SC_Subcontrato                     sc (NOLOCK)
                    ON sc.IdSubcontrato = ot.IdSubcontrato
					AND  ot.IdOTSolicitud = @pIdOTSolicitud
           JOIN
                PV_Subcontratista                  sub (NOLOCK)
                    ON sc.IdSubContratista	=	sub.IdSubContratista
           JOIN
                Petrovendor.dbo.S_Proveedor        pro (NOLOCK)
                    ON  sub.RFC COLLATE SQL_Latin1_General_CP1_CI_AS	=	pro.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
           JOIN
                Petrovendor.dbo.S_UsuarioProveedor up (NOLOCK)
                    ON  pro.IdProveedor	=	up.IdProveedor
           JOIN
                Petrovendor.dbo.S_Usuario          u (NOLOCK)
                    ON up.IdUsuario	=	u.IdUsuario
        WHERE
            ot.IdOTSolicitud = @pIdOTSolicitud;

        COMMIT TRAN;

        EXEC p_OT_CorreoProgramacion_flujo
            @pIdOTSolicitud,
            @pUsuarioId,
            '',
            102;

        /*SEMANA CERRADA*/
        fin:;

    END