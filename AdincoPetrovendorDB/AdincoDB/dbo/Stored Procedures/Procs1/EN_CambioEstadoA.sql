USE [Adinco]
GO
/****** Object:  StoredProcedure [dbo].[EN_CambioEstadoA]    Script Date: 25/01/2022 08:41:07 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[EN_CambioEstadoA]
    @idUsuario INT, --10150
    @idContrato INT,
    @idInstanciaEntregable INT,
    @Estatus INT,               --2 aprobada, 3 es rechazada
    @Comentarios VARCHAR(5000), -- el comentario del usuario, si no va en blanco
    @TipoOperacion INT,         --4
    @Rechazado BIT,             -- 1 es rechazado y 0 es aprobado
    @URLDetalle VARCHAR(MAX)   --sacar con que liga 
AS
BEGIN
    --2 Elaborador-- 3 Revisión, 4-- Aprobación --5Administrador Entregables
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/04/2018
-- Description:solo cambia el estatus para la instancia 
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Update date: 21/10/2020 
-- Description: Se agregar sp SP_EN_GuardarAvanceEntregableSeguimiento para seguimiento Equinor
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Update date: 25/01/2022 
-- Description: Se desactivan los registros del hisotrial entregables(url)
-- =============================================
    SET NOCOUNT ON;
    DECLARE @idVersion INT,
            @contrato INT,
            @ActividadSiguienteID INT,
            @ActividadIDActual INT,
            @NombreInstancia VARCHAR(MAX),
            @EnlaceDetalle VARCHAR(MAX),
            @EnlaceAprobado VARCHAR(MAX),
            @EnlaceRechazo VARCHAR(MAX),
            @FechaInstancia VARCHAR(MAX),
            @Para VARCHAR(MAX),
            @NombreUsuario VARCHAR(MAX),
            @idTipoOperacion INT,
            @ActividadIDeElaboracion INT,
            @idContratoEntregable INT,
            @usuarioResponsable INT,
            @EstadoI INT,
            @EstadoAprobado INT,
            @EsUsuarioAprobador INT,
            @EsGrupo INT,
            @IsAdmin INT,
            @EstadoActual VARCHAR(MAX);

    SELECT TOP 1
           @idVersion = IdLineaTiempo
    FROM dbo.EN_HistorialAprobacionesLineaTiempo
    WHERE idInstanciaEntregable = @idInstanciaEntregable
    ORDER BY CreadoEn DESC;


    SELECT @contrato = IdContrato,
           @idContratoEntregable = IE.IdContratoEntregable
    FROM dbo.EN_InstanciasEntregable IE
        JOIN dbo.EN_ContratoEntregable CE
            ON IE.IdContratoEntregable = CE.IdContratoEntregable
    WHERE idInstanciaEntregable = @idInstanciaEntregable;


    SELECT @IsAdmin = COUNT(1)
    FROM dbo.AP_PerfilUsuario PU
        JOIN dbo.AP_Perfil P
            ON PU.PerfilID = P.IdPerfil
        JOIN dbo.AP_Rol R
            ON P.IdRol = R.IdRol
    WHERE UsuarioID = @idUsuario
          AND P.IdContrato = @idContrato
          AND (R.Rol LIKE '%Admini%' OR R.ROL LIKE '%SASISOPA%SHELL%');


    IF (@idContrato = 0 OR @idContrato IS NULL)
    BEGIN

        SELECT @idContrato = IdContrato
        FROM dbo.EN_InstanciasEntregable IE
            JOIN dbo.EN_ContratoEntregable CE
                ON IE.IdContratoEntregable = CE.IdContratoEntregable
        WHERE idInstanciaEntregable = @idInstanciaEntregable;

    END;


    SELECT @ActividadIDeElaboracion = ActividadID
    FROM dbo.EN_Actividad
    WHERE IdContratoEntregable = @idContratoEntregable
          AND EstadoID = 10000;



    SELECT @ActividadIDActual = I.ActividadID,
           @usuarioResponsable = CASE ISNULL(EXAR.idUsuario, '')
                                     WHEN '' THEN
                                         A.idUsuario
                                     ELSE
                                         EXAR.idUsuario
                                 END,
           @EstadoI = A.EstadoID
    FROM dbo.EN_InstanciasEntregable I
        JOIN dbo.EN_Actividad A
            ON I.ActividadID = A.ActividadID
        LEFT JOIN dbo.EN_ExcepcionesActividad EXAR
            ON A.ActividadID = EXAR.ActividadIDExcepcion
               AND I.idInstanciaEntregable = EXAR.IdInstanciasEntregables
    WHERE idInstanciaEntregable = @idInstanciaEntregable;



    SELECT @NombreInstancia = DocumentoEntregable,
           @FechaInstancia = FechasLimiteAprobacion
 FROM dbo.EN_InstanciasEntregable IE
        JOIN dbo.EN_ContratoEntregable CE
            ON IE.IdContratoEntregable = CE.IdContratoEntregable
        JOIN dbo.EN_Entregable E
            ON CE.IdEntregable = E.IdEntregable
    WHERE idInstanciaEntregable = @idInstanciaEntregable;

    IF (@idUsuario = @usuarioResponsable)
    BEGIN
        SET @EsUsuarioAprobador = 1;
    END;
    ELSE
    BEGIN
        IF (
           (
               SELECT COUNT(1)
               FROM EN_GruposUsuarios
               WHERE IdGrupo = @usuarioResponsable
                     AND IdUsuario = @idUsuario
                     AND IdContrato = @idContrato
           ) > 0
           )
        BEGIN
            SET @EsUsuarioAprobador = 1;
        END;
        ELSE
        BEGIN
            SET @EsUsuarioAprobador = 0;
        END;
    END;

    IF (
           @EsUsuarioAprobador = 1
           OR
           (
               @IsAdmin = 1 AND
               @Rechazado = 1
               AND @TipoOperacion = 5
           )
       ) --SI ES USUARIO RESPONSABLE O SI ES ADMINISTRADOR Y SE VA A REINICIAR
    BEGIN
        IF (@Rechazado = 0)
        BEGIN
            SELECT @ActividadSiguienteID = SiguienteActividadID
            FROM dbo.EN_Transicion
            WHERE ActividadInicialID = @ActividadIDActual
                  AND AccionID = 10001;

            IF @ActividadSiguienteID IS NOT NULL
            BEGIN

                UPDATE EN_InstanciasEntregable
                SET ActividadID = @ActividadSiguienteID,
                    ModificadoEn = GETDATE()
                WHERE idInstanciaEntregable = @idInstanciaEntregable;

                SELECT @EnlaceDetalle = EnlaceDetalle,
                       @EnlaceAprobado = EnlaceAprobado,
                       @EnlaceRechazo = EnlaceRechazo,
                       @Para = correos,
                       @NombreUsuario = NombreUsuario,
                       @idTipoOperacion = tipoOperacion
                FROM dbo.EN_URLResponsablesEntregables
                WHERE ActividadID = @ActividadSiguienteID;

                IF (@Para IS NOT NULL)
                BEGIN

                    SELECT ID = ROW_NUMBER() OVER (ORDER BY EnlaceDetalle),
                           EnlaceDetalle,
                           EnlaceAprobado,
                           EnlaceRechazo,
                           correos,
                           NombreUsuario,
                           tipoOperacion,
                           NombreInstancia,
                           FechaInstancia
                    INTO #tmp
                    FROM dbo.EN_URLResponsablesEntregables
                    WHERE ActividadID = @ActividadSiguienteID
                          AND idInstanciaEntregable = @idInstanciaEntregable;

                    DECLARE @max INT,
                            @min INT;
                    SELECT @max = MAX(ID),
                           @min = 1
                    FROM #tmp;

                    WHILE (@min <= @max)
                    BEGIN
                        --select * from #tmp where id = @min


                        SELECT @EnlaceDetalle = EnlaceDetalle,
                               @EnlaceAprobado = EnlaceAprobado,
                               @EnlaceRechazo = EnlaceRechazo,
                               @Para = correos,
                               @NombreUsuario = NombreUsuario,
                               @idTipoOperacion = tipoOperacion,
                               @NombreInstancia = NombreInstancia,
                               @FechaInstancia = FechaInstancia
                        FROM #tmp
                        WHERE ID = @min;

                        EXEC [sp_EN_EnviaCorreosRevisionAprobacion] @idUsuario,
                                                                    @idContrato,
                                                                    @idInstanciaEntregable,
                                                                    @idTipoOperacion,
                                                                    @EnlaceAprobado,
                                                                    @EnlaceRechazo,
                                                                    @NombreInstancia,
                                                                    @FechaInstancia,
                                                                    @EnlaceDetalle,
                                                                    @Para,
                                                                    @NombreUsuario,
                                                                    12,
                                                                    0;


                        SELECT @min = @min + 1;
                    END;


                END;

                SELECT @idTipoOperacion = tipoOperacion
                FROM dbo.EN_URLResponsablesEntregables
                WHERE ActividadID = @ActividadIDActual;


                SELECT @Para = CASE ISNULL(EXAE.idUsuario, '')
                                   WHEN '' THEN
                                       u.Usuario
                                   ELSE
                                       UXE.Usuario
                               END,
                       @NombreUsuario = CASE ISNULL(EXAE.idUsuario, '')
                                            WHEN '' THEN
                                                u.Nombre
                                            ELSE
                                                UXE.Nombre
                                        END,
                       @EsGrupo = CASE ISNULL(EXAE.idUsuario, '')
                                      WHEN '' THEN
                                          ISNULL(u.IsGrupo, 0)
                                      ELSE
                                          ISNULL(UXE.IsGrupo, 0)
                                  END
                FROM dbo.EN_Actividad A
                    JOIN dbo.AP_Usuario u
                        ON A.idUsuario = u.UsuarioID
                    LEFT JOIN dbo.EN_ExcepcionesActividad EXAE
                        ON EXAE.ActividadIDExcepcion = @ActividadIDeElaboracion
                    LEFT JOIN dbo.AP_Usuario UXE
                        ON EXAE.idUsuario = UXE.UsuarioID
                WHERE ActividadID = @ActividadIDeElaboracion;


                IF (@EsGrupo = 1) --SI ES GRUPO EL ELABORADOR, SOLO SE ENVIA AL USUARIO QUE REALIZO EL ENTREGABLE
                BEGIN

                    SELECT @Para = U.Usuario,
                           @NombreUsuario = U.Nombre
                    FROM EN_HistorialAprobacionesLineaTiempo HAL
                        JOIN AP_Usuario U
                            ON HAL.CreadoPor = U.UsuarioID
                    WHERE idInstanciaEntregable = @idInstanciaEntregable
                          AND IdLineaTiempo = @idVersion
                          AND idTipoOperacion = 2;

                END;

                EXEC [sp_EN_EnviaCorreosRevisionAprobacion] @idUsuario,
                                                            @idContrato,
                                                            @idInstanciaEntregable,
                                                            @idTipoOperacion,
                                                            '',
                                                            '',
                                                            @NombreInstancia,
                                                            @FechaInstancia,
                                                            @URLDetalle,
                                                            @Para,
                                                            @NombreUsuario,
                                                 13,
                                                            2;

                EXEC EN_GuardaHistorialLineaTiempo @idVersion,
                                                   @idInstanciaEntregable,
                                                   @idUsuario,
                                                   @contrato,
                                                   @Comentarios,
                                                   @Rechazado,
                                                   @TipoOperacion,
                                                   0,
                                                   'En este paso no se ingresa URL',
                                                   0;

                EXEC [sp_EN_EnviaCorreos] @idUsuario,
                                          @contrato,
                                          @idInstanciaEntregable,
                                          10004,
                                          @ActividadSiguienteID,
                                          @ActividadIDActual;


                /*EL ENTREGABLABLE PASO AL SIGUIENTE ESTADO, SE REGISTRA EL 100% DE AVANCE DEL SEGUIMIENTO DEL ENTREGABLE INSTANCIA*/
                --NO SE SABE SI ES APROBACIÓN O REVISIÓN SE TIENE QUE BUSCAR EL TIPO
                IF (@TipoOperacion = 3 OR @TipoOperacion = 4) --> 3-- ES REVISIÓN  4-->ES APROBACIÓN --> TB --> EN_HistorialAprobacionesLineaTiempo(EN_TipoOperacion)
                BEGIN
                    IF @TipoOperacion = 3
                        SET @EstadoActual = 'REVISION';
                    IF @TipoOperacion = 4
                        SET @EstadoActual = 'APROBACION';
                    /*EL ENTREGABLABLE FINALIZA ESTADO REVISIÓN/APROBACIÓN, SE REGISTRA EL 100% DE AVANCE DEL SEGUIMIENTO DEL ENTREGABLE INSTANCIA*/
                    EXEC dbo.SP_EN_GuardarAvanceEntregableSeguimiento @EntregableInstanciaId = @idInstanciaEntregable, -- int
                                                                      @ClaveAvance = 'COMPLETADO',                     -- float
                                                                      @UsuarioId = @idUsuario,                         -- int
                                                                      @ContratoId = @idContrato,                       -- int
                                                                      @Estado = @EstadoActual,                         -- varchar(max)
                                                                      @TipoGuardado = 'SISTEMA',                       -- varchar(max)
                                                                      @Comentario = '';
                END;
            END;
        END;
        ELSE IF (@Rechazado = 1)
        BEGIN
            --EL ENTREGABLE ES RECHAZADO
            UPDATE dbo.EN_InstanciasEntregable
            SET BitContieneAcuse = 0,
                FechaRealEntregaRegulador = NULL
            WHERE idInstanciaEntregable = @idInstanciaEntregable;

            SELECT @ActividadSiguienteID = SiguienteActividadID
            FROM dbo.EN_Transicion
            WHERE ActividadInicialID = @ActividadIDActual
                  AND AccionID = 10002;

            SELECT @EstadoAprobado = EstadoID
            FROM EN_Actividad
            WHERE ActividadID = @ActividadIDActual;

            IF (@EstadoAprobado <> 10003)
            BEGIN
                SELECT @idTipoOperacion = tipoOperacion
                FROM dbo.EN_URLResponsablesEntregables
                WHERE ActividadID = @ActividadIDActual;
            END;
            ELSE
            BEGIN
                SET @idTipoOperacion = 5;
            END;

            IF @ActividadSiguienteID IS NOT NULL
            BEGIN
                UPDATE EN_InstanciasEntregable
                SET ActividadID = @ActividadSiguienteID,
					ModificadoEn = GETDATE()
                WHERE idInstanciaEntregable = @idInstanciaEntregable;

                SELECT @Para = CASE ISNULL(EXAE.idUsuario, '')
                                   WHEN '' THEN
                                       u.Usuario
                                   ELSE
                                       UXE.Usuario
                               END,
                       @NombreUsuario = CASE ISNULL(EXAE.idUsuario, '')
                                            WHEN '' THEN
                                                u.Nombre
                                            ELSE
                                                UXE.Nombre
                                        END,
                       @EsGrupo = CASE ISNULL(EXAE.idUsuario, '')
                                      WHEN '' THEN
                                          ISNULL(u.IsGrupo, 0)
                                      ELSE
                                          ISNULL(UXE.IsGrupo, 0)
                                  END
                FROM dbo.EN_Actividad A
                    JOIN dbo.AP_Usuario u
                        ON A.idUsuario = u.UsuarioID
                    LEFT JOIN dbo.EN_ExcepcionesActividad EXAE
                        ON EXAE.ActividadIDExcepcion = @ActividadIDeElaboracion
                    LEFT JOIN dbo.AP_Usuario UXE
                        ON EXAE.idUsuario = UXE.UsuarioID
                WHERE ActividadID = @ActividadIDeElaboracion;

                IF (@EsGrupo = 1) --SI ES GRUPO EL ELABORADOR, SOLO SE ENVIA AL USUARIO QUE REALIZO EL ENTREGABLE
                BEGIN

                    SELECT @Para = U.Usuario,
                           @NombreUsuario = U.Nombre
                    FROM EN_HistorialAprobacionesLineaTiempo HAL
                        JOIN AP_Usuario U
                            ON HAL.CreadoPor = U.UsuarioID
                    WHERE idInstanciaEntregable = @idInstanciaEntregable
                          AND IdLineaTiempo = @idVersion
                          AND idTipoOperacion = 2;

                END;


                EXEC [sp_EN_EnviaCorreosRevisionAprobacion] @idUsuario,
                                                            @idContrato,
                                                            @idInstanciaEntregable,
                                                            @idTipoOperacion,
                                                            '',
                                                            '',
                                                            @NombreInstancia,
                                                            @FechaInstancia,
                                                            @URLDetalle,
                                                            @Para,
                                                            @NombreUsuario,
                                                            13,
                                                            3;

                EXEC EN_GuardaHistorialLineaTiempo @idVersion,
                                                   @idInstanciaEntregable,
                                                   @idUsuario,
                                                   @contrato,
                                                   @Comentarios,
                                                   @Rechazado,
                                                   @TipoOperacion,
                                                   0,
                                                   'En este paso no se ingresa URL',
                                                   0;

                EXEC [sp_EN_EnviaCorreos] @idUsuario,
                                          @contrato,
                                          @idInstanciaEntregable,
                                          10005,
                                   @ActividadSiguienteID,
                                          @ActividadIDActual;

                /*EL ENTREGABLABLE SE RECHAZO DESDE APROBACIÓN O REVISIÓN O SE REINICIA, SE REGISTRA EL 0% DE AVANCE DEL SEGUIMIENTO SE REGRESA A 0%*/
                IF (@TipoOperacion = 5) --> 5 REINICIO --> TB --> (EN_TipoOperacion)
                BEGIN
                    SET @EstadoActual = 'REINICIO';

                    /*EL ENTREGABLABLE SE REINICIA DESDE EL ESTADO REVISIÓN/APROBACIÓN, SE REGISTRA EL 0% DE AVANCE DEL SEGUIMIENTO DEL ENTREGABLE INSTANCIA*/
                    EXEC dbo.SP_EN_GuardarAvanceEntregableSeguimiento @EntregableInstanciaId = @idInstanciaEntregable, -- int
                                                                      @ClaveAvance = '',                               -- float
                                                                      @UsuarioId = @idUsuario,                         -- int
                                                                      @ContratoId = @idContrato,                       -- int
                                                                      @Estado = @EstadoActual,                         -- varchar(max)
                                                                      @TipoGuardado = 'REINICIAR',                     -- varchar(max)
                                                                      @Comentario = 'SISTEMA';
                END;

				IF (@EstadoActual = 'REINICIO')
				BEGIN

					--DESACTIVACION DE SU HISTORIAL PARA NO MOSTRAR LAS URL ARCHIVO
					UPDATE EN_HistorialAprobacionesLineaTiempo
					SET Activo = 0
					WHERE idInstanciaEntregable = @idInstanciaEntregable AND 
						idTipoOperacion = 2 AND
						ContieneURLRepositorio = 1 AND
						Activo = 1;

					--DESACTIVACION DE SU HISTORIAL PARA NO MOSTRAR LAS URL ACUSE
					UPDATE EN_HistorialAprobacionesLineaTiempo
					SET Activo = 0
					WHERE idInstanciaEntregable = @idInstanciaEntregable AND 
						idTipoOperacion = 7 AND
						Activo = 1;

				END;
            END;
        END;
    END;
END;