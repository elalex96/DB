CREATE TABLE [dbo].[CO_LineaProgramaActividadMesDetalle] (
    [Id]                          INT             NOT NULL,
    [IdLineaProgramaActividadMes] INT             NOT NULL,
    [CantidadEjecutar]            DECIMAL (11, 2) NOT NULL,
    [UTUnidad]                    DECIMAL (11, 2) NOT NULL,
    [FechaInicio]                 DATETIME        NOT NULL,
    [FechaFin]                    DATETIME        NOT NULL,
    [Comentarios]                 VARCHAR (300)   NOT NULL,
    [CreadoEl]                    DATETIME        NOT NULL,
    [CreadoPor]                   INT             NOT NULL,
    [IdUnidad]                    INT             NULL,
    CONSTRAINT [PK_CO_LineaProgramaActividadMesDetalle] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdUnidad]) REFERENCES [dbo].[CO_Unidad] ([IdUnidad]),
    CONSTRAINT [FK_CO_LineaProgramaActividadMesDetalle_CO_LineaProgramaActividadMes] FOREIGN KEY ([IdLineaProgramaActividadMes]) REFERENCES [dbo].[CO_LineaProgramaActividadMes] ([IdLineaProgramaActividadMes])
);

