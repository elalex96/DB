CREATE TABLE [dbo].[CO_ContratistaRelacionado] (
    [IdContratista] INT      NOT NULL,
    [IdRelacionado] INT      NOT NULL,
    [BitActivo]     BIT      NULL,
    [CreadoPor]     INT      NULL,
    [CreadoEl]      DATETIME NULL,
    [ModificadoPor] INT      NULL,
    [ModificadoEl]  DATETIME NULL,
    CONSTRAINT [PK_CO_ContratistaRelacionado] PRIMARY KEY CLUSTERED ([IdContratista] ASC, [IdRelacionado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_ContratistaRelacionado_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ContratistaRelacionado_AP_Usuario2] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_CO_ContratistaRelacionado_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

