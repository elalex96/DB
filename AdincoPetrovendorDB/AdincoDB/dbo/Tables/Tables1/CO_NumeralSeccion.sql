CREATE TABLE [dbo].[CO_NumeralSeccion] (
    [IdNumeralSeccion] INT            IDENTITY (1, 1) NOT NULL,
    [NumeralSeccion]   NVARCHAR (MAX) NULL,
    [CreadoPor]        INT            NULL,
    CONSTRAINT [PK_Cat_General_NumeralSeccion] PRIMARY KEY CLUSTERED ([IdNumeralSeccion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

