CREATE TABLE [dbo].[CP_PrecioPetroleoEquivalenteFOB] (
    [IdPrecioPetroleoEquivalente] INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]                  INT            NULL,
    [Mes]                         DATE           NULL,
    [TipoPetroleo]                NVARCHAR (MAX) NULL,
    [GradosAPI]                   FLOAT (53)     NULL,
    [Azufre]                      FLOAT (53)     NULL,
    [PrecioFreeOnBoard]           MONEY          NULL,
    [CreadoPor]                   INT            NULL,
    [CreadoEl]                    DATETIME       NULL,
    [ModificadoPor]               INT            NULL,
    [ModificadoEl]                DATETIME       NULL,
    [Activo]                      BIT            NULL,
    CONSTRAINT [PK_CP_PrecioPetroleoEquivalenteFOB] PRIMARY KEY CLUSTERED ([IdPrecioPetroleoEquivalente] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

