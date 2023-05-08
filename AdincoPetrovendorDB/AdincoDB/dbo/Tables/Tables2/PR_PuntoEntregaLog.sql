CREATE TABLE [dbo].[PR_PuntoEntregaLog] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [IdLog]            INT             NOT NULL,
    [Bruta]            DECIMAL (24, 8) NULL,
    [Neta]             DECIMAL (24, 8) NULL,
    [Agua_Sedimento]   DECIMAL (24, 8) NULL,
    [Fecha]            DATETIME        NULL,
    [Modificado]       DATETIME        NULL,
    [ModificadoPor]    VARCHAR (200)   NULL,
    [ModificadoServer] DATETIME        NULL,
    [GradoAPI]         DECIMAL (24, 8) NULL,
    [AjusteProduccion] DECIMAL (24, 8) NULL,
    CONSTRAINT [PK_PR_PuntoEntregaLog] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

