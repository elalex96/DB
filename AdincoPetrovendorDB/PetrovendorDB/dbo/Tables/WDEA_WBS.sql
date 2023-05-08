CREATE TABLE [dbo].[WDEA_WBS] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [WBS]           VARCHAR (300) NULL,
    [CreadoEl]      DATETIME      NULL,
    [ModificadoEl]  DATETIME      NULL,
    [CreadoPor]     INT           NULL,
    [ModificadoPor] INT           NULL,
    [IdContrato]    INT           NULL,
    [Activo]        BIT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

