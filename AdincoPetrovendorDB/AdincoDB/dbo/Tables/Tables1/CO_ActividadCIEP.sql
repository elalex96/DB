CREATE TABLE [dbo].[CO_ActividadCIEP] (
    [IdActividad]        INT           IDENTITY (1, 1) NOT NULL,
    [ID_CATACTIV]        NVARCHAR (50) NULL,
    [NombreActividad]    NVARCHAR (50) NULL,
    [IdContrato]         INT           NULL,
    [IdUsuarioCreadoPor] INT           NULL,
    [Creado]             DATETIME      NULL,
    [IdUsuarioModPor]    INT           NULL,
    [Modificado]         DATETIME      NULL,
    [CreadoPor]          INT           NULL,
    CONSTRAINT [PK_Actividades] PRIMARY KEY CLUSTERED ([IdActividad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Actividades_Contratos] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato]),
    CONSTRAINT [FK_Actividades_Usuarios] FOREIGN KEY ([IdUsuarioCreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_Actividades_UsuariosMod] FOREIGN KEY ([IdUsuarioModPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

