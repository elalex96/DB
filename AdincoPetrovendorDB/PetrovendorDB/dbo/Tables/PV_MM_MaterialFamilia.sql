CREATE TABLE [dbo].[PV_MM_MaterialFamilia] (
    [IdFamilia]     INT            IDENTITY (10000, 1) NOT NULL,
    [CodFamilia]    NVARCHAR (50)  NULL,
    [Familia]       NVARCHAR (150) NULL,
    [IsActivo]      BIT            NULL,
    [IsEliminado]   BIT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
    CONSTRAINT [PK_PV_MM_MaterialFamilia] PRIMARY KEY CLUSTERED ([IdFamilia] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

