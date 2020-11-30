/****** Object:  StoredProcedure [dbo].[sp_SCOC_EnviaaCalculoAprobacion]    Script Date: 08/02/2019 03:27:23 p. m. ******/
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20180929
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SCOC_EnviaaCalculoAprobacion] --3,'20181101',2,'',1
    @idContrato INT,
    @MesReporte DATE,
    @idUsuario  INT,
    @URL        NVARCHAR(250),
    @IdPermiso  INT
AS
    BEGIN

        SET NOCOUNT ON;
        DECLARE
            @count                INT,
            @error                NVARCHAR(MAX) = '',
            @ApruebaRepPEP        BIT,
            @estatus              INT,
            @tipoCorreo           INT,
            @Comentario           NVARCHAR(MAX),
            @ComentarioCorreccion NVARCHAR(MAX);

        SELECT
            @count = COUNT(*)
        FROM
            dbo.SCOC_EnvioNotificacion
        WHERE
            idContrato = @idContrato
            AND MesReporte = @MesReporte;

        SELECT
            @ApruebaRepPEP = ApruebaRepPEP
        FROM
            SCOC_Contrato
        WHERE
            IdContrato = @idContrato;

        IF (@ApruebaRepPEP = 1)
            BEGIN
                SET @estatus = 10001;
                SET @tipoCorreo = 0;
                SET @Comentario = 'Envio a aprobación PEP el calculo de volumenes';
                SET @ComentarioCorreccion = 'Envio a aprobación PEP el calculo de volumenes (Corrección)';
            END;
        ELSE
            BEGIN
                SET @estatus = 10006;
                SET @tipoCorreo = 8;
                SET @Comentario = 'Enviado por contratista, se va directo a aprobación de Comercializadores';
                SET @ComentarioCorreccion = 'Envio a aprobación de comercializadores del edo (Corrección)';
            END;
        IF (@ApruebaRepPEP = 0)
            BEGIN
                UPDATE
                    SCOC_EnvioNotificacion
                SET
                    AprobadoRepPEP = 1,
                    FechaAprobacionRepPEP = GETDATE(),
                    IdUsuarioAprobadoRepPEP = @idUsuario
                WHERE
                    idContrato = @idContrato
                    AND MesReporte = @MesReporte;

                EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                    @idContrato,
                    @MesReporte,
                    8,
                    @idUsuario,
                    'Se envia Directo a comercializadores, por lo que PEP aprueba automaticamente',
                    0;
            END;
        ----------------------------------------------------------------------
        --Cambia estatus a Scoc_envioNotificación
        IF (@count = 0)
            BEGIN
                INSERT INTO dbo.SCOC_EnvioNotificacion
                    (
                        idContrato,
                        MesReporte,
                        EnviadoContratista,
                        FechaEnvioContratista,
                        AprobadoSCOC,
                        FechaAprobacion,
                        IdUsuarioAprobadoSCOC,
                        Comentarios,
                        CreadoPor,
                        CreadoEn,
                        ModificadoPor,
                        ModificadoEn,
                        FechaAprobacionRepPEP,
                        AprobadoRepPEP,
                        IdUsuarioAprobadoRepPEP,
                        idEstatus
                    )
                VALUES
                    (
                        @idContrato, -- idContrato - int
                        @MesReporte, -- MesReporte - date
                        1,           -- EnviadoContratista - bit
                        GETDATE(),   -- FechaEnvioContratista - date
                        0,           -- AprobadoSCOC - bit
                        NULL,        -- FechaAprobacion - date
                        NULL,        -- IdUsuarioAprobadoSCOC - int
                        NULL,        -- Comentarios - nvarchar(max)
                        @idUsuario,  -- CreadoPor - int
                        GETDATE(),   -- CreadoEn - datetime
                        NULL,        -- ModificadoPor - int
                        NULL,        -- ModificadoEn - datetime
                        NULL, 0, NULL, @estatus
                    );

                EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                    @idContrato,
                    @MesReporte,
                    @IdPermiso,
                    @idUsuario,
                    @Comentario,
                    0;
                EXECUTE sp_SCOC_EnviaCorreos
                    @idContrato,
                    @MesReporte,
                    @idUsuario,
                    @URL,
                    @tipoCorreo,
                    ''; -- Para que apruebe PEP
            END;
        ELSE
            BEGIN
                UPDATE
                    SCOC_EnvioNotificacion
                SET
                    EnviadoContratista = 1,
                    FechaEnvioContratista = GETDATE(),
                    ModificadoPor = @idUsuario,
                    ModificadoEn = GETDATE(),
                    idEstatus = @estatus
                WHERE
                    idContrato = @idContrato
                    AND MesReporte = @MesReporte;
                EXECUTE sp_SCOC_InsertaHistorialAprobaciones
                    @idContrato,
                    @MesReporte,
                    @IdPermiso,
                    @idUsuario,
                    @ComentarioCorreccion,
                    0;
                EXECUTE sp_SCOC_EnviaCorreos
                    @idContrato,
                    @MesReporte,
                    @idUsuario,
                    @URL,
                    @tipoCorreo,
                    ''; -- Para que apruebe PEP
            END;


        SELECT
            @error AS error;

    END;
