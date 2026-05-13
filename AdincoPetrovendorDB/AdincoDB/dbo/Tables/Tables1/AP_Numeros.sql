CREATE TABLE [dbo].[AP_Numeros] (
    [Cardinal] INT           NOT NULL,
    [Romano]   VARCHAR (500) NULL,
    CONSTRAINT [PK_AP_Numeros] PRIMARY KEY CLUSTERED ([Cardinal] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

