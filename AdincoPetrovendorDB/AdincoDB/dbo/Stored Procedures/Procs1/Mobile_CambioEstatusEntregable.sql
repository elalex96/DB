CREATE PROCEDURE [dbo].[Mobile_CambioEstatusEntregable]
    @idUsuario INT,
    @idContrato INT,
    @InstanciaEntregableId INT,
    @Comentarios VARCHAR(MAX),
    @TipoOperacion INT,
    @Rechazado BIT,
    @URLDetalle VARCHAR(MAX)
AS
BEGIN
    
    SET NOCOUNT ON;

     DECLARE 
			@idVersion INT,
            @contrato INT,
            @ActividadSiguienteID INT,
            @ActividadIDActual INT,
            @NombreInstancia NVARCHAR(MAX),
            @EnlaceDetalle NVARCHAR(MAX),
            @EnlaceAprobado NVARCHAR(MAX),
            @EnlaceRechazo NVARCHAR(MAX),
            @FechaInstancia NVARCHAR(MAX),
            @Para NVARCHAR(MAX),
            @NombreUsuario NVARCHAR(MAX),
            @idTipoOperacion INT,
            @ActividadIDeElaboracion INT,
            @idContratoEntregable INT,
            @usuarioResponsable INT,
            @EstadoI INT,
            @EstadoAprobado INT,
            @EsUsuarioAprobador INT,
            @EsGrupo INT,
            @IsAdmin INT;

    SELECT  
		TOP 1   @idVersion  =   IdLineaTiempo
    FROM    
		dbo.EN_HistorialAprobacionesLineaTiempo
    WHERE   
		idInstanciaEntregable = @InstanciaEntregableId
    ORDER   BY  CreadoEn    DESC;


    SELECT  
		@contrato   =   IdContrato,
        @idContratoEntregable   =   IE.IdContratoEntregable
    FROM    
		dbo.EN_InstanciasEntregable IE
    JOIN    
		dbo.EN_ContratoEntregable   CE
        ON  IE.IdContratoEntregable =   CE.IdContratoEntregable
    WHERE	
		idInstanciaEntregable   =   @InstanciaEntregableId;

------------------------------------------

	SELECT 
		TOP 1 @URLDetalle = REPLACE(@URLDetalle, '##URLReplace##', isnull(R.Ruta,'adinco.mx'))
	FROM
		CO_Contratista  CI
	LEFT JOIN 
		dbo.AP_Rutas R 
		ON CI.IdRuta	=	r.idRuta
	JOIN 
		CO_Contrato  C 
		ON c.IdContratista = CI.IdContratista
	WHERE 
	C.IdContrato = @contrato

