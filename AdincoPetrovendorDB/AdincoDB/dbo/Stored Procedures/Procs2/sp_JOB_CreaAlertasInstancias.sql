CREATE PROCEDURE [dbo].[sp_JOB_CreaAlertasInstancias]
AS
BEGIN
    -- =============================================
    -- Author:		Reyna Olvera
    -- Create date: 20181023
    -- Description:	Crea Alertas 
    -- =============================================
    -- 20190701	BAAC	Se modifica para que no inserte los registros para el push de la aplicación, solo las notificaciones de correo.
    -- =============================================
    SET NOCOUNT ON;

    --CREATE TABLE #DatosAlertaEntregables
    --(
    --    IDAlerta INT IDENTITY(1, 1),
    --    idInstanciaEntregable INT,
    --    Periodo DATE,
    --    FECHALIMITEACCION DATE,
    --    ActividadIDACTUAL INT,
    --    EstadoIDACTUAL INT,
    --    NombreACTUAL VARCHAR(500),
    --    UsuarioIDACTUAL INT,
    --    ParaACTUAL VARCHAR(MAX),
    --    NombreEstadoACTUAL VARCHAR(MAX),
    --    ActividadIDSiguiente INT,
    --    IDEstadoSiguiente INT,
    --    NombreSiguiente VARCHAR(MAX),
    --    UsuarioIDSiguiente INT,
    --    ParaSiguiente VARCHAR(MAX),
    --    EstadoSiguiente VARCHAR(MAX),
    --    FECHALIMITEACCIONSIGUIENTE DATE,
    --    tipoCorreo VARCHAR(MAX),
    --    IdEntregable INT,
    --    DocumentoEntregable VARCHAR(MAX),
    --    TextoTipoAlertaActual VARCHAR(MAX),
    --    TextoTipoAlertaActual2 VARCHAR(MAX),
    --    TextoTipoAlertaSiguiente VARCHAR(MAX),
    --    TextoTipoAlertaSiguiente2 VARCHAR(MAX),
    --    Ruta VARCHAR(MAX)
    --);

    DECLARE @HOY DATE,
            @NombreDia VARCHAR(100);
    SET @HOY = GETDATE();
    SELECT @NombreDia = NombreDia
    FROM dbo.AP_Calendario
    WHERE IdFecha = @HOY;

	IF @NombreDia = 'Lunes'
	BEGIN
		EXEC sp_EN_NotificacionesSemanales
		EXEC sp_EN_NotificacionesSemanales_ENI
--		SELECT 'EXEC'
	END

	IF (@NombreDia NOT IN ( 'Sábado', 'Domingo' ))
	BEGIN
		EXEC sp_EN_NotificacionesDiarias_Equinor
	END

