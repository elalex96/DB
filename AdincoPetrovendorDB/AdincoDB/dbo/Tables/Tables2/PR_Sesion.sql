CREATE TABLE [dbo].[PR_Sesion] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [Usuario]       VARCHAR (200)   NULL,
    [Host]          VARCHAR (200)   NULL,
    [Entrada]       DATETIME        NULL,
    [Salida]        DATETIME        NULL,
    [Minutos]       DECIMAL (24, 8) NULL,
    [EntradaServer] DATETIME        NULL,
    CONSTRAINT [PK_PR_Sesion] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

