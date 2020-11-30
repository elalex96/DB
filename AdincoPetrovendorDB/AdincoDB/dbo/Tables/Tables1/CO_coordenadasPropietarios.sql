CREATE TABLE [dbo].[CO_coordenadasPropietarios] (
    [idCoordenadaPropietario] INT           IDENTITY (1, 1) NOT NULL,
    [Latitud]                 NVARCHAR (50) NULL,
    [Longitud]                NVARCHAR (50) NULL,
    [idPropietario]           INT           NULL,
    [idAreaContractual]       INT           NULL,
    [CreadoPor]               INT           NULL,
    [CreadoEl]                DATETIME      NULL,
    [ModificadoPor]           INT           NULL,
    [ModificadoEl]            DATETIME      NULL,
    [Activo]                  BIT           NULL,
    CONSTRAINT [PK_CoordPropietario] PRIMARY KEY CLUSTERED ([idCoordenadaPropietario] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_AreaContractual_Coordenadas] FOREIGN KEY ([idAreaContractual]) REFERENCES [dbo].[CO_AreaContractual] ([IdAreaContractual]),
    CONSTRAINT [fk_propietario_Coordenadas] FOREIGN KEY ([idPropietario]) REFERENCES [dbo].[CO_PropietariosAreaContractual] ([IdPropietario]),
    CONSTRAINT [fk_Usuario1_Coordenadas] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [fk_Usuario2_Coordenadas] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

