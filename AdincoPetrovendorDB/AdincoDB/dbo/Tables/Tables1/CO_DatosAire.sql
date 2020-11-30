CREATE TABLE [dbo].[CO_DatosAire] (
    [idDatoAire] INT        IDENTITY (1000, 1) NOT NULL,
    [PMaire]     FLOAT (53) NULL,
    [Densaire]   FLOAT (53) NULL,
    PRIMARY KEY CLUSTERED ([idDatoAire] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

