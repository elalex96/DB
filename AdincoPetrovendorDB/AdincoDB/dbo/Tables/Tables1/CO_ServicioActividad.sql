CREATE TABLE [dbo].[CO_ServicioActividad] (
    [IdServicioActividad] INT IDENTITY (1, 1) NOT NULL,
    [IdTipoServicio]      INT NULL,
    [IdActividad]         INT NULL,
    [Orden]               INT NULL,
    [CreadoPor]           INT NULL,
    CONSTRAINT [PK_ServicioActividad] PRIMARY KEY CLUSTERED ([IdServicioActividad] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_ServicioActividad_Actividades] FOREIGN KEY ([IdActividad]) REFERENCES [dbo].[CO_ActividadCIEP] ([IdActividad]),
    CONSTRAINT [FK_ServicioActividad_TipoServicio] FOREIGN KEY ([IdTipoServicio]) REFERENCES [dbo].[CO_TipoServicio] ([IdTipoServicio])
);

