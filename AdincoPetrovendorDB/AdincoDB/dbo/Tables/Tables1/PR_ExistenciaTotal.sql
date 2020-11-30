CREATE TABLE [dbo].[PR_ExistenciaTotal] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [Bruta]            DECIMAL (24, 8) NULL,
    [Neta]             DECIMAL (24, 8) NULL,
    [Agua_Sedimento]   DECIMAL (24, 8) NULL,
    [Fecha]            DATETIME        NULL,
    [Modificado]       DATETIME        NULL,
    [ModificadoPor]    VARCHAR (200)   NULL,
    [ModificadoServer] DATETIME        NULL,
    CONSTRAINT [PK_PR_ExistenciaTotal] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

