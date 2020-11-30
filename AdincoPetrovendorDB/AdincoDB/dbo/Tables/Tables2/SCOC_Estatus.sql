CREATE TABLE [dbo].[SCOC_Estatus] (
    [idEstatus]          INT            IDENTITY (10000, 1) NOT NULL,
    [NombreEstatus]      VARCHAR (100)  NULL,
    [DescripcionEstatus] NVARCHAR (500) NULL,
    [CreadoPor]          INT            NULL,
    [CreadoEn]           DATETIME       NULL,
    [ModificadoPor]      INT            NULL,
    [ModificadoEn]       DATETIME       NULL,
    [Activo]             BIT            NULL,
    CONSTRAINT [PK_SCOC_Estatus] PRIMARY KEY CLUSTERED ([idEstatus] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SCOC_Estatus_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_SCOC_Estatus_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

