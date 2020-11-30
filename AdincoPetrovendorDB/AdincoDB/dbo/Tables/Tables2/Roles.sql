CREATE TABLE [dbo].[Roles] (
    [IdRol]      INT          NOT NULL,
    [Rol]        VARCHAR (50) NULL,
    [Activo]     BIT          NULL,
    [IdContrato] INT          NULL,
    CONSTRAINT [PK_Roles_] PRIMARY KEY CLUSTERED ([IdRol] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Roles_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

