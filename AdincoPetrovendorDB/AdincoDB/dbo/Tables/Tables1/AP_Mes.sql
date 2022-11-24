CREATE TABLE [dbo].[AP_Mes] (
    [idMes]     INT          IDENTITY (1, 1) NOT NULL,
    [Mes]       VARCHAR (50) NOT NULL,
    [CreadoPor] INT          NULL,
    [MesEng]    VARCHAR (30) NULL,
    CONSTRAINT [PK_Mes] PRIMARY KEY CLUSTERED ([idMes] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

