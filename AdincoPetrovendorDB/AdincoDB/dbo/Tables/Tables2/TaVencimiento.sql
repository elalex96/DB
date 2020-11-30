CREATE TABLE [dbo].[TaVencimiento] (
    [IdVencimiento]  INT IDENTITY (1, 1) NOT NULL,
    [DiaVencimiento] INT NULL,
    CONSTRAINT [PK_TaVencimiento] PRIMARY KEY CLUSTERED ([IdVencimiento] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

