CREATE TABLE [dbo].[AP_Excepciones] (
    [IdExcepcion] INT            IDENTITY (1, 1) NOT NULL,
    [Detalle]     NVARCHAR (MAX) NULL,
    [Ubicacion]   NVARCHAR (MAX) NULL,
    [Fecha]       DATETIME       NULL,
    CONSTRAINT [PK_AP_Excepciones] PRIMARY KEY CLUSTERED ([IdExcepcion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

