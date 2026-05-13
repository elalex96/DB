CREATE TABLE [dbo].[TA_Vencimiento] (
    [IdVencimiento]  INT IDENTITY (1, 1) NOT NULL,
    [DiaVencimiento] INT NULL,
    CONSTRAINT [PK_TaVencimiento] PRIMARY KEY CLUSTERED ([IdVencimiento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