/*
    IF (@NombreDia NOT IN ( 'Sábado', 'Domingo' ))
    BEGIN

        --=====================================================================================================================================================================================
        INSERT INTO #DatosAlertaEntregables (idInstanciaEntregable, Periodo, FECHALIMITEACCION, ActividadIDACTUAL,
                                             EstadoIDACTUAL, NombreACTUAL, UsuarioIDACTUAL, ParaACTUAL,
                                             NombreEstadoACTUAL, ActividadIDSiguiente, IDEstadoSiguiente,
                                             NombreSiguiente, UsuarioIDSiguiente, ParaSiguiente, EstadoSiguiente,
                                             FECHALIMITEACCIONSIGUIENTE, tipoCorreo, IdEntregable, DocumentoEntregable,
                                             TextoTipoAlertaActual, TextoTipoAlertaActual2, TextoTipoAlertaSiguiente,
                                             TextoTipoAlertaSiguiente2, Ruta)
        EXEC [sp_ExtraeDatosAlertasInstancias];
        --Select * from #DatosAlertaEntregables where idinstanciaEntregable=100261
        --=====================================================================================================================================================================================
        --=====================================================================================================================================================================================
        INSERT INTO dbo.S_Notificacion (IdNotificacion, Para, Asunto, Mensaje, FechaProgramadaEnvio, Enviada,
                                        FechaEnvio, CreadoPor, CreadoEl, ModificadoPor, ModificadoEl, De, EN_MsjEnviado)
        (SELECT
             (
                 SELECT MAX(IdNotificacion) + IDAlerta FROM dbo.S_Notificacion
             ),                                                                             -- IdNotificacion - bigint
             DAEA.ParaACTUAL,   -- Para - varchar(500)
 -- 'Alerta Entregables'
             SUBSTRING(REPLACE(DAEA.DocumentoEntregable, ' del contrato ', ' - '), 0, 250), -- Asunto - varchar(250)
             REPLACE(
                        REPLACE(
                                   REPLACE(
                                              REPLACE(
                                                         REPLACE(
                                                                    REPLACE(
                                                                               REPLACE(
                                                                                          REPLACE(
                                                                                                     t.HTML,
                                                                                                     '##NOMBRE_USUARIO##',
                                                                                                     DAEA.NombreACTUAL
                                                                                                 ),
                                                                                          '#TEXTOTIPOALERTA#',
                                                                                          DAEA.TextoTipoAlertaActual
                                                                                      ),
                                                                               '##TIPO_OPERACION_E##',
                                                                               DAEA.NombreEstadoACTUAL
                                                                           ),
                                                                    '##COMENTARIOGENERAL##',
                                                                    DAEA.DocumentoEntregable
                                                                ),
                                                         '##NOMBRE_INSTANCIA##',
                                                         DAEA.Periodo
                                                     ),
                                              '#TEXTOTIPOALERTAD#',
                                              DAEA.TextoTipoAlertaActual2
                                          ),
                                   '##TEXTOFINAL##',
                                   'Ingresa al portal, para ver el detalle'
                               ),
                        '##ENLACE_DETALLE##',
                        DAEA.Ruta
                    ),                                                                      -- Mensaje - text
             GETDATE(),                                                                     -- FechaProgramadaEnvio - datetime
             0,                                                                             -- Enviada - bit
             NULL,                                                                          -- FechaEnvio - datetime
             1,                                                                             -- CreadoPor - int
             GETDATE(),                                                                     -- CreadoEl - datetime
             1,                                                                             -- ModificadoPor - int
             GETDATE(),                                                                     -- ModificadoEl - datetime
             'notificaciones@adinco.mx',                                                    -- De - varchar(100)
             0                                                                              -- EN_MsjEnviado - bit

         -- SELECT DAEA.idInstanciaEntregable,DAEA.tipoCorreo,*
         FROM #DatosAlertaEntregables DAEA
         JOIN dbo.TA_Correo t ON t.Descripcion = 'Alertas Entregable Responsables'
         WHERE DAEA.ActividadIDACTUAL IS NOT NULL
        --   AND DAEA.ParaACTUAL IN ( 'reyna.olvera@adinco.mx', 'reyna.olvera@ogss.com.mx' )
        );
        --=======================================================================================================================
        --=======================================HISTORIAL DE ALERTAS-===========================================================
        INSERT INTO EN_HistorialHotificacionesEnviadas (Para, Asunto, Mensaje, De, idInstanciaEntregable, Periodo,
                                                        Estado, FECHALIMITEACCION, tipoCorreo, IdEntregable, CreadoPor,
                                                        CreadoEl)
        (SELECT DAEA.ParaACTUAL,                                            -- Para - varchar(500)
                REPLACE(DAEA.DocumentoEntregable, ' del contrato ', ' - '), -- Asunto - varchar(250)
                                                                            --'Alerta Entregables', 
                REPLACE(
                           REPLACE(
                                      REPLACE(
                                                 REPLACE(
                                                            REPLACE(
                                                                       REPLACE(
                                                                                  REPLACE(
                                                                                             REPLACE(
                                                                                                        t.HTML,
                                                                                                        '##NOMBRE_USUARIO##',
                                                                                                        DAEA.NombreACTUAL
                                                                                                    ),
                                                                                             '#TEXTOTIPOALERTA#',
                                                                                             DAEA.TextoTipoAlertaActual
                                                                                         ),
                                                                                  '##TIPO_OPERACION_E##',
                                                                                  DAEA.NombreEstadoACTUAL
                                                                              ),
                                                                       '##COMENTARIOGENERAL##',
                                                                       DAEA.DocumentoEntregable
                                                                   ),
                                                            '##NOMBRE_INSTANCIA##',
                                                            DAEA.Periodo
                                                        ),
                                                 '#TEXTOTIPOALERTAD#',
                                                 DAEA.TextoTipoAlertaActual2
                                             ),
                                      '##TEXTOFINAL##',
                                      'Ingresa al portal, para ver el detalle'
                                  ),
                           '##ENLACE_DETALLE##',
                           DAEA.Ruta
                       ),                                                   -- Mensaje - text
                'notificaciones@adinco.mx',
                DAEA.idInstanciaEntregable,
                DAEA.Periodo,
                'ESTADO ACTUAL: ' + DAEA.NombreEstadoACTUAL,
                DAEA.FECHALIMITEACCION,
                DAEA.tipoCorreo,
                DAEA.IdEntregable,
                1,     -- CreadoPor - int
             GETDATE()                                                   -- CreadoEl - datetime
         FROM #DatosAlertaEntregables DAEA
         JOIN dbo.TA_Correo t ON t.Descripcion = 'Alertas Entregable Responsables'
         WHERE DAEA.ActividadIDACTUAL IS NOT NULL);

        --=======================================================================================================================
        INSERT INTO dbo.S_Notificacion (IdNotificacion, Para, Asunto, Mensaje, FechaProgramadaEnvio, Enviada,
                                        FechaEnvio, CreadoPor, CreadoEl, ModificadoPor, ModificadoEl, De, EN_MsjEnviado)
        (SELECT
             (
                 SELECT MAX(IdNotificacion) + IDAlerta FROM dbo.S_Notificacion
             ),                                                                             -- IdNotificacion - bigint
             DAES.ParaSiguiente,                                                            -- Para - varchar(500)
             SUBSTRING(REPLACE(DAES.DocumentoEntregable, ' del contrato ', ' - '), 0, 250), -- Asunto - varchar(250)
                                                                                            -- 'Alerta Entregables',       -- Asunto - varchar(250)
             REPLACE(
                        REPLACE(
                                   REPLACE(
                                              REPLACE(
                                                         REPLACE(
                                                                    REPLACE(
                                                                               REPLACE(
                                                                                          t.HTML,
                                                                                          '##NOMBRE_USUARIO##',
                                                                                          DAES.NombreSiguiente
                                                                                      ),
                                                                               '#TEXTOTIPOALERTA#',
                                                                               DAES.TextoTipoAlertaSiguiente
                                                                           ),
                                                                    '##TIPO_OPERACION_E##',
                                                                    ''
                                                                ), --  DAES.EstadoSiguiente
                                                                   --   ),.
                                                         '##COMENTARIOGENERAL##',
                                                         DAES.DocumentoEntregable
                                                     ),
                                              '##NOMBRE_INSTANCIA##',
                                              DAES.Periodo
                                          ),
                                   '#TEXTOTIPOALERTAD#',
                                   ('La fecha limite para llevar acabo la ' + DAES.NombreEstadoACTUAL + ' fue: '
                                    + CONVERT(VARCHAR(50), DAES.FECHALIMITEACCION, 23)
                                   )
                               ),
                        '##TEXTOFINAL##',
                        ''
                    ),                                                                      -- Mensaje - text, -- Mensaje - text
             GETDATE(),                                                                     -- FechaProgramadaEnvio - datetime
             0,                                                                             -- Enviada - bit
             NULL,                                                                          -- FechaEnvio - datetime
             1,                                                  -- CreadoPor - int
             GETDATE(),                                                      -- CreadoEl - datetime
             1,                                                                             -- ModificadoPor - int
             GETDATE(),                                                                     -- ModificadoEl - datetime
             'notificaciones@adinco.mx',                                                    -- De - varchar(100)
             0                                                                              -- EN_MsjEnviado - bit,
         --Select *
         FROM #DatosAlertaEntregables DAES
         JOIN dbo.TA_Correo t ON t.Descripcion = 'Alertas Entregable'
         WHERE DAES.ActividadIDSiguiente IS NOT NULL
        -- AND DAES.ParaSiguiente IN ( 'reyna.olvera@adinco.mx', 'reyna.olvera@ogss.com.mx' )
        );
        --=======================================================================================================================
        --=======================================HISTORIAL DE ALERTAS-===========================================================
        INSERT INTO EN_HistorialHotificacionesEnviadas (Para, Asunto, Mensaje, De, idInstanciaEntregable, Periodo,
                                                        Estado, FECHALIMITEACCION, tipoCorreo, IdEntregable, CreadoPor,
                                                        CreadoEl)
        (SELECT DAES.ParaSiguiente,                                         -- Para - varchar(500)
                REPLACE(DAES.DocumentoEntregable, ' del contrato ', ' - '), -- Asunto - varchar(250)
                                                                            --  'Alerta Entregables', -- Asunto - varchar(250)
                REPLACE(
                           REPLACE(
                                      REPLACE(
                                                 REPLACE(
                                                            REPLACE(
                                                                       REPLACE(
                                                                                  REPLACE(
                                                                                             t.HTML,
                                                                                             '##NOMBRE_USUARIO##',
                                                                                             DAES.NombreSiguiente
                                                                                         ),
                                                                                  '#TEXTOTIPOALERTA#',
                                                                                  DAES.TextoTipoAlertaSiguiente
                                                                              ),
                                                                       '##TIPO_OPERACION_E##',
                                                                       ''
                                                                   ), --  DAES.EstadoSiguiente
                                                                      --   ),
                                                            '##COMENTARIOGENERAL##',
                                                            DAES.DocumentoEntregable
                                                        ),
                                                 '##NOMBRE_INSTANCIA##',
                                                 DAES.Periodo
                                             ),
                                      '#TEXTOTIPOALERTAD#',
                                      ('La fecha limite para llevar acabo la ' + DAES.NombreEstadoACTUAL + ' fue: '
+ CONVERT(VARCHAR(50), DAES.FECHALIMITEACCION, 23)
                        )
                       ),
              '##TEXTOFINAL##',
                           ''
                       ),                                                   -- Mensaje - text, -- Mensaje - text
                'notificaciones@adinco.mx',
                DAES.idInstanciaEntregable,
                DAES.Periodo,
                'ESTADO SIGUIENTE: ' + DAES.EstadoSiguiente,
                DAES.FECHALIMITEACCIONSIGUIENTE,
                DAES.tipoCorreo,
                DAES.IdEntregable,
                1,                                                          -- CreadoPor - int
                GETDATE()                                                   -- CreadoEl - datetime

         --	 Select *
         FROM #DatosAlertaEntregables DAES
         JOIN dbo.TA_Correo t ON t.Descripcion = 'Alertas Entregable'
         WHERE DAES.ActividadIDSiguiente IS NOT NULL);

    END;
*/
END;
