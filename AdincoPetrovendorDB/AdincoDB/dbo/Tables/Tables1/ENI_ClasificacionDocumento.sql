CREATE TABLE [dbo].[ENI_ClasificacionDocumento] (
    [IdClasificacionDocumento] INT          IDENTITY (10000, 1) NOT NULL,
    [Clasificacion]            BIT          NULL,
    [Descripcion]              VARCHAR (50) NULL,
    CONSTRAINT [PK_ENI_ClasificacionDocumento] PRIMARY KEY CLUSTERED ([IdClasificacionDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

