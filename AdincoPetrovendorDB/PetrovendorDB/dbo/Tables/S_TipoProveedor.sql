CREATE TABLE [dbo].[S_TipoProveedor] (
    [IdTipoProveedor] INT            IDENTITY (1, 1) NOT NULL,
    [TipoProveedor]   NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_S_TipoProveedor] PRIMARY KEY CLUSTERED ([IdTipoProveedor] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

