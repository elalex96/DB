IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'p_OT_InsertarProgramaBitacoraSemana'
    )
    DROP PROCEDURE p_OT_InsertarProgramaBitacoraSemana;
GO
CREATE proc [dbo].[p_OT_InsertarProgramaBitacoraSemana]
    @pIdOTProgramaBitacoraSemana int,
    @pIdOTSolicitud              int,
    @pSemanaID                   varchar(21),
    @pFechaRegistro              datetime,
    @pComentarios                varchar(500),
    @pCreadoPor                  varchar(150),
    @pTipoUsuario                tinyint --1.Operador 2.Subcontratista
as
    begin
        DECLARE @TablaCorreo TABLE
            (
                Html           VARCHAR(MAX),
                Asunto         VARCHAR(MAX),
                CuentaRegistro VARCHAR(500),
                Contrasena     VARCHAR(500),
                SMTP           VARCHAR(500),
                Puerto         INT,
                BBC            VARCHAR(500)
            )
			  declare @EnvioCorreo table
            (
                RazonSocial    VARCHAR(max),
                Folio          VARCHAR(500),
                Correo         VARCHAR(500),
                IdNotificacion bigint
            )

        declare
            @CuentaRegistro        VARCHAR(500),
            @Contrasena            VARCHAR(500),
            @Smtp                  VARCHAR(500),
            @Puerto                int,
            @Bbc                   VARCHAR(500),
            @NombreOperadora       VARCHAR(500),
            @NombreProveedor       VARCHAR(500),
            @Year                  int,
            @Folio                 VARCHAR(300),
            @UsuarioAdincoID       VARCHAR(300),
            @pUsuarioPetrovendorID VARCHAR(300),
            @URL                   VARCHAR(500),
            @Asunto                VARCHAR(max),
            @Html                  VARCHAR(max),
            @CorreoProveedor       VARCHAR(max),
            @IdNotificacion        bigint,
            @Dominio               VARCHAR(500) = 'https://petrovendor.com.mx/',
			@IdCorreoServidorMAX INT;

        select
            @pIdOTProgramaBitacoraSemana = isnull(max(IdOTProgramaBitacoraSemana), 0) + 1
        from
            [OT_ProgramaBitacoraSemana] (NOLOCK)

        if (@pTipousuario = 1)
            begin
                --Solo se envia el correo cuando es un comentario de la operadora
                select
                    @UsuarioAdincoID = UsuarioID
                from
                    AP_Usuario	(NOLOCK)
                where
                    Usuario = @pCreadoPor

                select
                    @IdNotificacion = max(IdNotificacion)
                from
                    Adinco.dbo.S_Notificacion	(NOLOCK)

                insert into @EnvioCorreo
                    (
                        RazonSocial,
                        Folio,
                        Correo,
                        IdNotificacion
                    )
                            select
                                contra.RazonSocial,
                                ot.Folio,
                                u.Correo,
                                row_number() over (order by
                                                       contra.RazonSocial
                                                  ) + @Idnotificacion
                            from
                                Ot_solicitud                           ot	(NOLOCK)
                                JOIN
                                    sc_subcontrato                     sub (NOLOCK)
                                        on ot.IdSubContrato = sub.IdSubContrato
										AND OT.IdOTSolicitud = @pIdOTSolicitud
                                JOIN
                                    pv_subcontratista                  contra (NOLOCK)
                                        on  sub.IdSubcontratista	= contra.IdSubcontratista
                                left join
                                    petrovendor.dbo.S_usuarioProveedor up (NOLOCK)
                                        on contra.IdPetrovendor	=	up.IdProveedor
                                left join
                                    petrovendor.dbo.s_usuario          u (NOLOCK)
                                        on up.IdUsuario	=	u.IdUsuario
                                           and u.activo = 1
                            where
                                OT.IdOTSolicitud = @pIdOTSolicitud
                                and u.correo is not null
                            group by
                                contra.RazonSocial,
                                ot.Folio,
                                u.Correo

                SELECT top 1
                    @Folio           = folio,
                    @NombreProveedor = RazonSocial
                from
                    @EnvioCorreo
                select
                    @year = year(getdate())

                select
                    @Url = concat(@dominio, '02Proveedores/CapturaProgramaOT.aspx?id=', @pIdOTSolicitud)

                select
                    @NombreOperadora = Nombre
                from
                    ap_usuario (NOLOCK)
                where
                    Usuario = @pCreadoPor

				select
					@IdCorreoServidorMAX =   max(IdCorreoServidor)
				from
					S_CorreoServidor;

                select
                    @CuentaRegistro = CuentaRegistro,
                    @Contrasena     = Contrasena,
                    @Smtp           = SMTP,
                    @Puerto         = Puerto,
                    @Bbc            = BBC
                from
                    S_CorreoServidor (NOLOCK)
                where
                    IdCorreoServidor = @IdCorreoServidorMAX;

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
                            SELECT
                                Cuerpo1,
                                Asunto,
                                @CuentaRegistro,
                                @Contrasena,
                                @Smtp,
                                @Puerto,
                                @Bbc
                            FROM
                                s_correo (NOLOCK)
                            where
                                descripcion = 'CONTROL_DE_OBRA_NOTIFICACION_BITACORA'

                select
                    @Asunto = REPLACE(Asunto, '{folio_ot}', LTRIM(@Folio)),
                    @Html
                            = REPLACE(
                                         REPLACE(
                                                    REPLACE(
                                                               REPLACE(
                                                                          REPLACE(
                                                                                     REPLACE(
                                                                                                Html, '{nombre_emisor}',
                                                                                                @NombreOperadora
                                                                                            ), '{folio_ot}', @folio
                                                                                 ), '{nombre_receptor}', @NombreProveedor
                                                                      ), '{year}', @Year
                                                           ), '{comentario_operadora}', @pComentarios
                                                ), '{url_ot}', @url
                                     )
                FROM
                    @TablaCorreo




                INSERT INTO Adinco.dbo.S_Notificacion
                    (
                        IdNotificacion,
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
                        De
                    )
                            SELECT
                                correo.IdNotificacion,
                                correo.Correo,
                                @Asunto,
                                @Html,
                                dateadd(minute, 1, GETDATE()),
                                0,
                                null,
                                3,
                                GETDATE(),
                                NULL,
                                NULL,
                                @CuentaRegistro
                            FROM
                                @EnvioCorreo correo
            end


        if (@pTipousuario = 2)
            begin
                select
                    @pUsuarioPetrovendorID = IdUsuario
                from
                    Petrovendor.dbo.S_Usuario (NOLOCK)
                where
                    Correo = @pCreadoPor
            end



        insert into [dbo].[OT_ProgramaBitacoraSemana]
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
        values
            (
                @pIdOTProgramaBitacoraSemana,
                @pIdOTSolicitud,
                @pSemanaID,
                getdate(),
                @pComentarios,
                @pCreadoPor,
                @pUsuarioPetrovendorID,
                @UsuarioAdincoID,
                @pTipousuario
            )
    end


