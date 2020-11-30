CREATE TABLE [dbo].[AP_RolPorContrato] (
    [idRolContrato] INT IDENTITY (1, 1) NOT NULL,
    [idContrato]    INT NULL,
    [idRol]         INT NULL,
    PRIMARY KEY CLUSTERED ([idRolContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([idRol]) REFERENCES [dbo].[AP_Rol] ([IdRol])
);

