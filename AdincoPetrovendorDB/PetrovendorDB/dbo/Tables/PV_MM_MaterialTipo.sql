CREATE TABLE [dbo].[PV_MM_MaterialTipo] (
    [IdTipoMaterial] INT            IDENTITY (10000, 1) NOT NULL,
    [Abre]           NVARCHAR (50)  NULL,
    [TipoMaterial]   NVARCHAR (150) NULL,
    [IsActivo]       BIT            NULL,
    [IsEliminado]    BIT            NULL,
    [CreadoPor]      INT            NULL,
    [CreadoEn]       DATETIME       NULL,
    [ModificadoPor]  INT            NULL,
    [ModificadoEn]   DATETIME       NULL,
    CONSTRAINT [PK_PV_MM_MaterialTipo] PRIMARY KEY CLUSTERED ([IdTipoMaterial] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

