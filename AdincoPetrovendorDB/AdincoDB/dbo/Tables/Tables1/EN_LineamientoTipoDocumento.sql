CREATE TABLE [dbo].[EN_LineamientoTipoDocumento] (
    [IdLineamientoTipoDocumento] INT           IDENTITY (10000, 1) NOT NULL,
    [TipoDocumento]              VARCHAR (100) NULL,
    [CreadoEl]                   DATETIME      NULL,
    [CreadoPor]                  VARCHAR (50)  NULL,
    [ModificadoEl]               DATETIME      NULL,
    [ModificadoPor]              VARCHAR (100) NULL,
    CONSTRAINT [PK__EN_Linea__6557F2DC90F32E91] PRIMARY KEY CLUSTERED ([IdLineamientoTipoDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

