CREATE TABLE [dbo].[PerfilModuloControl] (
    [IdPerfilModuloControl] INT IDENTITY (1, 1) NOT NULL,
    [IdPerfilModulo]        INT NULL,
    [IdControl]             INT NULL,
    [Activo]                BIT NULL,
    CONSTRAINT [PK_PerfilModuloControl] PRIMARY KEY CLUSTERED ([IdPerfilModuloControl] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PerfilModuloControl_Control] FOREIGN KEY ([IdControl]) REFERENCES [dbo].[Control] ([IdControl]),
    CONSTRAINT [FK_PerfilModuloControl_PerfilModulo] FOREIGN KEY ([IdPerfilModulo]) REFERENCES [dbo].[PerfilModulo] ([IdPerfilModulo])
);

