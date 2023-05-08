CREATE TABLE [dbo].[MM_MaterialMarca] (
    [IdMarca]   INT            IDENTITY (10000, 1) NOT NULL,
    [Marca]     NVARCHAR (MAX) NULL,
    [Activo]    BIT            NULL,
    [CreadoPor] INT            NULL,
    CONSTRAINT [PK_MM_MarcaMaterial] PRIMARY KEY CLUSTERED ([IdMarca] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

