
-- =============================================
-- Author:		Reynha Olvera
-- Create date:20180927
-- Description:	Envia correos a receptores de alterna, modulo entregables
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_EnviaCorreosRevisionAprobacion] -- 10061,3, 46191,4,'','','HOLA','Nomeinstancia','20190227','reyna.olvera@adinco.mx','Reyna',13,2
    @idUsuario INT,
    @idContrato INT,
    @idInstanciaEntregable INT,
    @idTipoOperacion INT,
    @EnlaceAprobado NVARCHAR(MAX),
    @EnlaceRechazo NVARCHAR(MAX),
    @NombreInstancia NVARCHAR(MAX), 
    @FechaInstancia NVARCHAR(MAX),
    @enlaceDetalle NVARCHAR(MAX),
    @Para NVARCHAR(MAX),
    @NombreUsuario NVARCHAR(MAX),
    @TipoCorreo INT,
    @Estatus INT
AS
BEGIN
    SET NOCOUNT ON;
    SET LANGUAGE Spanish;

    DECLARE @español        NVARCHAR(50),
            @ingles         NVARCHAR(50),
            @Correo         NVARCHAR(MAX),
            @Asunto         NVARCHAR(MAX),
            @CuentaRegistro NVARCHAR(MAX),
            @IdNotificacion BIGINT,
            @EstatusEspañol NVARCHAR(MAX),
            @EstatusIngles  NVARCHAR(MAX),
			@NumeroContrato VARCHAR(100);

	SELECT @NumeroContrato= NumeroContrato 
	FROM CO_Contrato
	WHERE IdContrato = @idContrato

	SET @NombreInstancia=@NombreInstancia+'-'+@NumeroContrato

    IF (@idTipoOperacion = 3)
    BEGIN
        SET @español = 'Revisión';
        SET @ingles = 'Review';
    END;
    IF (@idTipoOperacion = 4 OR @idTipoOperacion = 5 )
    BEGIN
        SET @español = 'Aprobación';
        SET @ingles = 'Acceptance';
    END;

    IF (@TipoCorreo = 12) --Enviaa notificaciones 
    BEGIN
		--select 'sp_EN_EnviaCorreosRevisionAprobacion. @TipoCorreo = 12'

        SELECT      @Correo	=	Correo.HTML,
                    @Asunto	=	Correo.Asunto,
                    @CuentaRegistro	=	servidor.CuentaRegistro
          FROM      Adinco.dbo.MA_Correo	Correo

		  JOIN	dbo.MA_ServidorDeCorreo	servidor
            ON	Correo.IdServidor	=	servidor.IdServidor

         WHERE      Correo.IdCorreo = @TipoCorreo;

		 --select		español				=	@español, 		 
			--		NombreInstancia		=	@NombreInstancia,	
			--		enlaceDetalle		=	@enlaceDetalle, 
			--		EnlaceAprobado		=	@EnlaceAprobado, 
			--		EnlaceRechazo		=	@EnlaceRechazo, 
			--		FechaInstancia		=	@FechaInstancia, 
			--		NombreInstancia		=	@NombreInstancia, 
			--		NombreUsuario		=	@NombreUsuario, 
			--		ingles				=	@ingles

        SET @Asunto = REPLACE(@Asunto, '##TIPO_APROBACION_E##', isnull(@español,''));
        SET @Asunto = REPLACE(@Asunto, '##COMENTARIOGENERAL##', isnull(@NombreInstancia,''));
        SET @Correo = REPLACE(@Correo, '##ENLACE_DETALLE##', isnull(@enlaceDetalle,''));
        SET @Correo = REPLACE(@Correo, '##ENLACE_APROBAR##', isnull(@EnlaceAprobado,''));
        SET @Correo = REPLACE(@Correo, '##ENLACE_RECHAZAR##', isnull(@EnlaceRechazo,''));
        SET @Correo = REPLACE(@Correo, '##NOMBRE_INSTANCIA##', isnull(@FechaInstancia,''));
        SET @Correo = REPLACE(@Correo, '##COMENTARIOGENERAL##', isnull(@NombreInstancia,''));
        SET @Correo = REPLACE(@Correo, '##NOMBRE_USUARIO##', isnull(@NombreUsuario,''));

        SET @Correo = REPLACE(@Correo, '##TIPO_APROBACION_E##', isnull(@español,''));
        SET @Correo = REPLACE(@Correo, '##TIPO_APROBACION_I##', isnull(@ingles,''));
        SET @Correo = REPLACE(@Correo, '##TIPO_OPERACION_E##', isnull(@español,''));
        SET @Correo = REPLACE(@Correo, '##TIPO_OPERACION_I##', isnull(@ingles,''));

		--select [Correo] = @Correo

    END;
    IF (@TipoCorreo	=	13) --Avisos a Elaborador como va el flujo de aprobaciobnes
    BEGIN
		--select 'sp_EN_EnviaCorreosRevisionAprobacion. @TipoCorreo = 13'

        SELECT      @Correo	=	correo.HTML,
                    @Asunto	=	correo.Asunto,
                    @CuentaRegistro	=	servidor.CuentaRegistro
          FROM	Adinco.dbo.MA_Correo	correo

		  JOIN	dbo.MA_ServidorDeCorreo	servidor
            ON	correo.IdServidor	=	servidor.IdServidor 

         WHERE	correo.IdCorreo	=	@TipoCorreo;


        IF (@Estatus	=	2) --Aprobado/rechazado
        BEGIN
            SET @EstatusEspañol = 'Aprobado';
            SET @EstatusIngles = 'Approved';
        END;

        IF (@Estatus	=	3)
        BEGIN
            SET @EstatusEspañol = 'Rechazado';
            SET @EstatusIngles = 'Rejected';
        END;

        SET @Asunto = REPLACE(@Asunto, '##TIPO_APROBACION_E##', @español);
        SET @Asunto = REPLACE(@Asunto, '##ESTATUS_E##', @EstatusEspañol);
        SET @Correo = REPLACE(@Correo, '##NOMBRE_USUARIO##', @NombreUsuario);
        SET @Correo = REPLACE(@Correo, '##NOMBRE_INSTANCIA##', @FechaInstancia);
        SET @Correo = REPLACE(@Correo, '##ESTATUS_E##', @EstatusEspañol);
        SET @Correo = REPLACE(@Correo, '##ESTATUS_I##', @EstatusIngles);
        SET @Correo = REPLACE(@Correo, '##COMENTARIOGENERAL##', @NombreInstancia);
        SET @Correo = REPLACE(@Correo, '##URL_TAREA##', @enlaceDetalle);
    END;

    SET @IdNotificacion = (SELECT MAX(IdNotificacion) FROM Adinco.dbo.S_Notificacion) + 1;
	

	--select [sp_EN_EnviaCorreosRevisionAprobacion.Correo] = @Correo
    INSERT INTO Adinco.dbo.S_Notificacion (IdNotificacion,
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
                                           De)
    VALUES (@IdNotificacion, 
            @Para,
			SUBSTRING( RTRIM(RTRIM(REPLACE(REPLACE(@Asunto, CHAR(10), ' '), CHAR(13), ' '))),0,500), 
            @Correo, 
            GETDATE(), 
            0,
            NULL, 
            @idUsuario,
            GETDATE(), 
            @idUsuario, 
            GETDATE(), 
            @CuentaRegistro 
        );
END;
