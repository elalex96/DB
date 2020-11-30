CREATE TABLE [dbo].[CP_MetodoCalculo] (
    [IdMetodoCalculo] INT            IDENTITY (1, 1) NOT NULL,
    [Descripcion]     NVARCHAR (MAX) NULL,
    [IdContrato]      INT            NULL,
    [Mes]             DATE           NULL,
    CONSTRAINT [PK_CP_MetodoCalculo] PRIMARY KEY CLUSTERED ([IdMetodoCalculo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

