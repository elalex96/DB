CREATE TABLE [dbo].[AP_MenuPorRol] (
    [IdMenuRol] INT IDENTITY (1, 1) NOT NULL,
    [IdRol]     INT NULL,
    [IdMenu]    INT NULL,
    [Visible]   BIT NULL,
    CONSTRAINT [PK_AP_MenuPorRol] PRIMARY KEY CLUSTERED ([IdMenuRol] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK__ap_MenuPo__idRol__4E00FDF4] FOREIGN KEY ([IdRol]) REFERENCES [dbo].[AP_Rol] ([IdRol]),
    CONSTRAINT [FK__AP_MenuPo__idRol__6128E101] FOREIGN KEY ([IdRol]) REFERENCES [dbo].[AP_Rol] ([IdRol]),
    CONSTRAINT [FK_AP_MenuPorRol_AP_MenuN] FOREIGN KEY ([IdMenu]) REFERENCES [dbo].[AP_MenuN] ([MenuId])
);

