-- =============================================
-- Author:		Reyna Olvera
-- Create date: 10/04/2018
-- Description:solo cambia el estatus para la instancia 
-- =============================================
CREATE PROCEDURE [dbo].[sp_En_SubeHistoricoAprueba] --10061,3,46190,16612
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT,
    @idContratoEntregable INT,
    @ComentarioUsuarioElaborador VARCHAR(500),
    @URLRepositorio VARCHAR(1500)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ActividadSiguienteID INT,
            @ActividadIDActual INT,
            @IdLineaTiempo INT,
            @idVersion INT,
            @ContieneURLRepositorio BIT,
            @idUsuarioRevisor INT,
            @idUsuarioAprobador INT;

    SELECT @ActividadIDActual = ActividadID
    FROM dbo.EN_InstanciasEntregable
    WHERE idInstanciaEntregable = @idInstanciaEntregable;

    SELECT TOP 1
           @idUsuarioRevisor = CASE
                                   WHEN exa.ActividadIDExcepcion IS NOT NULL THEN
                                       exa.idUsuario
                                   ELSE
                                       a.idUsuario
                               END
    FROM dbo.EN_Actividad a
    LEFT JOIN dbo.EN_ExcepcionesActividad exa ON a.ActividadID = exa.ActividadIDExcepcion
                                                 AND exa.IdInstanciasEntregables = @idInstanciaEntregable
    WHERE a.IdContratoEntregable = @idContratoEntregable
          AND a.EstadoID = 10001;


    SELECT @ActividadSiguienteID = ActividadID,
           @idUsuarioAprobador = CASE
                                     WHEN exa.ActividadIDExcepcion IS NOT NULL THEN
                                         exa.idUsuario
                                     ELSE
                                         a.idUsuario
                                 END
    FROM dbo.EN_Actividad a
    LEFT JOIN dbo.EN_ExcepcionesActividad exa ON a.ActividadID = exa.ActividadIDExcepcion
                                                 AND exa.IdInstanciasEntregables = @idInstanciaEntregable
    WHERE a.IdContratoEntregable = @idContratoEntregable
          AND a.EstadoID = 10003;

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
	/* 10,003*/--Registro de elaboración
    EXEC EN_GuardaHistorialLineaTiempo @idVersion,
                                       @idInstanciaEntregable,
                                       @idUsuario,
                                       @idContrato,
                                       @ComentarioUsuarioElaborador,
                                       0,
                                       2, --Elaborador
                                       0,
                                       @URLRepositorio,
                                       @ContieneURLRepositorio;


    EXEC EN_GuardaHistorialLineaTiempo @idVersion, --Revisión
                                       @idInstanciaEntregable,
                                       @idUsuarioRevisor,
                                       @idContrato,
                                       '',
                                       0,
                                       3, --Revisor
                                       0,
 'En este paso no se ingresa URL (Aprobado Directamente)',
                                       0;
	/*Cuando sea caso 10,002 omitir este paso*/
    EXEC EN_GuardaHistorialLineaTiempo @idVersion, --Aprobación
                                       @idInstanciaEntregable,
                                       @idUsuarioAprobador,
                                       @idContrato,
                                       '',
                                       0,
                                       4,--Aprobador
                                       0,
                                       'En este paso no se ingresa URL (Aprobado Directamente)',
                                       0;
--------------------------------------------------------------------------------------------------------

    EXEC EN_GuardaDocumentosPorVersion @idVersion,
                                       @idInstanciaEntregable,
                                       @idUsuario,
                                       @idContrato;
END;