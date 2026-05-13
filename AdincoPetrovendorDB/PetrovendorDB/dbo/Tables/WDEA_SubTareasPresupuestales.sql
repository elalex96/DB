CREATE TABLE [dbo].[WDEA_SubTareasPresupuestales] (
    [Id]                INT           NOT NULL,
    [IdContrato]        INT           NULL,
    [Tarea]             INT           NULL,
    [IdSubtarea]        INT           NULL,
    [Descripcion]       VARCHAR (MAX) NULL,
    [IdentificadorWDEA] VARCHAR (5)   NULL,
    CONSTRAINT [PK_WDEA_SubTareasPresupuestales] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

