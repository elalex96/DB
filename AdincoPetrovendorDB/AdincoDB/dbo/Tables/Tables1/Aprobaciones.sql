CREATE TABLE [dbo].[Aprobaciones] (
    [IdAprobacion]   INT           NOT NULL,
    [IdFlujoDetalle] INT           NULL,
    [Aprobado]       BIT           NULL,
    [Activo]         BIT           NULL,
    [IdGenerico]     INT           NULL,
    [Tabla]          VARCHAR (100) NULL,
    [Motivo]         VARCHAR (MAX) NULL,
    CONSTRAINT [PK_Aprobaciones] PRIMARY KEY CLUSTERED ([IdAprobacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Aprobaciones_CAT_FlujosDetalle] FOREIGN KEY ([IdFlujoDetalle]) REFERENCES [dbo].[CAT_FlujosDetalle] ([IdFlujoDetalle])
);

