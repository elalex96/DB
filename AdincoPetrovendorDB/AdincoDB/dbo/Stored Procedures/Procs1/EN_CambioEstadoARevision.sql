use Adinco
go
drop procedure if exists EN_CambioEstadoARevision
go
-- =============================================  
-- Author:   Daniel AC  
-- Update date: 20/10/2020  
-- Description: Se agrego métodos para avance de entregable instancia EQUINOR
-- ============================================= 
-- Author:   Luis David De La Cruz
-- Update date: 20/10/2020  
-- Description: Se agrego métodos para avance de entregable instancia EQUINOR
-- ============================================= 
CREATE PROCEDURE [dbo].[EN_CambioEstadoARevision] --10061,3,285713,16876,'',''
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT,
    @idContratoEntregable INT,
    @ComentarioUsuarioElaborador VARCHAR(500),
    @URLRepositorio VARCHAR(1500)
AS
BEGIN
    SET NOCOUNT ON;
    CREATE TABLE #URLResponsables
    (
        Id INT IDENTITY(1, 1),
        Enviado BIT,
        EnlaceDetalle VARCHAR(MAX),
        EnlaceAprobado VARCHAR(MAX),
        EnlaceRechazo VARCHAR(MAX),
        NombreInstancia VARCHAR(MAX),
        FechaInstancia VARCHAR(MAX),
        correos VARCHAR(MAX),
        NombreUsuario VARCHAR(MAX)
    );

    DECLARE @ActividadSiguienteID INT,
            @ActividadIDActual INT,
            @IdLineaTiempo INT,
            @idVersion INT,
            @NombreInstancia VARCHAR(MAX),
            @EnlaceDetalle VARCHAR(MAX),
            @EnlaceAprobado VARCHAR(MAX),
            @EnlaceRechazo VARCHAR(MAX),
            @FechaInstancia VARCHAR(MAX),
            @Para VARCHAR(1000),
            @NombreUsuario VARCHAR(2500),
            @ContieneURLRepositorio BIT,
            @CountRevisores INT,
            @IsUsuarioRev INT,
            @IsUsuarioApro INT,
            @IsUsuarioElab INT,
            @IdUrl INT = 0,
            @EsEntregableGrupo INT = 0,
            @IdGrupo INT = 0,
            @BitPasaAprobacion INT = 0;

    SELECT @ActividadIDActual = ActividadID
    FROM dbo.EN_InstanciasEntregable
    WHERE idInstanciaEntregable = @idInstanciaEntregable;

    SELECT @ActividadSiguienteID = SiguienteActividadID
    FROM dbo.EN_Transicion
    WHERE ActividadInicialID = @ActividadIDActual;

    SELECT @CountRevisores = COUNT(1)
    FROM dbo.EN_Actividad
    WHERE IdContratoEntregable = @idContratoEntregable
          AND EstadoID = 10001;


    IF (@CountRevisores = 1)
    BEGIN

        SELECT @IsUsuarioElab = CASE
                                    WHEN exa.ActividadIDExcepcion IS NOT NULL THEN
                                        exa.idUsuario
                                    ELSE
                                        a.idUsuario
                                END
        FROM dbo.EN_Actividad a
            LEFT JOIN dbo.EN_ExcepcionesActividad exa
                ON a.ActividadID = exa.ActividadIDExcepcion
                   AND exa.IdInstanciasEntregables = @idInstanciaEntregable
        WHERE a.IdContratoEntregable = @idContratoEntregable
              AND a.EstadoID = 10000;


        SELECT @IsUsuarioRev = CASE
                                   WHEN exa.ActividadIDExcepcion IS NOT NULL THEN
                                       exa.idUsuario
                                   ELSE
                                       a.idUsuario
                               END
        FROM dbo.EN_Actividad a
            LEFT JOIN dbo.EN_ExcepcionesActividad exa
                ON a.ActividadID = exa.ActividadIDExcepcion
                   AND exa.IdInstanciasEntregables = @idInstanciaEntregable
        WHERE a.IdContratoEntregable = @idContratoEntregable
              AND a.EstadoID = 10001;


        SELECT @IsUsuarioApro = CASE
                                    WHEN exa.ActividadIDExcepcion IS NOT NULL THEN
                                        exa.idUsuario
                                    ELSE
                                        a.idUsuario
                                END
        FROM dbo.EN_Actividad a
            LEFT JOIN dbo.EN_ExcepcionesActividad exa
                ON a.ActividadID = exa.ActividadIDExcepcion
                   AND exa.IdInstanciasEntregables = @idInstanciaEntregable
        WHERE a.IdContratoEntregable = @idContratoEntregable
              AND a.EstadoID = 10002;
    END;

    SELECT @EsEntregableGrupo = CASE ISNULL(exa.idUsuario, '')
                                    WHEN '' THEN
                                        ISNULL(U.IsGrupo, 0)
                                    ELSE
                                        ISNULL(UXA.IsGrupo, 0)
                                END,
           @IdGrupo = CASE
                          WHEN exa.ActividadIDExcepcion IS NOT NULL THEN
                              exa.idUsuario
                          ELSE
                              a.idUsuario
                      END
    FROM dbo.EN_Actividad a
        JOIN EN_ContratoEntregable CE
            ON a.IdContratoEntregable = CE.IdContratoEntregable
               AND CE.IdContrato = @idContrato
        JOIN AP_Usuario U
            ON a.idUsuario = U.UsuarioID
        LEFT JOIN dbo.EN_ExcepcionesActividad exa
            ON a.ActividadID = exa.ActividadIDExcepcion
               AND exa.IdInstanciasEntregables = @idInstanciaEntregable
        LEFT JOIN AP_Usuario UXA
            ON exa.idUsuario = UXA.UsuarioID
    WHERE a.IdContratoEntregable = @idContratoEntregable
          AND CE.IdContrato = @idContrato	--10112 --ÁREA 20 SHELL
          AND a.EstadoID = 10000;


    IF (@EsEntregableGrupo = 1)
    BEGIN
        IF ((SELECT COUNT(1)
             FROM EN_GruposUsuarios
             WHERE IdGrupo = @IdGrupo
             AND IdUsuario = @idUsuario
             AND IdContrato = @idContrato) > 0 and (@IsUsuarioRev = @IsUsuarioElab))
        BEGIN
            SET @BitPasaAprobacion = 1;
        END;
        ELSE
        BEGIN
            SET @BitPasaAprobacion = 0;
        END;
    END;


    IF (
           (
               @IsUsuarioElab = @IsUsuarioRev
               AND @IsUsuarioElab = @IsUsuarioApro
           )
           OR (@BitPasaAprobacion = 1)
       )
    BEGIN
        --select '[sp_En_SubeHistoricoAprueba]'    
        --Finalizar el entregable
        EXEC [sp_En_SubeHistoricoAprueba] @idUsuario,
                                          @idContrato,
                                          @idInstanciaEntregable,
                                          @idContratoEntregable,
                                          @ComentarioUsuarioElaborador,
                                          @URLRepositorio;
        /*EL ENTREGABLABLE FINALIZA ESTADO APROBACIÓN, SE REGISTRA EL 100% DE AVANCE DEL SEGUIMIENTO DEL ENTREGABLE INSTANCIA*/
        EXEC dbo.SP_EN_GuardarAvanceEntregableSeguimiento @EntregableInstanciaId = @idInstanciaEntregable, -- int
                                                          @ClaveAvance = 'COMPLETADO',                     -- float
                                                          @UsuarioId = @idUsuario,                         -- int
                                                          @ContratoId = @idContrato,                       -- int
                                                          @Estado = 'APROBACION',                          -- varchar(max)
                                                          @TipoGuardado = 'SISTEMA',                       -- varchar(max)
                                                          @Comentario = '';                                -- varchar(max)

    END;
    ELSE
    BEGIN
        IF (@IsUsuarioElab = @IsUsuarioRev)
        BEGIN
            --select '[sp_En_DirectoAcprobacion]'
            --hacer un clone del sp
            EXEC [sp_En_DirectoAcprobacion] @idUsuario,
                                            @idContrato,
                                            @idInstanciaEntregable,
                                            @idContratoEntregable,
                                            @ComentarioUsuarioElaborador,
                                            @URLRepositorio;

   /*EL ENTREGABLABLE FINALIZA ESTADO REVISIÓN, SE REGISTRA EL 100% DE AVANCE DEL SEGUIMIENTO DEL ENTREGABLE INSTANCIA*/
            EXEC dbo.SP_EN_GuardarAvanceEntregableSeguimiento @EntregableInstanciaId = @idInstanciaEntregable, -- int
                                                              @ClaveAvance = 'COMPLETADO',                     -- float
                                                              @UsuarioId = @idUsuario,                         -- int
                                                              @ContratoId = @idContrato,                       -- int
                                                              @Estado = 'REVISION',                            -- varchar(max)
                                                              @TipoGuardado = 'SISTEMA',                       -- varchar(max)
                                                              @Comentario = '';
        END;
        ELSE
        BEGIN
            --select 'else'
            UPDATE EN_InstanciasEntregable
            SET ActividadID = @ActividadSiguienteID,
                FechaElaboro = GETDATE()
            WHERE idInstanciaEntregable = @idInstanciaEntregable;

            SELECT @IdLineaTiempo = ISNULL(MAX(IdLineaTiempo), 0)
            FROM dbo.EN_HistorialAprobacionesLineaTiempo;

            SET @idVersion = (@IdLineaTiempo + 1);

            IF @ComentarioUsuarioElaborador = ''
            BEGIN
                SET @ComentarioUsuarioElaborador = 'Usuario elaborador a enviado a revisión el entregable';
            END;

            IF (@URLRepositorio = '' OR @URLRepositorio IS NULL)
            BEGIN
                SET @URLRepositorio = 'No se ingreso URL de repositorio';
                SET @ContieneURLRepositorio = 0;
            END;
            ELSE
            BEGIN
                SET @ContieneURLRepositorio = 1;
            END;

            EXEC EN_GuardaHistorialLineaTiempo @idVersion,
                                               @idInstanciaEntregable,
                                               @idUsuario,
                                               @idContrato,
                                               @ComentarioUsuarioElaborador,
                                               0,
                                               2,
                                               0,
                                               @URLRepositorio,
                                               @ContieneURLRepositorio;

            EXEC EN_GuardaDocumentosPorVersion @idVersion,
                                               @idInstanciaEntregable,
                                               @idUsuario,
                                               @idContrato;

            INSERT INTO #URLResponsables
            (
                EnlaceDetalle,
                EnlaceAprobado,
                EnlaceRechazo,
                NombreInstancia,
                FechaInstancia,
                correos,
                NombreUsuario
            )
            SELECT EnlaceDetalle,
                   EnlaceAprobado,
                   EnlaceRechazo,
                   NombreInstancia,
                   FechaInstancia,
                   correos,
                   NombreUsuario
            FROM dbo.EN_URLResponsablesEntregables
            WHERE ActividadID = @ActividadSiguienteID
                  AND idInstanciaEntregable = @idInstanciaEntregable;



            WHILE
            (SELECT COUNT(1) FROM #URLResponsables WHERE Enviado IS NULL) > 0
            BEGIN

                SET @IdUrl = @IdUrl + 1;

                SELECT TOP 1
                       @EnlaceDetalle = EnlaceDetalle,
                       @EnlaceAprobado = EnlaceAprobado,
                       @EnlaceRechazo = EnlaceRechazo,
                       @NombreInstancia = NombreInstancia,
                       @FechaInstancia = FechaInstancia,
                 @Para = correos,
                       @NombreUsuario = NombreUsuario
                FROM #URLResponsables
                WHERE Id = @IdUrl
                      AND Enviado IS NULL
                ORDER BY NombreUsuario DESC;

                EXEC [sp_EN_EnviaCorreosRevisionAprobacion] @idUsuario,
                                                            @idContrato,
                                                            @idInstanciaEntregable,
                                                            3,
                                                            @EnlaceAprobado,
                                                            @EnlaceRechazo,
                                                            @NombreInstancia,
                                                            @FechaInstancia,
                                                            @EnlaceDetalle,
                                                            @Para,
                                                            @NombreUsuario,
                                                            12,
                                                            0;

                UPDATE #URLResponsables
                SET Enviado = 1
                WHERE Id = @IdUrl
                      AND Enviado IS NULL;
            END;

            EXEC [sp_EN_EnviaCorreos] @idUsuario,
                                      @idContrato,
                                      @idInstanciaEntregable,
                                      10002,
                                      @ActividadSiguienteID,
                                      @ActividadIDActual;

            EXEC [sp_EN_EnviaCorreos] @idUsuario,
                                      @idContrato,
                                      @idInstanciaEntregable,
                                      10000,
                                      @ActividadSiguienteID,
                                      @ActividadIDActual; --Correo para el elaborador, cumplio su trabajo

            /*EL ENTREGABLABLE FINALIZA ESTADO ELABORACIÓN, SE REGISTRA EL 100% DE AVANCE DEL SEGUIMIENTO DEL ENTREGABLE INSTANCIA*/
            EXEC dbo.SP_EN_GuardarAvanceEntregableSeguimiento @EntregableInstanciaId = @idInstanciaEntregable, -- int
                                                              @ClaveAvance = 'COMPLETADO',                     -- float
                                                              @UsuarioId = @idUsuario,                         -- int
                                                              @ContratoId = @idContrato,                       -- int
                                                              @Estado = 'ELABORACION',                         -- varchar(max)
                                                              @TipoGuardado = 'SISTEMA',                       -- varchar(max)
                                                              @Comentario = '';
        END;

    END;
END;
