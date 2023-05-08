CREATE TABLE [dbo].[RespaldoAprobadorSASISOPA] (
    [ActividadID]          INT      NOT NULL,
    [EstadoID]             INT      NOT NULL,
    [idUsuario]            INT      NOT NULL,
    [IdContratoEntregable] INT      NOT NULL,
    [CreadoPor]            INT      NULL,
    [CreadoEn]             DATETIME NULL,
    [ModificadoPor]        INT      NULL,
    [ModificadoEn]         DATETIME NULL,
    [Activo]               BIT      NOT NULL
);

