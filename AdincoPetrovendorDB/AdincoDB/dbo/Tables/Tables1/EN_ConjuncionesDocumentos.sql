CREATE TABLE [dbo].[EN_ConjuncionesDocumentos] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [Palabra]        VARCHAR (500) NULL,
    [Sustitucion]    VARCHAR (300) NULL,
    [Activo]         BIT           NULL,
    [CreadoPor]      INT           NULL,
    [CreadoEl]       DATETIME      NULL,
    [ModificacdoPor] INT           NULL,
    [ModificadoEl]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80)
);

