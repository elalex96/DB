CREATE TABLE [dbo].[CO_ContratoRolUsuario] (
    [IdContratoRolUsuario] INT      IDENTITY (1, 1) NOT NULL,
    [IdContrato]           INT      NULL,
    [IdRol]                INT      NULL,
    [IdUsuario]            INT      NULL,
    [Activo]               INT      NULL,
    [Creado]               DATETIME NULL,
    [ModificadoPor]        INT      NULL,
    [Modificado]           DATETIME NULL,
    [CreadoPor]            INT      NULL,
    CONSTRAINT [PK_ContratoRolUsuario] PRIMARY KEY CLUSTERED ([IdContratoRolUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ContratoRolUsuario_Contratos] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

