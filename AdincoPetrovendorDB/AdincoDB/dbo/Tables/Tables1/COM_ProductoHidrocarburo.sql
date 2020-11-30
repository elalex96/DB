CREATE TABLE [dbo].[COM_ProductoHidrocarburo] (
    [IdProductoHidrocarburo] INT            IDENTITY (10000, 1) NOT NULL,
    [Clave]                  NVARCHAR (MAX) NULL,
    [ProductoHidrocarburo]   NVARCHAR (MAX) NULL,
    [IdTipoHidrocarburo]     INT            NULL,
    CONSTRAINT [PK_COM_ProductoHidrocarburo] PRIMARY KEY CLUSTERED ([IdProductoHidrocarburo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

