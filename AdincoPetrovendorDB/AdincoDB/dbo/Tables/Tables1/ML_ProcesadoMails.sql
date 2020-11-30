CREATE TABLE [dbo].[ML_ProcesadoMails] (
    [IdProcesadoMails] INT            IDENTITY (10000, 1) NOT NULL,
    [UID]              NVARCHAR (250) NULL,
    [Numero]           INT            NULL,
    [De]               NVARCHAR (500) NULL,
    [Para]             NVARCHAR (500) NULL,
    [Asunto]           NVARCHAR (500) NULL,
    [Fecha]            DATETIME       NULL,
    [FechaEnvio]       DATETIME       NULL,
    [AdincoMailId]     INT            NULL,
    CONSTRAINT [PK_ProcesadoMails] PRIMARY KEY CLUSTERED ([IdProcesadoMails] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

