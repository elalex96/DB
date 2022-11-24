CREATE TABLE [dbo].[MM_TipoRegistroHistorialCierrePedido] (
    [IdTipoRegistroHistorialCierrePedido] INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]                              NVARCHAR (50) NOT NULL,
    CONSTRAINT [PK_MM_TipoRegistroHistorialCierrePedido] PRIMARY KEY CLUSTERED ([IdTipoRegistroHistorialCierrePedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

