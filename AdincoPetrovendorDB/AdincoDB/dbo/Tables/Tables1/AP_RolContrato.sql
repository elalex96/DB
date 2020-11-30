CREATE TABLE [dbo].[AP_RolContrato] (
    [IdRolContrato] INT IDENTITY (10000, 1) NOT NULL,
    [IdRol]         INT NULL,
    [IdContrato]    INT NULL,
    [Activo]        BIT NULL,
    CONSTRAINT [PK_AP_RolContrato] PRIMARY KEY CLUSTERED ([IdRolContrato] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_AP_RolContrato_AP_Rol] FOREIGN KEY ([IdRol]) REFERENCES [dbo].[AP_Rol] ([IdRol]),
    CONSTRAINT [FK_AP_RolContrato_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

