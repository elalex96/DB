CREATE TABLE [dbo].[EN_Actividades] (
    [IdActividad]         INT            IDENTITY (10000, 1) NOT NULL,
    [NombreActividad]     VARCHAR (3000) NULL,
    [Dias]                INT            NULL,
    [DiasNaturales]       BIT            NULL,
    [CreadoPor]           INT            NULL,
    [CreadoEl]            DATETIME       NULL,
    [ModificadoPor]       INT            NULL,
    [ModificadoEl]        DATETIME       NULL,
    [Activo]              BIT            NULL,
    [IdRegulador]         INT            NULL,
    [IdActividadOriginal] INT            NULL,
    CONSTRAINT [PK_EN_Actividades] PRIMARY KEY CLUSTERED ([IdActividad] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_EN_Actividades_UsuarioCreado] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_EN_Actividades_UsuarioModificado] FOREIGN KEY ([ModificadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_IdActividadOriginal_EN_Actividades] FOREIGN KEY ([IdActividadOriginal]) REFERENCES [dbo].[EN_Actividades] ([IdActividad]),
    CONSTRAINT [FK_IdRegulador_EN_Actividades] FOREIGN KEY ([IdRegulador]) REFERENCES [dbo].[CO_Regulador] ([IdRegulador])
);

