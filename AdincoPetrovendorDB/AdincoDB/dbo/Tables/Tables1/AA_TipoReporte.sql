CREATE TABLE [dbo].[AA_TipoReporte] (
    [IdTipoReporte] INT           IDENTITY (10000, 1) NOT NULL,
    [NombreReporte] NVARCHAR (50) NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEn]      DATETIME      NULL,
    [CountColumnas] INT           NULL,
    CONSTRAINT [PK_AA_TipoReporte] PRIMARY KEY CLUSTERED ([IdTipoReporte] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AA_TipoReporte_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

