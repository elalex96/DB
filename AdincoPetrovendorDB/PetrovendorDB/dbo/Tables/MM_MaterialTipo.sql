CREATE TABLE [dbo].[MM_MaterialTipo] (
    [IdTipoMaterial] INT            IDENTITY (10000, 1) NOT NULL,
    [TipoMaterial]   NVARCHAR (MAX) NULL,
    [Activo]         BIT            NULL,
    [CreadoPor]      INT            NULL,
    CONSTRAINT [PK_MM_MaterialTipo] PRIMARY KEY CLUSTERED ([IdTipoMaterial] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

