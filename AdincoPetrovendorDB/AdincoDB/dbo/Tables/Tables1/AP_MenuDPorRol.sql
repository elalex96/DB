CREATE TABLE [dbo].[AP_MenuDPorRol] (
    [idMenuRol] INT IDENTITY (1, 1) NOT NULL,
    [IdRol]     INT NOT NULL,
    [IdMenu]    INT NOT NULL,
    [Visible]   BIT NULL,
    CONSTRAINT [PK_AP_MenuDPorRol] PRIMARY KEY CLUSTERED ([IdRol] ASC, [IdMenu] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_MenuDPorRol_AP_MenuD] FOREIGN KEY ([IdMenu]) REFERENCES [dbo].[AP_MenuD] ([MenuId])
);

