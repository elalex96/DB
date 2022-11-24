CREATE TABLE [dbo].[PRED_Predios] (
    [IdPredio]            INT           IDENTITY (1, 1) NOT NULL,
    [IdPropietario]       INT           NULL,
    [IdMunicipio]         INT           NULL,
    [IdEstado]            INT           NULL,
    [IdAreaContractual]   INT           NULL,
    [KilometrosCuadrados] FLOAT (53)    NULL,
    [CreadoPor]           INT           NULL,
    [CreadoEl]            DATETIME      NULL,
    [ModificadoPor]       INT           NULL,
    [ModificadoEl]        DATETIME      NULL,
    [Activo]              BIT           NULL,
    [Nombre]              VARCHAR (MAX) NULL,
    CONSTRAINT [PK_PRED_Predios] PRIMARY KEY CLUSTERED ([IdPredio] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PRED_Predios_AP_Usuario_Ins] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PRED_Predios_AP_Usuario_Upd] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_PRED_Predios_CAT_Estados] FOREIGN KEY ([IdEstado]) REFERENCES [dbo].[CAT_Estados] ([IdEstado]),
    CONSTRAINT [FK_PRED_Predios_CAT_Municipios] FOREIGN KEY ([IdMunicipio]) REFERENCES [dbo].[CAT_Municipios] ([IdMunicipio]),
    CONSTRAINT [FK_PRED_Predios_CO_AreaContractual] FOREIGN KEY ([IdAreaContractual]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual]),
    CONSTRAINT [FK_PRED_Predios_CO_PropietariosAreaContractual] FOREIGN KEY ([IdPropietario]) REFERENCES [dbo].[CO_PropietariosAreaContractual] ([IdPropietario])
);

