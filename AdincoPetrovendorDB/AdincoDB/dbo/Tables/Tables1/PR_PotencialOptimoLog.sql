CREATE TABLE [dbo].[PR_PotencialOptimoLog] (
    [Idlog]            INT             IDENTITY (1, 1) NOT NULL,
    [Id]               INT             NULL,
    [Pozo]             INT             NULL,
    [ProduccionBruta]  DECIMAL (24, 8) NULL,
    [ProduccionNeta]   DECIMAL (24, 8) NULL,
    [Gas]              DECIMAL (24, 8) NULL,
    [Agua]             DECIMAL (8, 4)  NULL,
    [Alta]             DATETIME        NULL,
    [Comentarios]      NVARCHAR (MAX)  NULL,
    [Modificado]       DATETIME        NULL,
    [ModificadoPor]    NVARCHAR (2000) NULL,
    [ModificadoServer] DATETIME        NULL,
    CONSTRAINT [PK_PR_PotencialOptimoLog] PRIMARY KEY CLUSTERED ([Idlog] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

