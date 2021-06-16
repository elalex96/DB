
CREATE PROCEDURE sp_En_DirectoAcprobacion
(
	@idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT,
    @idContratoEntregable INT,
    @ComentarioUsuarioElaborador VARCHAR(500),
    @URLRepositorio VARCHAR(1500)
)
AS
BEGIN
 SET NOCOUNT ON;
    DECLARE @ActividadSiguienteID INT,
            @ActividadIDActual INT,
            @IdLineaTiempo INT,
            @idVersion INT,
            @ContieneURLRepositorio BIT,
            @idUsuarioRevisor INT,
            @idUsuarioAprobador INT,
			@EnlaceDetalle		VARCHAR(max),
			@EnlaceAprobado		VARCHAR(max),
			@EnlaceRechazo		VARCHAR(max),
			@Para				VARCHAR(1000),
			@NombreUsuario		VARCHAR(1500),
			@idTipoOperacion	int,
			@NombreInstancia	VARCHAR(max),
			@FechaInstancia		VARCHAR(1500),
			@EsEntregableGrupo INT = 0,
            @IdGrupo INT = 0

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
                                 END,
			@EsEntregableGrupo = CASE ISNULL(exa.idUsuario, '')
                                    WHEN '' THEN
                                        ISNULL(U.IsGrupo, 0)
                                    ELSE
                                        ISNULL(UXA.IsGrupo, 0)
                                END,
           @IdGrupo	=	CASE
                          WHEN exa.ActividadIDExcepcion IS NOT NULL THEN
                              exa.idUsuario
                          ELSE
                              a.idUsuario
                      END
    FROM dbo.EN_Actividad a
	JOIN AP_Usuario U
            ON a.idUsuario = U.UsuarioID
    LEFT JOIN dbo.EN_ExcepcionesActividad exa ON a.ActividadID = exa.ActividadIDExcepcion
                                                 AND exa.IdInstanciasEntregables = @idInstanciaEntregable
	LEFT JOIN AP_Usuario UXA
            ON exa.idUsuario = UXA.UsuarioID
    WHERE a.IdContratoEntregable = @idContratoEntregable
          AND a.EstadoID = 10002;

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
									  'En este paso no se ingresa URL (Revisado Directamente)',
                                       0;
	
--------------------------------------------------------------------------------------------------------
   EXEC EN_GuardaDocumentosPorVersion @idVersion,
                                       @idInstanciaEntregable,
                                       @idUsuario,
                                       @idContrato;
------------------------------------------------------------------------------------------------------
      SELECT	@EnlaceDetalle						=	EnlaceDetalle,
				@EnlaceAprobado						=   EnlaceAprobado,
				@EnlaceRechazo						=   EnlaceRechazo,
				@Para								=   correos,
				@NombreUsuario						=   NombreUsuario,
				@idTipoOperacion					=   tipoOperacion,
				@NombreInstancia					=	NombreInstancia,
				@FechaInstancia						=	FechaInstancia
    FROM		dbo.EN_URLResponsablesEntregables
    WHERE		ActividadID							=	@ActividadSiguienteID
	and			idInstanciaEntregable				=	@idInstanciaEntregable

IF @EsEntregableGrupo = 0
BEGIN
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
END
ELSE
-- SE DEBEN ENVIAR CORREOS A TODOS LOS APROBADORES DEL GRUPO DE USUARIOS
BEGIN
	SELECT @Para = '', @NombreUsuario = ''
-- VEMOS SI SE ENVIA EL CORREO CON MULTIPLES DESTINATARIOS
	SELECT
		@Para = U.Usuario + ';' + @Para,
		@NombreUsuario = U.Nombre + ' / ' + @NombreUsuario
	FROM
		EN_GruposUsuarios	GU
	JOIN
		AP_Usuario	U
		ON	GU.IdUsuario	=	U.UsuarioID
	WHERE
		GU.IdGrupo	=	@IdGrupo

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

END
  
EXEC [sp_EN_EnviaCorreos]	@idUsuario,
							@idContrato,
							@idInstanciaEntregable,
							10000,
							@ActividadSiguienteID,
							@ActividadIDActual;--Correo para el elaborador, cumplio su trabajo  


END;
