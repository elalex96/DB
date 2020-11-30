CREATE TABLE [dbo].[MM_MaterialSubFamilia] (
    [IdSubFamilia] INT            IDENTITY (10000, 1) NOT NULL,
    [SubFamilia]   NVARCHAR (MAX) NULL,
    [Activo]       BIT            NULL,
    CONSTRAINT [PK_MM_MaterialSubFamilia] PRIMARY KEY CLUSTERED ([IdSubFamilia] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

