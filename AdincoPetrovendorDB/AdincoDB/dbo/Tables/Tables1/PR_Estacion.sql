CREATE TABLE [dbo].[PR_Estacion] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [Clave]          VARCHAR (20)    NOT NULL,
    [Nombre]         VARCHAR (200)   NOT NULL,
    [Descripcion]    NVARCHAR (2000) NOT NULL,
    [Estatus]        TINYINT         NOT NULL,
    [Ramal]          INT             NOT NULL,
    [Zona]           INT             NOT NULL,
    [Campo]          INT             NOT NULL,
    [SigEstacion]    INT             NULL,
    [LimiteTipo]     FLOAT (53)      NULL,
    [PorcentajeAgua] DECIMAL (8, 4)  NULL,
    [PuntoEntregaID] INT             NULL,
    CONSTRAINT [PK_PR_Estacion] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Estacion_Campo] FOREIGN KEY ([Campo]) REFERENCES [dbo].[PR_Campo] ([Id]),
    CONSTRAINT [FK_Estacion_Ramal] FOREIGN KEY ([Ramal]) REFERENCES [dbo].[PR_Ramal] ([Id]),
    CONSTRAINT [FK_Estacion_Zona] FOREIGN KEY ([Zona]) REFERENCES [dbo].[PR_Zona] ([Id]),
    CONSTRAINT [FK_PR_Estacion_CO_PuntosdeEntrega] FOREIGN KEY ([PuntoEntregaID]) REFERENCES [dbo].[CO_PuntosdeEntrega] ([PuntoEntregaID])
);

