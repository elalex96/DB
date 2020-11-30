CREATE TABLE [dbo].[EN_HistorialAprobacionesLineaTiempo] (
    [IdHistorialAprobacionesVersion] INT            IDENTITY (10000, 1) NOT NULL,
    [IdLineaTiempo]                  INT            NOT NULL,
    [idInstanciaEntregable]          INT            NOT NULL,
    [idContrato]                     INT            NULL,
    [Comentario]                     VARCHAR (5000) NULL,
    [Rechazado]                      BIT            NOT NULL,
    [idTipoOperacion]                INT            NOT NULL,
    [CreadoPor]                      INT            NOT NULL,
    [CreadoEn]                       DATETIME       NULL,
    [ModificadoPor]                  INT            NULL,
    [ModificadoEn]                   DATETIME       NULL,
    [Activo]                         BIT            NULL,
    [ActualizadoByApp]               BIT            NULL,
    [URLRepositorio]                 VARCHAR (5000) NULL,
    [ContieneURLRepositorio]         BIT            NULL,
    CONSTRAINT [PK_EN_HistorialAprobacionesVersion] PRIMARY KEY CLUSTERED ([IdLineaTiempo] ASC, [idInstanciaEntregable] ASC, [Rechazado] ASC, [idTipoOperacion] ASC, [CreadoPor] ASC, [IdHistorialAprobacionesVersion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_HistorialAprobacionesVersion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_HistorialAprobacionesVersion_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_HistorialAprobacionesVersion_Co_Contrato] FOREIGN KEY ([idContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_EN_HistorialAprobacionesVersion_EN_InstanciasEntregable] FOREIGN KEY ([idInstanciaEntregable]) REFERENCES [dbo].[EN_InstanciasEntregable] ([idInstanciaEntregable]),
    CONSTRAINT [FK_EN_TipoOperacion] FOREIGN KEY ([idTipoOperacion]) REFERENCES [dbo].[EN_TipoOperacion] ([idTipoOperacion])
);

