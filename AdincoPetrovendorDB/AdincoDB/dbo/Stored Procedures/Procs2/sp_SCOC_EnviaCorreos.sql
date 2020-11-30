-- =============================================
-- Author:		Reynha Olvera
-- Create date:20180927
-- Description:	<Description,,>
--SELECT * FROM dbo.SCOC_EnvioNotificacion
-- =============================================

CREATE PROCEDURE [dbo].[sp_SCOC_EnviaCorreos] --10010,'20181201',10,'https://pemex.adinco/001/AprobacionCalculo.aspx?mes=MDEvMTEvMjAxOCAxMjowMDowMCBhLiBtLg==&contrato=MTAwNDA=',11,'NO APTO'
    @idContrato INT,
    @MesReporte DATE,
    @idUsuario INT,
    @URL NVARCHAR(MAX),
    @TipoCorreoEnviar INT,
    @ComentDesdeAprobacion NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;
    DECLARE @Usuario NVARCHAR(MAX),
            @correoU NVARCHAR(300)='',
            @UsuarioPEP NVARCHAR(MAX),
            @correoUPEP NVARCHAR(300)='',
            @contrato NVARCHAR(MAX),
            @FechaName NVARCHAR(MAX),
            @CountUsuariosSCOC INT,
            @Correo NVARCHAR(MAX),
            @CorreoPEP NVARCHAR(MAX),
            @UsuarioSCOC NVARCHAR(MAX),
            @FechaAprobacionSCOC NVARCHAR(MAX),
            @Comentarios NVARCHAR(MAX),
            @FechaReinicioProceso NVARCHAR(MAX);

    IF OBJECT_ID('#TemporalUsuarios') IS NOT NULL
        DROP TABLE #TemporalUsuarios;
    CREATE TABLE #TemporalUsuarios
    (
        id INT IDENTITY(1, 1),
        contrato INT,
        Nombre VARCHAR(150),
        Usuario NVARCHAR(150)
    );
    IF OBJECT_ID('#TemporalDatosCorreo') IS NOT NULL
        DROP TABLE #TemporalDatosCorreo;
    CREATE TABLE #TemporalDatosCorreo
    (
        NumeroContrato NVARCHAR(MAX),
        id INT,
        contrato INT,
        Nombre VARCHAR(150),
        Usuario NVARCHAR(150),
        FechaName NVARCHAR(100),
        Descripcion NVARCHAR(MAX),
    );



    --------------------------------------------PEP-------------------------------------
    IF (@TipoCorreoEnviar = 0) --Para que Apruebe PEP
    BEGIN
        IF OBJECT_ID('#TemporalUsuariosP') IS NOT NULL
            DROP TABLE #TemporalUsuarios;
        CREATE TABLE #TemporalUsuariosP
        (
            id INT IDENTITY(1, 1),
            contrato INT,
            Nombre VARCHAR(150),
            Usuario NVARCHAR(150)
        );
        INSERT INTO #TemporalUsuariosP
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso = 8
              AND BitActivo = 1;
        IF OBJECT_ID('#TemporalDatosCorreoP') IS NOT NULL
            DROP TABLE #TemporalDatosCorreoP;
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Calculo Volumenes' AS Descripcion
        INTO #TemporalDatosCorreoP
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuariosP t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;


        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Aprobación Representante PEP Calculo de Volumenes',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(HTML, '##NOMBRE_USUARIO##', tc.Nombre),
                                             '##CONTRATO##',
                                             tc.NumeroContrato
                                         ),
                                  '##MES##',
                                  tc.FechaName
                              ),
                       '##ENLACE_DETALLE##',
                       @URL
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreoP tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Calculo Volumenes';
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'ENVIADO A APROBACIÓN PEP',
                                                      '',
                                                      @idUsuario;

    END;
    IF (@TipoCorreoEnviar = 5) --RechazadoPEP 
    BEGIN
        SELECT @Usuario = Nombre --Envio a aprobar el calculo  --CONTRATISTA
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;

        ---------------------------PARA*******CONTRATISTA-----------------------------
        SELECT @correoU = ISNULL(Usuario, '') --Envio a aprobar el calculo  --CONTRATISTA
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        ------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;
        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);
        SELECT @UsuarioSCOC = Nombre
        FROM dbo.AP_Usuario
        WHERE UsuarioID = @idUsuario;
        SELECT @FechaAprobacionSCOC
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()));
        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(
                                                                     REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                                     '##CONTRATO##',
                                                                     @contrato
                                                                 ),
                                                          '##MES##',
                                                          @FechaName
                                                      ),
                                               '#FECHAAPROBACION#',
                                               @FechaAprobacionSCOC
                                           ),
                                    '##USUARIOSCOC##',
                                    @UsuarioSCOC
                                ),
                         '##COMENTARIO##',
                         @ComentDesdeAprobacion
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Rechazo Calculo de Volumenes';
        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                               -- IdNotificacion - bigint
                @correoU,                                                        -- Para - varchar(500)
                'Estatus Rechazo de Calculo de Volumenes por Representante PEP', -- Asunto - varchar(250)
                @Correo,                                                         -- Mensaje - text
                GETDATE(),                                                       -- FechaProgramadaEnvio - datetime
                0,                                                               -- Enviada - bit
                NULL,                                                            -- FechaEnvio - datetime
                @idUsuario,                                                      -- CreadoPor - int
                GETDATE(),                                                       -- CreadoEl - datetime
                @idUsuario,                                                      -- ModificadoPor - int
                GETDATE(),                                                       -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                                      -- De - varchar(100)
                0                                                                -- EN_MsjEnviado - bit
                );
        END;
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'RECHAZADO POR USUARIO PEP',
                                                      @ComentDesdeAprobacion,
                                                      @idUsuario;
    END;
    IF (@TipoCorreoEnviar = 12) --APROBADO PEP (LICENCIA) APROBACIONES ACOMPLETADAS
    BEGIN
        SELECT @Usuario = Nombre --Envio a aprobar el calculo --CONTRATISTA
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------***PARA*****----------------------------------
        SELECT @correoU = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        --------------------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;

        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);

        ----------------------------------Para Usuario PEP sepa que volvera a empezar el ciclo y volvera a aprobar-------------------------------------------------
        SELECT @UsuarioPEP = Nombre -- USUARIO PEP
        FROM dbo.AP_Usuario
        WHERE UsuarioID = @idUsuario;
        -------------------------------
        SELECT @correoUPEP = ISNULL(Usuario, '')
        FROM dbo.AP_Usuario
        WHERE UsuarioID = @idUsuario;
        -----------------------------------------------------------------------------------

        SELECT @FechaAprobacionSCOC
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()));
        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAAPROBACION#',
                                    @FechaAprobacionSCOC
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioPEP
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Calculo de volumenes';
        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                        -- IdNotificacion - bigint
                @correoU,                                                 -- Para - varchar(500)
                'Estatus Calculo de volumenes, Aprobado por usuario PEP', -- Asunto - varchar(250)
                @Correo,                                                  -- Mensaje - text
                GETDATE(),                                                -- FechaProgramadaEnvio - datetime
                0,                                                        -- Enviada - bit
                NULL,                                                     -- FechaEnvio - datetime
                @idUsuario,                                               -- CreadoPor - int
                GETDATE(),                                                -- CreadoEl - datetime
                @idUsuario,                                               -- ModificadoPor - int
                GETDATE(),                                                -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                               -- De - varchar(100)
                0                                                         -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------

        INSERT INTO #TemporalUsuarios
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso = 6
              AND BitActivo = 1;
        INSERT INTO #TemporalDatosCorreo
        (
            NumeroContrato,
            id,
            contrato,
            Nombre,
            Usuario,
            FechaName,
            Descripcion
        )
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Calculo Volumenes' AS Descripcion
        --INTO
        --        #TemporalDatosCorreo
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuarios t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;

        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Visualizar calculo de volumenes aprobado',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(HTML, '##NOMBRE_USUARIO##', tc.Nombre),
                                             '##CONTRATO##',
                                             tc.NumeroContrato
                                         ),
                                  '##MES##',
                                  tc.FechaName
                              ),
                       '##ENLACE_DETALLE##',
                       @URL
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreo tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Calculo Volumenes';
        ----------------------------------------------------------------------
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'APROBADO POR USUARIO PEP (APROBACIONES COMPLETAS)',
                                                      '',
                                                      @idUsuario;
    END;
    IF (@TipoCorreoEnviar = 13) --APROBADO PEP NOTIFICACIÓN A CONTRATISTA (PC)
    BEGIN
        SELECT @Usuario = Nombre --Envio a aprobar el calculo --CONTRATISTA
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------***PARA*****----------------------------------
        SELECT @correoU = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;
        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);
        ----------------------------------Para Usuario PEP sepa que volvera a empezar el ciclo y volvera a aprobar-------------------------------------------------
        SELECT @UsuarioPEP = Nombre -- USUARIO PEP
        FROM dbo.AP_Usuario
        WHERE UsuarioID = @idUsuario;
        SELECT @correoUPEP = ISNULL(Usuario, '')
        FROM dbo.AP_Usuario
        WHERE UsuarioID = @idUsuario;
        -----------------------------------------------------------------------------------
        SELECT @FechaAprobacionSCOC
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()));
        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAAPROBACION#',
                                    @FechaAprobacionSCOC
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioPEP
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Calculo de volumenes';

        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                        -- IdNotificacion - bigint
                @correoU,                                                 -- Para - varchar(500)
                'Estatus Calculo de volumenes, Aprobado por usuario PEP', -- Asunto - varchar(250)
                @Correo,                                                  -- Mensaje - text
                GETDATE(),                                                -- FechaProgramadaEnvio - datetime
                0,                                                        -- Enviada - bit
                NULL,                                                     -- FechaEnvio - datetime
                @idUsuario,                                               -- CreadoPor - int
                GETDATE(),                                                -- CreadoEl - datetime
                @idUsuario,                                               -- ModificadoPor - int
                GETDATE(),                                                -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                               -- De - varchar(100)
                0                                                         -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'APROBADO POR USUARIO PEP (CONTINUA CON COMERCIALIZADOR LIQUIDOS)',
                                                      '',
                                                      @idUsuario;
    END;
    --------------------------------------------SCOC-------------------------------------
    IF (@TipoCorreoEnviar = 1) --Para que Apruebe SCOC
    BEGIN
        INSERT INTO #TemporalUsuarios
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso = 6
              AND BitActivo = 1;

        INSERT INTO #TemporalDatosCorreo
        (
            NumeroContrato,
            id,
            contrato,
            Nombre,
            Usuario,
            FechaName,
            Descripcion
        )
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Calculo Volumenes' AS Descripcion
        -- INTO #TemporalDatosCorreo
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuarios t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;
        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Aprobación Calculo de Volumenes Usuario SCOC',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(HTML, '##NOMBRE_USUARIO##', tc.Nombre),
                                             '##CONTRATO##',
                                             tc.NumeroContrato
                                         ),
                                  '##MES##',
                                  tc.FechaName
                              ),
                       '##ENLACE_DETALLE##',
                       @URL
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreo tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Calculo Volumenes';
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'ENVIADO A APROBACIÓN SCOC',
                                                      '',
                                                      @idUsuario;
    END;
    IF (@TipoCorreoEnviar = 2) --AprobadoSCOC
    BEGIN
        SELECT @Usuario = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------***PARA*****----------------------------------

        SELECT @correoU = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        ------------------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;
        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);
        ----------------------------------Para Usuario PEP sepa que volvera a empezar el ciclo y volvera a aprobar-------------------------------------------------
        SELECT @UsuarioPEP = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------***PARA*****----------------------------------
        SELECT @correoUPEP = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------
        SELECT @UsuarioSCOC = Nombre
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoSCOC
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;

        SELECT @FechaAprobacionSCOC
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()));
        SELECT @Comentarios = Comentarios
        FROM SCOC_EnvioNotificacion
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;

        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAAPROBACION#',
                                    @FechaAprobacionSCOC
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioSCOC
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Calculo de volumenes';
        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                        -- IdNotificacion - bigint
                @correoU,                                                 -- Para - varchar(500)
                'Estatus aprobado por usuario SCOC calculo de volumenes', -- Asunto - varchar(250)
                @Correo,                                                  -- Mensaje - text
                GETDATE(),                                                -- FechaProgramadaEnvio - datetime
                0,                                                        -- Enviada - bit
                NULL,                                                     -- FechaEnvio - datetime
                @idUsuario,                                               -- CreadoPor - int
                GETDATE(),                                                -- CreadoEl - datetime
                @idUsuario,                                               -- ModificadoPor - int
                GETDATE(),                                                -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                               -- De - varchar(100)
                0                                                         -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        --Para  PEP
        SELECT @CorreoPEP
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @UsuarioPEP),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAAPROBACION#',
                                    @FechaAprobacionSCOC
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioSCOC
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Calculo de volumenes';
        IF (@correoUPEP <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                        -- IdNotificacion - bigint
                @correoUPEP,                                              -- Para - varchar(500)--*************************************
                'Estatus aprobado por usuario SCOC calculo de volumenes', -- Asunto - varchar(250)
                @CorreoPEP,                                               -- Mensaje - text
                GETDATE(),                                                -- FechaProgramadaEnvio - datetime
                0,                                                        -- Enviada - bit
                NULL,                                                     -- FechaEnvio - datetime
                @idUsuario,                                               -- CreadoPor - int
                GETDATE(),                                                -- CreadoEl - datetime
                @idUsuario,                                               -- ModificadoPor - int
                GETDATE(),                                                -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                               -- De - varchar(100)
                0                                                         -- EN_MsjEnviado - bit
                );
        END;
        --------------------------------------------------------------------------------
        ----------------------------------------------------------------------
        ----Para comercializadores de liq and comercializadores de gas
        INSERT INTO #TemporalUsuarios
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso IN ( 9, 10 )
              AND BitActivo = 1;

        INSERT INTO #TemporalDatosCorreo
        (
            NumeroContrato,
            id,
            contrato,
            Nombre,
            Usuario,
            FechaName,
            Descripcion
        )
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Estatus Calculo de volumenes' AS Descripcion
        --INTO
        --        #TemporalDatosCorreo
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuarios t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;
        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Estatus aprobado por usuario SCOC calculo de volumenes',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(HTML, '##NOMBRE_USUARIO##', Nombre),
                                                                   '##CONTRATO##',
                                                                   @contrato
                                                               ),
                                                        '##MES##',
                                                        @FechaName
                                                    ),
                                             '#FECHAAPROBACION#',
                                             @FechaAprobacionSCOC
                                         ),
                                  '##USUARIOSCOC##',
                                  @UsuarioSCOC
                              ),
                       '##COMENTARIO##',
                       @ComentDesdeAprobacion
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreo tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Estatus Calculo de volumenes';

        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'APROBADO POR USUARIO SCOC',
                                                      '',
                                                      @idUsuario;
    END;
    IF (@TipoCorreoEnviar = 3) --RechazadoSCOC  ---Envviar al todos tambnien para que sepa que Volvera a aprobar
    BEGIN
        --------------------------------Para Contratista---------------------------------------------------
        SELECT @Usuario = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;

        ---------------------------------------PARA************************************

        SELECT @correoU = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------
        ----------------------------------Para Usuario PEP sepa que volvera a empezar el ciclo y volvera a aprobar-------------------------------------------------
        SELECT @UsuarioPEP = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;

        ---------------------------------------PARA************************************
        SELECT @correoUPEP = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;
        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);
        SELECT @UsuarioSCOC = Nombre
        FROM dbo.AP_Usuario
        WHERE UsuarioID = @idUsuario;
        SELECT @FechaAprobacionSCOC
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()));

        ----------------------------------------------------------------------
        --Para Contratista
        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(
                                                                     REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                                     '##CONTRATO##',
                                                                     @contrato
                                                                 ),
                                                          '##MES##',
                                                          @FechaName
                                                      ),
                                               '#FECHAAPROBACION#',
                                               @FechaAprobacionSCOC
                                           ),
                                    '##USUARIOSCOC##',
                                    @UsuarioSCOC
                                ),
                         '##COMENTARIO##',
                         @ComentDesdeAprobacion
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Rechazo Calculo de Volumenes';
        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                      -- IdNotificacion - bigint
                @correoU,                               -- Para - varchar(500)
                'Estatus Rechazo Calculo de Volumenes', -- Asunto - varchar(250)
                @Correo,                                -- Mensaje - text
                GETDATE(),                              -- FechaProgramadaEnvio - datetime
                0,                                      -- Enviada - bit
                NULL,                                   -- FechaEnvio - datetime
                @idUsuario,                             -- CreadoPor - int
                GETDATE(),                              -- CreadoEl - datetime
                @idUsuario,                             -- ModificadoPor - int
                GETDATE(),                              -- ModificadoEl - datetime
                'notificaciones@adinco.mx',             -- De - varchar(100)
                0                                       -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        --Para  PEP
        SELECT @CorreoPEP
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(
                                                                     REPLACE(HTML, '##NOMBRE_USUARIO##', @UsuarioPEP),
                                                                     '##CONTRATO##',
                                                                     @contrato
                                                                 ),
                                                          '##MES##',
                                                          @FechaName
                                                      ),
                                               '#FECHAAPROBACION#',
                                               @FechaAprobacionSCOC
                                           ),
                                    '##USUARIOSCOC##',
                                    @UsuarioSCOC
                                ),
                         '##COMENTARIO##',
                         @ComentDesdeAprobacion
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Rechazo Calculo de Volumenes';

        IF (@correoUPEP <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                      -- IdNotificacion - bigint
                @correoUPEP,                            -- Para - varchar(500)
                'Estatus Rechazo Calculo de Volumenes', -- Asunto - varchar(250)
                @CorreoPEP,                             -- Mensaje - text
                GETDATE(),                              -- FechaProgramadaEnvio - datetime
                0,                                      -- Enviada - bit
                NULL,                                   -- FechaEnvio - datetime
                @idUsuario,                             -- CreadoPor - int
                GETDATE(),                              -- CreadoEl - datetime
                @idUsuario,                             -- ModificadoPor - int
                GETDATE(),                              -- ModificadoEl - datetime
                'notificaciones@adinco.mx',             -- De - varchar(100)
                0                                       -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        ----Para comercializadores de liq and comercializadores de gas
        INSERT INTO #TemporalUsuarios
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso IN ( 9, 10 )
              AND BitActivo = 1;

        INSERT INTO #TemporalDatosCorreo
        (
            NumeroContrato,
            id,
            contrato,
            Nombre,
            Usuario,
            FechaName,
            Descripcion
        )
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Estatus Rechazo Calculo de Volumenes' AS Descripcion
        --INTO
        --        #TemporalDatosCorreo
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuarios t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;
        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Estatus Rechazo Calculo de Volumenes SCOC',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(HTML, '##NOMBRE_USUARIO##', tc.Nombre),
                                                                   '##CONTRATO##',
                                                                   @contrato
                                                               ),
                                                        '##MES##',
                                                        @FechaName
                                                    ),
                                             '#FECHAAPROBACION#',
                                             @FechaAprobacionSCOC
                                         ),
                                  '##USUARIOSCOC##',
                                  @UsuarioSCOC
                              ),
                       '##COMENTARIO##',
                       @ComentDesdeAprobacion
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreo tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Estatus Rechazo Calculo de Volumenes';
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'RECHAZADO POR USUARIO SCOC',
                                                      @ComentDesdeAprobacion,
                                                      @idUsuario;
    END;
    --------------------------------------------REINCIO-------------------------------------
    IF (@TipoCorreoEnviar = 4) --ReiniciaProceso --Enviar a contratista y a PEP
    BEGIN
        --------------------------------CONTRATISTA------------------------------------
        SELECT @Usuario = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------****PARA*****--------------------------------------------------
        SELECT @correoU = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;
        ---------------------------------
        ----------------------------------Notificar a PEP que usuario SCOC reinicio el proceso-------------------------------------------------
        SELECT @UsuarioPEP = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------****PARA*****--------------------------------------------------
        SELECT @correoUPEP = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------
        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);
        SELECT @UsuarioSCOC = Nombre
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = @idUsuario
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        SELECT @FechaReinicioProceso
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()))
              + ',</BR> Motivo de reinicio: ' + @ComentDesdeAprobacion;
        --------------------------------------------------------------------------------------
        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAINICIOPROCES#',
                                    @FechaReinicioProceso
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioSCOC
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Reinicio Calculo de volumenes';

        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                  -- IdNotificacion - bigint
                @correoU,                           -- Para - varchar(500)
                'Reinicio de Calculo de volumenes', -- Asunto - varchar(250)
                @Correo,                            -- Mensaje - text
                GETDATE(),                          -- FechaProgramadaEnvio - datetime
                0,                                  -- Enviada - bit
                NULL,                               -- FechaEnvio - datetime
                @idUsuario,                         -- CreadoPor - int
                GETDATE(),                          -- CreadoEl - datetime
                @idUsuario,                         -- ModificadoPor - int
                GETDATE(),                          -- ModificadoEl - datetime
                'notificaciones@adinco.mx',         -- De - varchar(100)
                0                                   -- EN_MsjEnviado - bit
                );
        END;
        --------------------------------------------------------------------------------------
        --------------------------------------------------------------------------------------
        SELECT @CorreoPEP
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @UsuarioPEP),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAINICIOPROCES#',
                                    @FechaReinicioProceso
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioSCOC
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Reinicio Calculo de volumenes';
        IF (@correoUPEP <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                  -- IdNotificacion - bigint
                @correoUPEP,                        -- Para - varchar(500)
                'Reinicio de Calculo de volumenes', -- Asunto - varchar(250)
                @CorreoPEP,                         -- Mensaje - text
                GETDATE(),                          -- FechaProgramadaEnvio - datetime
                0,                                  -- Enviada - bit
                NULL,                               -- FechaEnvio - datetime
                @idUsuario,                         -- CreadoPor - int
                GETDATE(),                          -- CreadoEl - datetime
                @idUsuario,                         -- ModificadoPor - int
                GETDATE(),                          -- ModificadoEl - datetime
                'notificaciones@adinco.mx',         -- De - varchar(100)
                0                                   -- EN_MsjEnviado - bit
                );
        END;
        --------------------------------------------------------------------------------------
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'REINICIO DE PROCESO POR USUARIO SCOC',
                                                      @ComentDesdeAprobacion,
                                                      @idUsuario;
    END;
    ------------------------------------------------LIQUIDOS Y GAS---------------------------------------------------------------
    IF (@TipoCorreoEnviar = 6) --Rechazado Comercializador LIQUIDOS  ---Envviar al Pep tambnien para que sepa que Volvera a aprobar
    BEGIN
        --------------------------------Para Contratista---------------------------------------------------
        SELECT @Usuario = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        ----------------------------------*********************PARA**********************
        SELECT @correoU = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------
        ----------------------------------Para Usuario PEP sepa que volvera a empezar el ciclo y volvera a aprobar-------------------------------------------------
        SELECT @UsuarioPEP = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;

        SELECT @correoUPEP = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;
        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);
        SELECT @UsuarioSCOC = Nombre
        FROM dbo.AP_Usuario
        WHERE UsuarioID = @idUsuario;
        SELECT @FechaAprobacionSCOC
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()));

        ----------------------------------------------------------------------
        --Para Contratista
        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(
                                                                     REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                                     '##CONTRATO##',
                                                                     @contrato
                                                                 ),
                                                          '##MES##',
                                                          @FechaName
                                                      ),
                                               '#FECHAAPROBACION#',
                                               @FechaAprobacionSCOC
                                           ),
                                    '##USUARIOSCOC##',
                                    @UsuarioSCOC
                                ),
                         '##COMENTARIO##',
                         @ComentDesdeAprobacion
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Rechazo Calculo de Volumenes';
        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                                           -- IdNotificacion - bigint
                @correoU,                                                                    -- Para - varchar(500)
                'Rechazado de calculo de volumenes por usuario comercializador de liquidos', -- Asunto - varchar(250)
                @Correo,                                                                     -- Mensaje - text
                GETDATE(),                                                                   -- FechaProgramadaEnvio - datetime
                0,                                                                           -- Enviada - bit
                NULL,                                                                        -- FechaEnvio - datetime
                @idUsuario,                                                                  -- CreadoPor - int
                GETDATE(),                                                                   -- CreadoEl - datetime
                @idUsuario,                                                                  -- ModificadoPor - int
                GETDATE(),                                                                   -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                                                  -- De - varchar(100)
                0                                                                            -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        --Para  PEP
        SELECT @CorreoPEP
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(
                                                                     REPLACE(HTML, '##NOMBRE_USUARIO##', @UsuarioPEP),
                                                                     '##CONTRATO##',
                                                                     @contrato
                                                                 ),
                                                          '##MES##',
                                                          @FechaName
                                                      ),
                                               '#FECHAAPROBACION#',
                                               @FechaAprobacionSCOC
                                           ),
                                    '##USUARIOSCOC##',
                                    @UsuarioSCOC
                                ),
                         '##COMENTARIO##',
                         @ComentDesdeAprobacion
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Rechazo Calculo de Volumenes';
        IF (@correoUPEP <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                                           -- IdNotificacion - bigint
                @correoUPEP,                                                                 -- Para - varchar(500)
                'Rechazado de calculo de volumenes por usuario comercializador de liquidos', -- Asunto - varchar(250)
                @CorreoPEP,                                                                  -- Mensaje - text
                GETDATE(),                                                                   -- FechaProgramadaEnvio - datetime
                0,                                                                           -- Enviada - bit
                NULL,                                                                        -- FechaEnvio - datetime
                @idUsuario,                                                                  -- CreadoPor - int
                GETDATE(),                                                                   -- CreadoEl - datetime
                @idUsuario,                                                                  -- ModificadoPor - int
                GETDATE(),                                                                   -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                                                  -- De - varchar(100)
                0                                                                            -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        ----Para comercializadores de liq and comercializadores de gas
        INSERT INTO #TemporalUsuarios
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso IN ( 10 )
              AND BitActivo = 1;
        INSERT INTO #TemporalDatosCorreo
        (
            NumeroContrato,
            id,
            contrato,
            Nombre,
            Usuario,
            FechaName,
            Descripcion
        )
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Estatus Rechazo Calculo de Volumenes' AS Descripcion
        --INTO
        --        #TemporalDatosCorreo
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuarios t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;
        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Rechazado de calculo de volumenes por usuario comercializador de liquidos',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(HTML, '##NOMBRE_USUARIO##', Nombre),
                                                                   '##CONTRATO##',
                                                                   @contrato
                                                               ),
                                                        '##MES##',
                                                        @FechaName
                                                    ),
                                             '#FECHAAPROBACION#',
                                             @FechaAprobacionSCOC
                                         ),
                                  '##USUARIOSCOC##',
                                  @UsuarioSCOC
                              ),
                       '##COMENTARIO##',
                       @ComentDesdeAprobacion
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreo tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Estatus Rechazo Calculo de Volumenes';
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'RECHAZADO POR USUARIO COMERCIALIZADOR DE LIQUIDOS',
                                                      @Comentarios,
                                                      @idUsuario;
    END;
    IF (@TipoCorreoEnviar = 7) --Rechazado Comercializador GAS   ---Envviar al Pep tambnien para que sepa que Volvera a aprobar
    BEGIN
        --------------------------------Para Contratista---------------------------------------------------
        SELECT @Usuario = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        ------------------************

        SELECT @correoU = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------
        ----------------------------------Para Usuario PEP sepa que volvera a empezar el ciclo y volvera a aprobar-------------------------------------------------
        SELECT @UsuarioPEP = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;

        SELECT @correoUPEP = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;
        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);
        SELECT @UsuarioSCOC = Nombre
        FROM dbo.AP_Usuario
        WHERE UsuarioID = @idUsuario;
        SELECT @FechaAprobacionSCOC
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()));

        ----------------------------------------------------------------------
        --Para Contratista
        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(
                                                                     REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                                     '##CONTRATO##',
                                                                     @contrato
                                                                 ),
                                                          '##MES##',
                                                          @FechaName
                                                      ),
                                               '#FECHAAPROBACION#',
                                               @FechaAprobacionSCOC
                                           ),
                                    '##USUARIOSCOC##',
                                    @UsuarioSCOC
                                ),
                         '##COMENTARIO##',
                         @ComentDesdeAprobacion
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Rechazo Calculo de Volumenes';
        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                                      -- IdNotificacion - bigint
                @correoU,                                                               -- Para - varchar(500)
                'Rechazado de calculo de volumenes por usuario comercializador de gas', -- Asunto - varchar(250)
                @Correo,                                                                -- Mensaje - text
                GETDATE(),                                                              -- FechaProgramadaEnvio - datetime
                0,                                                                      -- Enviada - bit
                NULL,                                                                   -- FechaEnvio - datetime
                @idUsuario,                                                             -- CreadoPor - int
                GETDATE(),                                                              -- CreadoEl - datetime
                @idUsuario,                                                             -- ModificadoPor - int
                GETDATE(),                                                              -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                                             -- De - varchar(100)
                0                                                                       -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        --Para  PEP
        SELECT @CorreoPEP
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(
                                                                     REPLACE(HTML, '##NOMBRE_USUARIO##', @UsuarioPEP),
                                                                     '##CONTRATO##',
                                                                     @contrato
                                                                 ),
                                                          '##MES##',
                                                          @FechaName
                                                      ),
                                               '#FECHAAPROBACION#',
                                               @FechaAprobacionSCOC
                                           ),
                                    '##USUARIOSCOC##',
                                    @UsuarioSCOC
                                ),
                         '##COMENTARIO##',
                         @ComentDesdeAprobacion
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Rechazo Calculo de Volumenes';
        IF (@correoUPEP <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                                      -- IdNotificacion - bigint
                @correoUPEP,                                                            -- Para - varchar(500)
                'Rechazado de calculo de volumenes por usuario comercializador de gas', -- Asunto - varchar(250)
                @CorreoPEP,                                                             -- Mensaje - text
                GETDATE(),                                                              -- FechaProgramadaEnvio - datetime
                0,                                                                      -- Enviada - bit
                NULL,                                                                   -- FechaEnvio - datetime
                @idUsuario,                                                             -- CreadoPor - int
                GETDATE(),                                                              -- CreadoEl - datetime
                @idUsuario,                                                             -- ModificadoPor - int
                GETDATE(),                                                              -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                                             -- De - varchar(100)
                0                                                                       -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        ----Para comercializadores de liq and comercializadores de gas
        INSERT INTO #TemporalUsuarios
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso IN ( 9 )
              AND BitActivo = 1;

        INSERT INTO #TemporalDatosCorreo
        (
            NumeroContrato,
            id,
            contrato,
            Nombre,
            Usuario,
            FechaName,
            Descripcion
        )
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Estatus Rechazo Calculo de Volumenes' AS Descripcion
        --INTO
        --        #TemporalDatosCorreo
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuarios t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;
        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Rechazado de calculo de volumenes por usuario comercializador de gas',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(HTML, '##NOMBRE_USUARIO##', tc.Nombre),
                                                                   '##CONTRATO##',
                                                                   @contrato
                                                               ),
                                                        '##MES##',
                                                        @FechaName
                                                    ),
                                             '#FECHAAPROBACION#',
                                             @FechaAprobacionSCOC
                                         ),
                                  '##USUARIOSCOC##',
                                  @UsuarioSCOC
                              ),
                       '##COMENTARIO##',
                       @ComentDesdeAprobacion
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreo tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Estatus Rechazo Calculo de Volumenes';
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'RECHAZADO POR USUARIO COMERCIALIZADOR DE GAS',
                                                      @Comentarios,
                                                      @idUsuario;
    END;
    IF (@TipoCorreoEnviar = 8) --Para que ApruebenTODOS los COMERCIALIZADORES
    BEGIN
        INSERT INTO #TemporalUsuarios
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso IN ( 9, 10 )
              AND BitActivo = 1;

        INSERT INTO #TemporalDatosCorreo
        (
            NumeroContrato,
            id,
            contrato,
            Nombre,
            Usuario,
            FechaName,
            Descripcion
        )
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Calculo Volumenes' AS Descripcion
        --INTO
        --        #TemporalDatosCorreo
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuarios t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;
        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Aprobación calculo de volumenes para comercializadores del estado',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(HTML, '##NOMBRE_USUARIO##', tc.Nombre),
                                             '##CONTRATO##',
                                             tc.NumeroContrato
                                         ),
                                  '##MES##',
                                  tc.FechaName
                              ),
                       '##ENLACE_DETALLE##',
                       @URL
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreo tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Calculo Volumenes';
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'ENVIADO A APROBACIÓN DE COMERCIALIZADORES DEL ESTADO',
                                                      '',
                                                      @idUsuario;
    END;

    IF (@TipoCorreoEnviar = 10) --Aprobado Comenrcializador LIQUIDOS
    BEGIN
        SELECT @Usuario = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------***PARA***** contratista----------------------------------
        SELECT @correoU = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;
        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);
        ----------------------------------Para Usuario PEP sepa que volvera a empezar el ciclo y volvera a aprobar-------------------------------------------------
        SELECT @UsuarioPEP = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------***PARA***** PEP----------------------------------
        SELECT @correoUPEP = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------
        SELECT @UsuarioSCOC = Nombre
        FROM AP_Usuario
        WHERE UsuarioID = @idUsuario;

        SELECT @FechaAprobacionSCOC
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()));

        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAAPROBACION#',
                                    @FechaAprobacionSCOC
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioSCOC
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Calculo de volumenes';
        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                                               -- IdNotificacion - bigint
                @correoU,                                                                        -- Para - varchar(500)
                'Estatus aprobado por usuario Comercializador de liquidos-calculo de volumenes', -- Asunto - varchar(250)
                @Correo,                                                                         -- Mensaje - text
                GETDATE(),                                                                       -- FechaProgramadaEnvio - datetime
                0,                                                                               -- Enviada - bit
                NULL,                                                                            -- FechaEnvio - datetime
                @idUsuario,                                                                      -- CreadoPor - int
                GETDATE(),                                                                       -- CreadoEl - datetime
                @idUsuario,                                                                      -- ModificadoPor - int
                GETDATE(),                                                                       -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                                                      -- De - varchar(100)
                0                                                                                -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        --Para  PEP
        SELECT @CorreoPEP
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @UsuarioPEP),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAAPROBACION#',
                                    @FechaAprobacionSCOC
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioSCOC
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Calculo de volumenes';
        IF (@correoUPEP <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                                               -- IdNotificacion - bigint
                @correoUPEP,                                                                     -- Para - varchar(500)
                'Estatus aprobado por usuario Comercializador de liquidos-calculo de volumenes', -- Asunto - varchar(250)
                @CorreoPEP,                                                                      -- Mensaje - text
                GETDATE(),                                                                       -- FechaProgramadaEnvio - datetime
                0,                                                                               -- Enviada - bit
                NULL,                                                                            -- FechaEnvio - datetime
                @idUsuario,                                                                      -- CreadoPor - int
                GETDATE(),                                                                       -- CreadoEl - datetime
                @idUsuario,                                                                      -- ModificadoPor - int
                GETDATE(),                                                                       -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                                                      -- De - varchar(100)
                0                                                                                -- EN_MsjEnviado - bit
                );
        END;
        --------------------------------------------------------------------------------
        ----------------------------------------------------------------------
        ----Para comercializadores de liq and comercializadores de gas
        INSERT INTO #TemporalUsuarios
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso IN ( 10 )
              AND BitActivo = 1;

        INSERT INTO #TemporalDatosCorreo
        (
            NumeroContrato,
            id,
            contrato,
            Nombre,
            Usuario,
            FechaName,
            Descripcion
        )
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Estatus Calculo de volumenes' AS Descripcion
        --INTO
        --        #TemporalDatosCorreo
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuarios t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;

        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Estatus aprobado por usuario Comercializador de liquidos-calculo de volumenes',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(HTML, '##NOMBRE_USUARIO##', tc.Nombre),
                                                                   '##CONTRATO##',
                                                                   @contrato
                                                               ),
                                                        '##MES##',
                                                        @FechaName
                                                    ),
                                             '#FECHAAPROBACION#',
                                             @FechaAprobacionSCOC
                                         ),
                                  '##USUARIOSCOC##',
                                  @UsuarioSCOC
                              ),
                       '##COMENTARIO##',
                       @ComentDesdeAprobacion
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreo tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Estatus Calculo de volumenes';

        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'Aprobacion comercializador de liquidos',
                                                      '',
                                                      @idUsuario;
    END;
    IF (@TipoCorreoEnviar = 11) --Aprobado Comenrcializador GAS
    BEGIN
        SELECT @Usuario = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------***PARA*****----------------------------------
        SELECT @correoU = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.CreadoPor
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -----------------------------------------------------------------------------------------
        SELECT @contrato = NumeroContrato
        FROM dbo.CO_Contrato
        WHERE IdContrato = @idContrato;
        SET @FechaName = UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte);
        ----------------------------------Para Usuario PEP sepa que volvera a empezar el ciclo y volvera a aprobar-------------------------------------------------

        SELECT @UsuarioPEP = Nombre --Envio a aprobar el calculo
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato = @idContrato;
        -------------------------------------------***PARA*****----------------------------------
		
        SELECT @correoUPEP = ISNULL(Usuario, '')
        FROM SCOC_EnvioNotificacion
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = SCOC_EnvioNotificacion.IdUsuarioAprobadoRepPEP
        WHERE MesReporte = @MesReporte
              AND idContrato =@idContrato;
        -----------------------------------------------------------------------------------
        SELECT @UsuarioSCOC = Nombre
        FROM AP_Usuario
        WHERE UsuarioID = @idUsuario;

        SELECT @FechaAprobacionSCOC
            = UPPER(DATENAME(DAY, GETDATE())) + ' ' + UPPER(DATENAME(MONTH, GETDATE())) + ' ' + LTRIM(YEAR(GETDATE()));

        SELECT @Correo
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @Usuario),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAAPROBACION#',
                                    @FechaAprobacionSCOC
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioSCOC
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Calculo de volumenes';
        IF (@correoU <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                                          -- IdNotificacion - bigint
                @correoU,                                                                   -- Para - varchar(500)
                'Estatus aprobado por usuario Comercializador de gas-calculo de volumenes', -- Asunto - varchar(250)
                @Correo,                                                                    -- Mensaje - text
                GETDATE(),                                                                  -- FechaProgramadaEnvio - datetime
                0,                                                                          -- Enviada - bit
                NULL,                                                                       -- FechaEnvio - datetime
                @idUsuario,                                                                 -- CreadoPor - int
                GETDATE(),                                                                  -- CreadoEl - datetime
                @idUsuario,                                                                 -- ModificadoPor - int
                GETDATE(),                                                                  -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                                                 -- De - varchar(100)
                0                                                                           -- EN_MsjEnviado - bit
                );
        END;
        ----------------------------------------------------------------------
        --Para  PEP
        SELECT @CorreoPEP
            = REPLACE(
                         REPLACE(
                                    REPLACE(
                                               REPLACE(
                                                          REPLACE(HTML, '##NOMBRE_USUARIO##', @UsuarioPEP),
                                                          '##CONTRATO##',
                                                          @contrato
                                                      ),
                                               '##MES##',
                                               @FechaName
                                           ),
                                    '#FECHAAPROBACION#',
                                    @FechaAprobacionSCOC
                                ),
                         '##USUARIOSCOC##',
                         @UsuarioSCOC
                     )
        FROM dbo.TA_Correo
        WHERE Descripcion = 'Estatus Calculo de volumenes';
        IF (@correoUPEP <> '')
        BEGIN
            INSERT INTO dbo.S_Notificacion
            (
                IdNotificacion,
                Para,
                Asunto,
                Mensaje,
                FechaProgramadaEnvio,
                Enviada,
                FechaEnvio,
                CreadoPor,
                CreadoEl,
                ModificadoPor,
                ModificadoEl,
                De,
                EN_MsjEnviado
            )
            VALUES
            (
                (
                    SELECT MAX(IdNotificacion) + 1 FROM dbo.S_Notificacion
                ),                                                                          -- IdNotificacion - bigint
                @correoUPEP,                                                                -- Para - varchar(500)
                'Estatus aprobado por usuario Comercializador de gas-calculo de volumenes', -- Asunto - varchar(250)
                @CorreoPEP,                                                                 -- Mensaje - text
                GETDATE(),                                                                  -- FechaProgramadaEnvio - datetime
                0,                                                                          -- Enviada - bit
                NULL,                                                                       -- FechaEnvio - datetime
                @idUsuario,                                                                 -- CreadoPor - int
                GETDATE(),                                                                  -- CreadoEl - datetime
                @idUsuario,                                                                 -- ModificadoPor - int
                GETDATE(),                                                                  -- ModificadoEl - datetime
                'notificaciones@adinco.mx',                                                 -- De - varchar(100)
                0                                                                           -- EN_MsjEnviado - bit
                );
        END;
        --------------------------------------------------------------------------------
        ----------------------------------------------------------------------
        ----Para comercializadores de liq and comercializadores de gas
        INSERT INTO #TemporalUsuarios
        (
            contrato,
            Nombre,
            Usuario
        )
        SELECT @idContrato,
               Nombre,
               Usuario
        FROM dbo.AP_PermisosUsuarios
            JOIN dbo.AP_Usuario
                ON AP_Usuario.UsuarioID = AP_PermisosUsuarios.UsuarioID
        WHERE IdPermiso IN ( 9 )
              AND BitActivo = 1;

        INSERT INTO #TemporalDatosCorreo
        (
            NumeroContrato,
            id,
            contrato,
            Nombre,
            Usuario,
            FechaName,
            Descripcion
        )
        SELECT NumeroContrato,
               t.*,
               UPPER(DATENAME(MONTH, @MesReporte)) + ' ' + CONVERT(VARCHAR(4), @MesReporte) AS FechaName,
               'Estatus Calculo de volumenes' AS Descripcion
        --INTO
        --        #TemporalDatosCorreo
        FROM dbo.CO_Contrato c
            JOIN #TemporalUsuarios t
                ON t.contrato = c.IdContrato
        WHERE IdContrato = @idContrato;
        INSERT INTO dbo.S_Notificacion
        (
            IdNotificacion,
            Para,
            Asunto,
            Mensaje,
            FechaProgramadaEnvio,
            Enviada,
            FechaEnvio,
            CreadoPor,
            CreadoEl,
            ModificadoPor,
            ModificadoEl,
            De,
            EN_MsjEnviado
        )
        SELECT
            (
                SELECT MAX(IdNotificacion) + tc.id FROM dbo.S_Notificacion
            ),
            tc.Usuario,
            'Estatus aprobado por usuario Comercializador de gas-calculo de volumenes',
            REPLACE(
                       REPLACE(
                                  REPLACE(
                                             REPLACE(
                                                        REPLACE(
                                                                   REPLACE(HTML, '##NOMBRE_USUARIO##', tc.Nombre),
                                                                   '##CONTRATO##',
                                                                   @contrato
                                                               ),
                                                        '##MES##',
                                                        @FechaName
                                                    ),
                                             '#FECHAAPROBACION#',
                                             @FechaAprobacionSCOC
                                         ),
                                  '##USUARIOSCOC##',
                                  @UsuarioSCOC
                              ),
                       '##COMENTARIO##',
                       @ComentDesdeAprobacion
                   ),
            GETDATE(),                  -- FechaProgramadaEnvio - datetime
            0,                          -- Enviada - bit
            NULL,                       -- FechaEnvio - datetime
            @idUsuario,                 -- CreadoPor - int
            GETDATE(),                  -- CreadoEl - datetime
            @idUsuario,                 -- ModificadoPor - int
            GETDATE(),                  -- ModificadoEl - datetime
            'notificaciones@adinco.mx', -- De - varchar(100)
            0                           -- EN_MsjEnviado - bit
        FROM dbo.TA_Correo tac
            JOIN #TemporalDatosCorreo tc
                ON tc.Descripcion = tac.Descripcion
        WHERE tac.Descripcion = 'Estatus Calculo de volumenes';
        EXECUTE SCOC_GuardaHistorialCalculosVolumenes @idContrato,
                                                      @MesReporte,
                                                      'Aprobacion comercializador de gas',
                                                      '',
                                                      @idUsuario;
    END;
--------------------------------------------*/
END;
