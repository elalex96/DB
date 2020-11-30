CREATE TABLE [dbo].[RolesFlujosDetalle] (
    [IdRolFlujoDetalle] INT NOT NULL,
    [IdRol]             INT NULL,
    [IdFlujoDetalle]    INT NULL,
    [Activo]            BIT NULL,
    CONSTRAINT [PK_RolesFlujosDetalle] PRIMARY KEY CLUSTERED ([IdRolFlujoDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_RolesFlujosDetalle_CAT_FlujosDetalle] FOREIGN KEY ([IdFlujoDetalle]) REFERENCES [dbo].[CAT_FlujosDetalle] ([IdFlujoDetalle])
);

