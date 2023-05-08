CREATE TABLE [dbo].[PV_MM_MaterialUnidad] (
    [IdUnidad]      INT           IDENTITY (10000, 1) NOT NULL,
    [Unidad]        NVARCHAR (50) NULL,
    [UMB]           NVARCHAR (50) NULL,
    [IsActivo]      BIT           NULL,
    [IsEliminado]   BIT           NULL,
    [CreadoPor]     INT           NULL,
    [CreadoEn]      DATETIME      NULL,
    [ModificadoPor] INT           NULL,
    [ModificadoEn]  DATETIME      NULL,
    CONSTRAINT [PK_PV_MM_MaterialUnidad] PRIMARY KEY CLUSTERED ([IdUnidad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

