CREATE TABLE [dbo].[AP_BitacoraStatusSesion] (
    [IdSesion]  INT            IDENTITY (1, 1) NOT NULL,
    [HostName]  NVARCHAR (MAX) NULL,
    [Browser]   NVARCHAR (MAX) NULL,
    [IsActive]  BIT            DEFAULT ((0)) NULL,
    [UsuarioID] INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([IdSesion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_UsuarioID] FOREIGN KEY ([UsuarioID]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

