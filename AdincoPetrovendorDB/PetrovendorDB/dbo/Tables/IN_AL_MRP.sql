CREATE TABLE [dbo].[IN_AL_MRP] (
    [CantidadMaxima]      DECIMAL (14, 2) NOT NULL,
    [CantidadMinima]      DECIMAL (14, 2) NOT NULL,
    [CantidadSobreMinimo] DECIMAL (14, 2) NOT NULL,
    [CreadoEl]            DATETIME        NOT NULL,
    [CreadoPor]           INT             NOT NULL,
    [IdAlmacen]           INT             NOT NULL,
    [IdLineaPresupuesto]  INT             NOT NULL,
    [IdMaterial]          INT             NOT NULL,
    [ModificadoEl]        DATETIME        NULL,
    [ModificadoPor]       INT             NULL
);

