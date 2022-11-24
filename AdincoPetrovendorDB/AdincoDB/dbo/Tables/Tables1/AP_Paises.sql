CREATE TABLE [dbo].[AP_Paises] (
    [idPais]     INT           IDENTITY (1, 1) NOT NULL,
    [NombrePais] NVARCHAR (60) NULL,
    [CodigoPais] INT           NULL,
    PRIMARY KEY CLUSTERED ([idPais] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

