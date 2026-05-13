CREATE TABLE [dbo].[PR_ParoLog] (
    [IdLog]              INT             IDENTITY (1, 1) NOT NULL,
    [Id]                 INT             NOT NULL,
    [Pozo]               INT             NOT NULL,
    [Inicio]             DATETIME        NOT NULL,
    [Fin]                DATETIME        NULL,
    [Duracion]           DECIMAL (24, 8) NULL,
    [Programado]         TINYINT         NOT NULL,
    [Motivo]             INT             NOT NULL,
    [Estatus]            TINYINT         NOT NULL,
    [Origen]             INT             NOT NULL,
    [ProduccionDiferida] DECIMAL (24, 8) NOT NULL,
    [Comentarios]        NVARCHAR (2000) NULL,
    [Finalizado]         INT             NOT NULL,
    [Modificado]         DATETIME        NULL,
    [ModificadoPor]      VARCHAR (200)   NULL,
    [ModificadoServer]   DATETIME        NULL,
    CONSTRAINT [PK_PR__ParoLog] PRIMARY KEY CLUSTERED ([IdLog] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

