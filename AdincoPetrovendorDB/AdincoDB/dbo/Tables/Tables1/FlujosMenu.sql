CREATE TABLE [dbo].[FlujosMenu] (
    [IdFlujoMenu] INT    NOT NULL,
    [IdFlujo]     INT    NULL,
    [IdMenu]      BIGINT NULL,
    [Activo]      BIT    NULL,
    CONSTRAINT [PK_FlujosMenu] PRIMARY KEY CLUSTERED ([IdFlujoMenu] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FlujosMenu_AP_Menu] FOREIGN KEY ([IdMenu]) REFERENCES [dbo].[AP_Menu] ([MenuId]),
    CONSTRAINT [FK_FlujosMenu_CAT_Flujos] FOREIGN KEY ([IdFlujo]) REFERENCES [dbo].[CAT_Flujos] ([IdFlujo])
);

