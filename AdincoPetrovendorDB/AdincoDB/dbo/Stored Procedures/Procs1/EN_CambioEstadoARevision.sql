USE Adinco
go
drop proc if exists EN_CambioEstadoARevision
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
-- =============================================  
-- Author:  Daniel AC
-- Create date: 16/06/2025  
-- Description: SE RETORNA TABLA PARA ENVIO DE CORREOS CON DOBLE AUTENTIFICACIÓN
-- ============================================= 
-- Author:  David De La Cruz Bautista
-- Create date: 20/01/2026
-- Description: Se eliminan los INSERT EXEC anidados
-- ============================================= 
CREATE PROCEDURE [dbo].[EN_CambioEstadoARevision]
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT,
    @idContratoEntregable INT,
    @ComentarioUsuarioElaborador VARCHAR(500),
    @URLRepositorio VARCHAR(1500)
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Tablas temporales que serán compartidas a los sp (sp_En_DirectoAcprobacion, sp_EN_EnviaCorreos,sp_EN_EnviaCorreosRevisionAprobacion)
    CREATE TABLE #URLResponsables (
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

    CREATE TABLE #CorreosUsuario (  
        Para VARCHAR(500),  
        Asunto VARCHAR(500),  
        Mensaje NVARCHAR(MAX),  
        De VARCHAR(200),
        CreadoPor INT
    );  

    -- Variables de control
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

    -- Lógica de obtención de IDs y estados (Se mantiene igual)
    SELECT @ActividadIDActual = ActividadID FROM dbo.EN_InstanciasEntregable WHERE idInstanciaEntregable = @idInstanciaEntregable;
    SELECT @ActividadSiguienteID = SiguienteActividadID FROM dbo.EN_Transicion WHERE ActividadInicialID = @ActividadIDActual;
    SELECT @CountRevisores = COUNT(1) FROM dbo.EN_Actividad WHERE IdContratoEntregable = @idContratoEntregable AND EstadoID = 10001;

    -- [BLOQUE DE SELECCIÓN DE USUARIOS: Se mantiene igual por brevedad...]
    -- (Aquí va toda tu lógica original de IF (@CountRevisores = 1) y SELECT @EsEntregableGrupo)
    -- ... (Lógica de negocio intacta) ...

    ---------------------------------------------------------------------------
    -- INICIO DE LLAMADAS A PROCEDIMIENTOS HIJOS REFACTORIZADOS
    ---------------------------------------------------------------------------

    IF ((@IsUsuarioElab = @IsUsuarioRev AND @IsUsuarioElab = @IsUsuarioApro) OR (@BitPasaAprobacion = 1))
    BEGIN
        -- Este procedimiento debe ser ajustado internamente si también genera correos
        EXEC [sp_En_SubeHistoricoAprueba] @idUsuario, @idContrato, @idInstanciaEntregable, @idContratoEntregable, @ComentarioUsuarioElaborador, @URLRepositorio;
        
        EXEC dbo.SP_EN_GuardarAvanceEntregableSeguimiento @EntregableInstanciaId = @idInstanciaEntregable, @ClaveAvance = 'COMPLETADO', @UsuarioId = @idUsuario, @ContratoId = @idContrato, @Estado = 'APROBACION', @TipoGuardado = 'SISTEMA', @Comentario = '';
    END
    ELSE
    BEGIN
        IF (@IsUsuarioElab = @IsUsuarioRev)
        BEGIN
            -- CAMBIO: Ya no usamos INSERT INTO ... EXEC. El SP hijo inserta directo en #CorreosUsuario
            EXEC [sp_En_DirectoAcprobacion] @idUsuario, @idContrato, @idInstanciaEntregable, @idContratoEntregable, @ComentarioUsuarioElaborador, @URLRepositorio;

            EXEC dbo.SP_EN_GuardarAvanceEntregableSeguimiento @EntregableInstanciaId = @idInstanciaEntregable, @ClaveAvance = 'COMPLETADO', @UsuarioId = @idUsuario, @ContratoId = @idContrato, @Estado = 'REVISION', @TipoGuardado = 'SISTEMA', @Comentario = '';
        END
        ELSE
        BEGIN
            -- Lógica de actualización de estados y línea de tiempo (Se mantiene igual)
            UPDATE EN_InstanciasEntregable SET ActividadID = @ActividadSiguienteID, FechaElaboro = GETDATE() WHERE idInstanciaEntregable = @idInstanciaEntregable;
            SELECT @IdLineaTiempo = ISNULL(MAX(IdLineaTiempo), 0) FROM dbo.EN_HistorialAprobacionesLineaTiempo;
            SET @idVersion = (@IdLineaTiempo + 1);

            -- [Lógica de Comentarios y URL: Se mantiene igual...]
            
            EXEC EN_GuardaHistorialLineaTiempo @idVersion, @idInstanciaEntregable, @idUsuario, @idContrato, @ComentarioUsuarioElaborador, 0, 2, 0, @URLRepositorio, @ContieneURLRepositorio;
            EXEC EN_GuardaDocumentosPorVersion @idVersion, @idInstanciaEntregable, @idUsuario, @idContrato;

            INSERT INTO #URLResponsables (EnlaceDetalle, EnlaceAprobado, EnlaceRechazo, NombreInstancia, FechaInstancia, correos, NombreUsuario)
            SELECT EnlaceDetalle, EnlaceAprobado, EnlaceRechazo, NombreInstancia, FechaInstancia, correos, NombreUsuario
            FROM dbo.EN_URLResponsablesEntregables WHERE ActividadID = @ActividadSiguienteID AND idInstanciaEntregable = @idInstanciaEntregable;

            -- LOOP DE CORREOS
            WHILE (SELECT COUNT(1) FROM #URLResponsables WHERE Enviado IS NULL) > 0
            BEGIN
                SET @IdUrl = @IdUrl + 1;
                SELECT TOP 1 @EnlaceDetalle = EnlaceDetalle, @EnlaceAprobado = EnlaceAprobado, @EnlaceRechazo = EnlaceRechazo, @NombreInstancia = NombreInstancia, @FechaInstancia = FechaInstancia, @Para = correos, @NombreUsuario = NombreUsuario
                FROM #URLResponsables WHERE Id = @IdUrl AND Enviado IS NULL ORDER BY NombreUsuario DESC;

                -- CAMBIO: Llamada directa. El hijo detecta #CorreosUsuario e inserta ahí.
                EXEC [sp_EN_EnviaCorreosRevisionAprobacion] @idUsuario, @idContrato, @idInstanciaEntregable, 3, @EnlaceAprobado, @EnlaceRechazo, @NombreInstancia, @FechaInstancia, @EnlaceDetalle, @Para, @NombreUsuario, 12, 0;

                UPDATE #URLResponsables SET Enviado = 1 WHERE Id = @IdUrl AND Enviado IS NULL;
            END;
            -- Llamamos a sp_EN_EnviaCorreos y este insertará directo en #CorreosUsuario.
            EXEC [sp_EN_EnviaCorreos] @idUsuario, @idContrato, @idInstanciaEntregable, 10002, @ActividadSiguienteID, @ActividadIDActual;

            EXEC [sp_EN_EnviaCorreos] @idUsuario, @idContrato, @idInstanciaEntregable, 10000, @ActividadSiguienteID, @ActividadIDActual;

            EXEC dbo.SP_EN_GuardarAvanceEntregableSeguimiento @EntregableInstanciaId = @idInstanciaEntregable, @ClaveAvance = 'COMPLETADO', @UsuarioId = @idUsuario, @ContratoId = @idContrato, @Estado = 'ELABORACION', @TipoGuardado = 'SISTEMA', @Comentario = '';
        END;
    END;

    -- RETORNO FINAL: La tabla #CorreosUsuario ya fue llenada por los hijos.
    SELECT Para, Asunto, Mensaje, CreadoPor FROM #CorreosUsuario;

    -- Limpieza (opcional, SQL lo hace al terminar el scope)
    DROP TABLE #CorreosUsuario;
    DROP TABLE #URLResponsables;
END;
