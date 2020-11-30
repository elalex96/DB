CREATE TABLE [dbo].[AP_UsuarioCentroCosto] (
    [IdUsuario]     INT      NOT NULL,
    [IdCentroCosto] INT      NOT NULL,
    [CreadoEl]      DATETIME NOT NULL,
    [Id]            INT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_AP_UsuarioCentroCosto] PRIMARY KEY CLUSTERED ([IdUsuario] ASC, [IdCentroCosto] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_UsuarioCentroCosto_AP_Usuario] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

