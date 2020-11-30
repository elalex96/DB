CREATE TABLE [dbo].[AP_MenuPorRolContrato] (
    [idMenuRolContrato] INT IDENTITY (1, 1) NOT NULL,
    [idRolContrato]     INT NULL,
    [menuId]            INT NULL,
    [Visible]           BIT NULL,
    PRIMARY KEY CLUSTERED ([idMenuRolContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([menuId]) REFERENCES [dbo].[AP_MenuN] ([MenuId])
);