------------------------------------------
   SELECT 
        @IsAdmin    =   COUNT(1)
    FROM 
        dbo.AP_PerfilUsuario PU
    JOIN 
        dbo.AP_Perfil P 
        ON PU.PerfilID = P.IdPerfil
    JOIN 
        dbo.AP_Rol R 
        ON P.IdRol = R.IdRol
    WHERE 
        UsuarioID   =   @idUsuario
        AND P.IdContrato    =   @idContrato
        AND (   R.Rol   LIKE    '%Administra%Entregables%'  OR R.Rol LIKE '%Admin%Shell%' OR R.Rol LIKE '%Especial%BARBARA%');


    IF (@idContrato =   0   OR  @idContrato IS  NULL)
    BEGIN
        SELECT 
			@idContrato     =   IdContrato
        FROM    
			dbo.EN_InstanciasEntregable IE
        JOIN    
			dbo.EN_ContratoEntregable   CE
            ON  IE.IdContratoEntregable =   CE.IdContratoEntregable
        WHERE   
			idInstanciaEntregable   =   @InstanciaEntregableId;
    END;


    SELECT 
		@ActividadIDeElaboracion =   ActividadID
    FROM    
		dbo.EN_Actividad    
    WHERE   
		IdContratoEntregable    =   @idContratoEntregable
        AND   EstadoID    =   10000;


    SELECT  
		@ActividadIDActual  =   I.ActividadID,
        @usuarioResponsable =
        CASE ISNULL(EXAR.idUsuario, '')
            WHEN ''  
            THEN A.idUsuario
            ELSE EXAR.idUsuario
        END,
		@EstadoI =   A.EstadoID
    FROM    
		dbo.EN_InstanciasEntregable I
    JOIN    
		dbo.EN_Actividad    A
        ON  I.ActividadID   =   A.ActividadID 
    LEFT    JOIN    
		dbo.EN_ExcepcionesActividad EXAR 
        ON  A.ActividadID   =   EXAR.ActividadIDExcepcion
        AND I.idInstanciaEntregable =   EXAR.IdInstanciasEntregables
    WHERE   
		idInstanciaEntregable   =   @InstanciaEntregableId;

    SELECT 
		@NombreInstancia =   DocumentoEntregable,
        @FechaInstancia  =   FechasLimiteAprobacion
    FROM    
		dbo.EN_InstanciasEntregable IE
    JOIN    
		dbo.EN_ContratoEntregable   CE
        ON  IE.IdContratoEntregable = CE.IdContratoEntregable
    JOIN 
		dbo.EN_Entregable  E
        ON CE.IdEntregable = E.IdEntregable
    WHERE 
		idInstanciaEntregable = @InstanciaEntregableId;
	---

    IF(@IdUsuario   =   @usuarioResponsable)
    BEGIN
        SET @EsUsuarioAprobador =   1;
    END
    ELSE
    BEGIN
        IF((SELECT  COUNT(1)    FROM    EN_GruposUsuarios WHERE IdGrupo =   @usuarioResponsable AND IdUsuario   =   @idUsuario  AND IdContrato  =   @idContrato)    >   0)
            BEGIN
                SET @EsUsuarioAprobador =   1;
            END
            ELSE
            BEGIN
                SET @EsUsuarioAprobador =   0;
            END
    END
    IF (@EsUsuarioAprobador =   1 OR (@IsAdmin  =   1 AND @Rechazado    =   1 AND @TipoOperacion    =   5)) --SI ES USUARIO RESPONSABLE O SI ES ADMINISTRADOR Y SE VA A REINICIAR
    BEGIN
        IF (@Rechazado = 0)
            BEGIN

                SELECT  
					@ActividadSiguienteID   =   SiguienteActividadID
                FROM    
					dbo.EN_Transicion
                WHERE   
					ActividadInicialID  =   @ActividadIDActual
                    AND AccionID    =   10001;


                    IF  @ActividadSiguienteID   IS NOT NULL
                        BEGIN
                            UPDATE  
								EN_InstanciasEntregable
                            SET 
								ActividadID =   @ActividadSiguienteID,
                                ModificadoEn    =   GETDATE()
                            WHERE 
								idInstanciaEntregable =   @InstanciaEntregableId;


                                SELECT 
								   @EnlaceDetalle   =   EnlaceDetalle,
                                   @EnlaceAprobado  =   EnlaceAprobado,
                                   @EnlaceRechazo   =   EnlaceRechazo,
                                   @Para    =   correos,
                                   @NombreUsuario   =   NombreUsuario,
                                   @idTipoOperacion =   tipoOperacion
                            FROM 
								dbo.EN_URLResponsablesEntregables
                            WHERE 
								ActividadID = @ActividadSiguienteID;


                            IF (@Para IS NOT NULL)
                                BEGIN
                                    EXEC [sp_EN_EnviaCorreosRevisionAprobacion] @idUsuario,
                                                                                @idContrato,
                                                                                @InstanciaEntregableId,
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
                                END;


                            SELECT  
								@idTipoOperacion    =   tipoOperacion
                            FROM    
                                dbo.EN_URLResponsablesEntregables
                            WHERE   
                                ActividadID =   @ActividadIDActual;


                            SELECT 
								@Para = 
                                CASE ISNULL(EXAE.idUsuario, '')
                                    WHEN '' THEN
                                        u.Usuario
                                    ELSE
                                        UXE.Usuario
                                END,
                                    @NombreUsuario = 
                                    CASE ISNULL(EXAE.idUsuario, '')
                                        WHEN '' THEN
                                            u.Nombre
                                        ELSE
                                            UXE.Nombre
                                    END,
                                    @EsGrupo = 
                                        CASE ISNULL(EXAE.idUsuario, '')
                                            WHEN '' THEN
                                                ISNULL(u.IsGrupo,0)
                                            ELSE
                                                ISNULL(UXE.IsGrupo,0)
                                        END
                            FROM    
                                dbo.EN_Actividad    A
                            JOIN    
                                dbo.AP_Usuario  u 
                                ON  A.idUsuario =   u.UsuarioID
                            LEFT    JOIN    
                                dbo.EN_ExcepcionesActividad EXAE 
                                ON  EXAE.ActividadIDExcepcion   =   @ActividadIDeElaboracion
                            LEFT    JOIN    
                                dbo.AP_Usuario  UXE 
                                ON  EXAE.idUsuario  =   UXE.UsuarioID
                            WHERE ActividadID = @ActividadIDeElaboracion;


                            IF( @EsGrupo    =   1)--SI ES GRUPO EL ELABORADOR, SOLO SE ENVIA AL USUARIO QUE REALIZO EL ENTREGABLE
                            BEGIN

                                SELECT @Para    =   U.Usuario,
									   @NombreUsuario  =   U.Nombre
                                FROM 
                                    EN_HistorialAprobacionesLineaTiempo HAL
                                JOIN    
                                    AP_Usuario  U
                                    ON  HAL.CreadoPor   =   U.UsuarioID
                                 WHERE 
                                    idInstanciaEntregable   =   @InstanciaEntregableId  
                                    AND IdLineaTiempo   =   @idVersion  
                                    AND idTipoOperacion =   2

                            END

                            EXEC [sp_EN_EnviaCorreosRevisionAprobacion] @idUsuario,
                                                                        @idContrato,
                                                                        @InstanciaEntregableId,
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
                                                                @InstanciaEntregableId,
                                                                @idUsuario,
                                                                @contrato,
                                                                @Comentarios,
                                                                @Rechazado,
                                                                @TipoOperacion,
                                                                1,
                                                                'En este paso no se ingresa URL',
                                                                0;


                            EXEC [sp_EN_EnviaCorreos]   @idUsuario,
                                                        @contrato,
                                                        @InstanciaEntregableId,
                                                        10004,
                                                        @ActividadSiguienteID,
                                                        @ActividadIDActual;
            END;
        END;
        ELSE 

        IF (@Rechazado = 1)
            BEGIN
                UPDATE  
					dbo.EN_InstanciasEntregable
                SET 
					BitContieneAcuse    =   0,
                    FechaRealEntregaRegulador = NULL
                WHERE   
					idInstanciaEntregable   =   @InstanciaEntregableId;

                SELECT  
					@ActividadSiguienteID   =   SiguienteActividadID
                FROM    
					dbo.EN_Transicion
                WHERE   
					ActividadInicialID  =   @ActividadIDActual
					AND AccionID    =   10002;


                SELECT  
					@EstadoAprobado =   EstadoID
                FROM    
					EN_Actividad
                WHERE   
					ActividadID =   @ActividadIDActual;


                    IF (@EstadoAprobado <> 10003)
                        BEGIN

                            SELECT  
								@idTipoOperacion    =   tipoOperacion
                            FROM    
								dbo.EN_URLResponsablesEntregables
                            WHERE   
								ActividadID =   @ActividadIDActual;

                        END;
                        ELSE
                        BEGIN
                            SET @idTipoOperacion    =   5;
                        END;

                    IF  @ActividadSiguienteID   IS  NOT NULL
                        BEGIN
                            UPDATE  
								EN_InstanciasEntregable
							SET 
								ActividadID =   @ActividadSiguienteID,
								ModificadoEn    =   GETDATE()
                            WHERE   
								idInstanciaEntregable   =   @InstanciaEntregableId;


                            SELECT  @Para   =
                                CASE    ISNULL(EXAE.idUsuario, '')
                                    WHEN    ''  
                                    THEN    u.Usuario
                                    ELSE     UXE.Usuario
                                END,
                                   @NombreUsuario   =
                                   CASE ISNULL(EXAE.idUsuario, '')
                                       WHEN '' 
                                       THEN u.Nombre
                                       ELSE UXE.Nombre
                                   END,
                                   @EsGrupo = 
                                        CASE ISNULL(EXAE.idUsuario, '')
                                            WHEN '' THEN
                                                ISNULL(u.IsGrupo,0)
                                            ELSE
                                                ISNULL(UXE.IsGrupo,0)
                                        END
                            FROM    
								dbo.EN_Actividad    A
                            JOIN    
								dbo.AP_Usuario  u 
                                ON  A.idUsuario =   u.UsuarioID 
                            LEFT    JOIN    
								dbo.EN_ExcepcionesActividad EXAE 
                                ON  EXAE.ActividadIDExcepcion   =   @ActividadIDeElaboracion
                            LEFT    JOIN    
								dbo.AP_Usuario  UXE 
                                ON  EXAE.idUsuario  =   UXE.UsuarioID
                            WHERE   
								ActividadID =   @ActividadIDeElaboracion;


                            IF( @EsGrupo    =   1)--SI ES GRUPO EL ELABORADOR, SOLO SE ENVIA AL USUARIO QUE REALIZO EL ENTREGABLE
                            BEGIN
                                SELECT 
									@Para    =   U.Usuario,
                                    @NombreUsuario  =   U.Nombre
                                FROM 
									EN_HistorialAprobacionesLineaTiempo    HAL
                                JOIN    
									AP_Usuario  U
                                    ON  HAL.CreadoPor   =   U.UsuarioID
                                 WHERE 
									idInstanciaEntregable    =   @InstanciaEntregableId  
									AND IdLineaTiempo   =   @idVersion  
									AND idTipoOperacion =   2
                            END

                            EXEC [sp_EN_EnviaCorreosRevisionAprobacion] @idUsuario,
                                                                        @idContrato,
                                                                        @InstanciaEntregableId,
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
                                                               @InstanciaEntregableId,
                                                               @idUsuario,
                                                               @contrato,
                                                               @Comentarios,
                                                               @Rechazado,
                                                               @TipoOperacion,
                                                               1,
                                                               'En este paso no se ingresa URL',
                                                               0;

                            EXEC [sp_EN_EnviaCorreos] @idUsuario,
                                              @contrato,
                                              @InstanciaEntregableId,
                                              10005,
                                              @ActividadSiguienteID,
                                              @ActividadIDActual;
                        END;
            END;
    END;





	IF @Rechazado = 1
	BEGIN
		SELECT 'Entregable rechazado correctamente' AS 'Mensaje'
	END
	IF @Rechazado = 0
	BEGIN
		SELECT 'Entregable aprobado correctamente' AS 'Mensaje'
	END

END;

