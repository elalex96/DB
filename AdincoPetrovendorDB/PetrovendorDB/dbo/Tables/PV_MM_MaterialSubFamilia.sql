CREATE TABLE [dbo].[PV_MM_MaterialSubFamilia] (
    [IdSubFamilia]  INT            IDENTITY (10000, 1) NOT NULL,
    [CodSubFamilia] NVARCHAR (50)  NULL,
    [SubFamilia]    NVARCHAR (150) NULL,
    [IsActivo]      BIT            NULL,
    [IsEliminado]   BIT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
    CONSTRAINT [PK_PV_MM_SubFamilia] PRIMARY KEY CLUSTERED ([IdSubFamilia] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

