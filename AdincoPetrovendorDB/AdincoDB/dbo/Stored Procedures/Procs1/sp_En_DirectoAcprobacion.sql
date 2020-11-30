
create proc sp_En_DirectoAcprobacion
(
	@idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT,
    @idContratoEntregable INT,
    @ComentarioUsuarioElaborador VARCHAR(500),
    @URLRepositorio VARCHAR(1500)
)
as
begin
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


	declare		@EnlaceDetalle		nvarchar(max),
				@EnlaceAprobado		nvarchar(max),
				@EnlaceRechazo		nvarchar(max),
				@Para				nvarchar(max),
				@NombreUsuario		nvarchar(max),
				@idTipoOperacion	int,
				@NombreInstancia	nvarchar(max),
				@FechaInstancia		nvarchar(max)

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

	--select * from dbo.EN_URLResponsablesEntregables
 --   WHERE		ActividadID							=	@ActividadSiguienteID
	--and			idInstanciaEntregable				=	@idInstanciaEntregable

    --SELECT		@idTipoOperacion					=   tipoOperacion
    --FROM		dbo.EN_URLResponsablesEntregables
    --WHERE		ActividadID							=   @ActividadIDActual;

	--select [sp_En_DirectoAcprobacion.idTipoOperacion] = @idTipoOperacion

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
    EXEC [sp_EN_EnviaCorreos]	@idUsuario,
								@idContrato,
								@idInstanciaEntregable,
								10000,
								@ActividadSiguienteID,
								@ActividadIDActual;--Correo para el elaborador, cumplio su trabajo
    
    
  
  


END;