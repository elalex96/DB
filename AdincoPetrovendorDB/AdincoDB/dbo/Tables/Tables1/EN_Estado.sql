CREATE TABLE [dbo].[EN_Estado] (
    [EstadoID]      INT            IDENTITY (10000, 1) NOT NULL,
    [NombreEstado]  NVARCHAR (150) NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_EN_Estado] PRIMARY KEY CLUSTERED ([EstadoID] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_Estado_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_Estado_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

