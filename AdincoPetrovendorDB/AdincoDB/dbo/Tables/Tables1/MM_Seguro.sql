CREATE TABLE [dbo].[MM_Seguro] (
    [IdSeguro]   INT           IDENTITY (1, 1) NOT NULL,
    [Seguro]     VARCHAR (MAX) NOT NULL,
    [Decripcion] VARCHAR (MAX) NOT NULL,
    [Activo]     BIT           NOT NULL,
    CONSTRAINT [PK_MM_Seguro] PRIMARY KEY CLUSTERED ([IdSeguro] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

