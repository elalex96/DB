CREATE TABLE [dbo].[CO_SubactividadCIEP] (
    [IdSubactividad]     INT            IDENTITY (1, 1) NOT NULL,
    [IdActividad]        INT            NULL,
    [ID_CATSUBACTIV]     NVARCHAR (MAX) NULL,
    [NombreSubactividad] NVARCHAR (MAX) NULL,
    [IdTipoServicio]     INT            NULL,
    [IdUsuario]          INT            NULL,
    [FecMovto]           DATETIME       NULL,
    [Activo]             BIT            NULL,
    [CreadoPor]          INT            NULL,
    CONSTRAINT [PK_Subactividades] PRIMARY KEY CLUSTERED ([IdSubactividad] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Subactividades_Actividades] FOREIGN KEY ([IdActividad]) REFERENCES [dbo].[CO_ActividadCIEP] ([IdActividad]),
    CONSTRAINT [FK_Subactividades_Subactividades] FOREIGN KEY ([IdSubactividad]) REFERENCES [dbo].[CO_SubactividadCIEP] ([IdSubactividad]),
    CONSTRAINT [FK_Subactividades_Usuarios] FOREIGN KEY ([IdUsuario]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID])
);

