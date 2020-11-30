CREATE TABLE [dbo].[Excepciones] (
    [IdExcepcion] INT            IDENTITY (1, 1) NOT NULL,
    [Detalle]     NVARCHAR (MAX) NULL,
    [Ubicacion]   NVARCHAR (MAX) NULL,
    [Fecha]       DATETIME       NULL,
    CONSTRAINT [PK_Excepciones] PRIMARY KEY CLUSTERED ([IdExcepcion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

