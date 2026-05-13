use Petrovendor
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'APP_AdministrarNotificacionDefault'
)
    DROP PROCEDURE APP_AdministrarNotificacionDefault;

GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 30/08/2022
-- Modified:	Alexander Gomez - 27/04/2026
-- Description:	Administra las notificaciones default (CRUD) y registra
--              el usuario que realizó la acción (CreadoPor / ModificadoPor).
--              NombreCreadoPor y NombreModificadoPor se resuelven mediante
--              JOIN a S_Usuario.
-- =============================================
CREATE PROCEDURE [dbo].[APP_AdministrarNotificacionDefault]
    @TipoConsulta      NVARCHAR(MAX),
    @Id                INT           = NULL,
    @ContratoId        INT           = NULL,
    @Titulo            NVARCHAR(MAX) = NULL,
    @Mensaje           NVARCHAR(MAX) = NULL,
    @FechaInicio       DATETIME      = NULL,
    @FechaFinalizacion DATETIME      = NULL,
    @Activo            BIT           = NULL,
    @CreadoPor         INT           = NULL,
    @ModificadoPor     INT           = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @TipoConsulta = 'CONSULTAR_TODOS'
    BEGIN
        SELECT n.Id,
               n.ContratoId,
               n.Titulo,
               n.Mensaje,
               n.FechaInicio,
               n.FechaFinalizacion,
               n.Activo,
               n.CreadoEl,
               n.CreadoPor,
               n.ModificadoPor,
               n.ModificadoEl,
               ucreador.Nombre     AS NombreCreadoPor,
               umodificador.Nombre AS NombreModificadoPor
        FROM dbo.APP_NotificacionesDefault AS n WITH (NOLOCK)
            LEFT JOIN dbo.S_Usuario AS ucreador WITH (NOLOCK)
                ON ucreador.IdUsuario = n.CreadoPor
            LEFT JOIN dbo.S_Usuario AS umodificador WITH (NOLOCK)
                ON umodificador.IdUsuario = n.ModificadoPor
        ORDER BY n.Id DESC;
    END

    IF @TipoConsulta = 'CONSULTAR_CONTRATOS'
    BEGIN
        SELECT C.IdContrato AS ContratoId,
               CONCAT(C.NumeroContrato, ISNULL(' - ' + AC.NombreAreaContractual, '')) AS Contrato
        FROM Adinco..CO_Contrato AS C WITH (NOLOCK)
            LEFT JOIN Adinco..CO_AreaContractual AS AC WITH (NOLOCK)
                ON C.IdAreaContractual = AC.IdAreaContractual
        ORDER BY C.NumeroContrato;
    END

    IF @TipoConsulta = 'INSERTAR'
    BEGIN
        INSERT INTO dbo.APP_NotificacionesDefault
        (
            ContratoId,
            Titulo,
            Mensaje,
            FechaInicio,
            FechaFinalizacion,
            Activo,
            CreadoEl,
            CreadoPor
        )
        VALUES
        (
            @ContratoId,
            @Titulo,
            @Mensaje,
            @FechaInicio,
            @FechaFinalizacion,
            @Activo,
            GETDATE(),
            @CreadoPor
        );
    END

    IF @TipoConsulta = 'ACTUALIZAR'
    BEGIN
        UPDATE dbo.APP_NotificacionesDefault
        SET ContratoId        = @ContratoId,
            Titulo            = @Titulo,
            Mensaje           = @Mensaje,
            FechaInicio       = @FechaInicio,
            FechaFinalizacion = @FechaFinalizacion,
            Activo            = @Activo,
            ModificadoPor     = @ModificadoPor,
            ModificadoEl      = GETDATE()
        WHERE Id = @Id;
    END

    IF @TipoConsulta = 'ELIMINAR'
    BEGIN
        DELETE FROM dbo.APP_NotificacionesDefault
        WHERE Id = @Id;
    END
END
