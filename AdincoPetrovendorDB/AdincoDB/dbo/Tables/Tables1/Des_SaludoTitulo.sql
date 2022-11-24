CREATE TABLE [dbo].[Des_SaludoTitulo] (
    [idTitulo]          INT          IDENTITY (10000, 1) NOT NULL,
    [Titulo]            VARCHAR (50) NULL,
    [AbreviaturaTitulo] VARCHAR (15) NULL,
    CONSTRAINT [PK__Des_Salu__A3113E575DCD4C01] PRIMARY KEY CLUSTERED ([idTitulo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

