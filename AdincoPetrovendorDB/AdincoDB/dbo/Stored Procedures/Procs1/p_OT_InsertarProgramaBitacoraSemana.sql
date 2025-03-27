IF OBJECT_ID('[dbo].[p_OT_InsertarProgramaBitacoraSemana]', 'P') IS NOT NULL
    DROP PROC [dbo].[p_OT_InsertarProgramaBitacoraSemana]
GO

CREATE PROC [dbo].[p_OT_InsertarProgramaBitacoraSemana]
    @pIdOTProgramaBitacoraSemana INT,
    @pIdOTSolicitud INT,
    @pSemanaID VARCHAR(21),
    @pFechaRegistro DATETIME,
    @pComentarios VARCHAR(500),
    @pCreadoPor VARCHAR(150),
    @pTipoUsuario TINYINT --1.Operador 2.Subcontratista
AS
BEGIN
    DECLARE @TablaCorreo TABLE
    (
        Html VARCHAR(MAX),
        Asunto VARCHAR(MAX),
        CuentaRegistro VARCHAR(500),
        Contrasena VARCHAR(500),
        SMTP VARCHAR(500),
        Puerto INT,
        BBC VARCHAR(500)
    )
    DECLARE @EnvioCorreo TABLE
    (
        RazonSocial VARCHAR(max),
        Folio VARCHAR(500),
        Correo VARCHAR(500),
        IdNotificacion BIGINT
    )
    DECLARE @CuentaRegistro VARCHAR(500),
            @Contrasena VARCHAR(500),
            @Smtp VARCHAR(500),
            @Puerto INT,
            @Bbc VARCHAR(500),
            @NombreOperadora VARCHAR(500),
            @NombreProveedor VARCHAR(500),
            @Year INT,
            @Folio VARCHAR(300),
            @UsuarioAdincoID VARCHAR(300),
            @pUsuarioPetrovendorID VARCHAR(300),
            @URL VARCHAR(500),
            @Asunto VARCHAR(max),
            @Html VARCHAR(max),
            @CorreoProveedor VARCHAR(max),
            @IdNotificacion BIGINT,
            @Dominio VARCHAR(500) = 'https://petrovendor.com.mx/',
            @IdCorreoServidorMAX INT,
            @Id INT = 0,
            @Para VARCHAR(500) = '',
            @FechaProgramadaEnvio DATETIME,
            @Modulo VARCHAR(100) = 'Control de Obra',
            @TotalRegistros INT,
            @Contador INT = 1;

    SELECT @pIdOTProgramaBitacoraSemana = isnull(max(IdOTProgramaBitacoraSemana), 0) + 1
    FROM [OT_ProgramaBitacoraSemana] (NOLOCK)

    IF (@pTipousuario = 1)
    BEGIN
        --Solo se envia el correo cuando es un comentario de la operadora
        SELECT @UsuarioAdincoID = UsuarioID
        FROM AP_Usuario (NOLOCK)
        WHERE Usuario = @pCreadoPor

        SELECT @IdNotificacion = max(IdNotificacion)
        FROM Adinco.dbo.S_Notificacion (NOLOCK)

        INSERT INTO @EnvioCorreo
        (
            RazonSocial,
            Folio,
            Correo,
            IdNotificacion
        )
        SELECT contra.RazonSocial,
               ot.Folio,
               u.Correo,
               row_number() OVER (ORDER BY contra.RazonSocial)
        FROM Ot_solicitud ot (NOLOCK)
            JOIN sc_subcontrato sub (NOLOCK)
                ON ot.IdSubContrato = sub.IdSubContrato
                   AND OT.IdOTSolicitud = @pIdOTSolicitud
            JOIN pv_subcontratista contra (NOLOCK)
                ON sub.IdSubcontratista = contra.IdSubcontratista
            LEFT JOIN petrovendor.dbo.S_usuarioProveedor up (NOLOCK)
                ON contra.IdPetrovendor = up.IdProveedor
            LEFT JOIN petrovendor.dbo.s_usuario u (NOLOCK)
                ON up.IdUsuario = u.IdUsuario
                   AND u.activo = 1
        WHERE OT.IdOTSolicitud = @pIdOTSolicitud
              AND u.correo IS NOT NULL
        GROUP BY contra.RazonSocial,
                 ot.Folio,
                 u.Correo

		-- Obtener la cantidad de registros en @EnvioCorreo
		SET @TotalRegistros = @@ROWCOUNT;

        SELECT TOP 1
            @Folio = folio,
            @NombreProveedor = RazonSocial
        FROM @EnvioCorreo

        SELECT @year = year(getdate())

        SELECT @Url = CONCAT(@dominio, '02Proveedores/CapturaProgramaOT.aspx?id=', @pIdOTSolicitud)

        SELECT @NombreOperadora = Nombre
        FROM ap_usuario (NOLOCK)
        WHERE Usuario = @pCreadoPor

        SELECT @IdCorreoServidorMAX = max(IdCorreoServidor)
        FROM S_CorreoServidor;

        SELECT @CuentaRegistro = CuentaRegistro,
               @Contrasena = Contrasena,
               @Smtp = SMTP,
               @Puerto = Puerto,
               @Bbc = BBC
        FROM S_CorreoServidor (NOLOCK)
        WHERE IdCorreoServidor = @IdCorreoServidorMAX;

        INSERT INTO @TablaCorreo
        (
            Html,
            Asunto,
            CuentaRegistro,
            Contrasena,
            Smtp,
            Puerto,
            Bbc
        )
        SELECT Cuerpo1,
               Asunto,
               @CuentaRegistro,
               @Contrasena,
               @Smtp,
               @Puerto,
               @Bbc
        FROM s_correo (NOLOCK)
        WHERE descripcion = 'CONTROL_DE_OBRA_NOTIFICACION_BITACORA'

        SELECT @Asunto = REPLACE(Asunto, '{folio_ot}', LTRIM(@Folio)),
               @Html
                   = REPLACE(
                                REPLACE(
                                           REPLACE(
                                                      REPLACE(
                                                                 REPLACE(
                                                                            REPLACE(
                                                                                       Html,
                                                                                       '{nombre_emisor}',
                                                                                       @NombreOperadora
                                                                                   ),
                                                                            '{folio_ot}',
                                                                            @folio
                                                                        ),
                                                                 '{nombre_receptor}',
                                                                 @NombreProveedor
                                                             ),
                                                      '{year}',
                                                      @Year
                                                  ),
                                           '{comentario_operadora}',
                                           @pComentarios
                                       ),
                                '{url_ot}',
                                @url
                            )
        FROM @TablaCorreo

        SET @FechaProgramadaEnvio = DATEADD(MINUTE, 1, GETDATE());

        WHILE @Contador <= @TotalRegistros
        BEGIN
            -- Obtener valores de la fila actual basada en el IDENTITY
            SELECT @Para = Correo
            FROM @EnvioCorreo
            WHERE IdNotificacion = @Contador;

            -- Programar la fecha de envío
            -- Ejecutar el procedimiento almacenado para cada registro
            EXEC [dbo].[USP_INS_AP_Notificacion] @Id = @Id,
                                                 @Para = @Para,
                                                 @Asunto = @Asunto,
                                                 @Mensaje = @Html,
                                                 @FechaProgramadaEnvio = @FechaProgramadaEnvio,
                                                 @Enviada = 0,
                                                 @CreadoPor = @pCreadoPor,
                                                 @CCO = '',
                                                 @Modulo = @Modulo;

            -- Incrementar el contador
            SET @Contador = @Contador + 1;
        END
    END

    IF (@pTipousuario = 2)
    BEGIN
        SELECT @pUsuarioPetrovendorID = IdUsuario
        FROM Petrovendor.dbo.S_Usuario (NOLOCK)
        WHERE Correo = @pCreadoPor
    END

    INSERT INTO [dbo].[OT_ProgramaBitacoraSemana]
    (
        IdOTProgramaBitacoraSemana,
        IdOTSolicitud,
        SemanaID,
        FechaRegistro,
        Comentarios,
        CreadoPor,
        UsuarioPetrovendorID,
        UsuarioAdincoID,
        TipoUsuario
    )
    VALUES
    (@pIdOTProgramaBitacoraSemana,
     @pIdOTSolicitud,
     @pSemanaID,
     getdate(),
     @pComentarios,
     @pCreadoPor,
     @pUsuarioPetrovendorID,
     @UsuarioAdincoID,
     @pTipousuario
    )
END
