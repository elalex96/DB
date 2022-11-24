CREATE TABLE [dbo].[EN_Accion] (
    [AccionID]      INT            IDENTITY (10000, 1) NOT NULL,
    [NombreAccion]  NVARCHAR (150) NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_EN_Accion] PRIMARY KEY CLUSTERED ([AccionID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_Accion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_Accion_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

