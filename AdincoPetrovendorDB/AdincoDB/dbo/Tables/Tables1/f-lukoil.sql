CREATE TABLE [dbo].[f-lukoil] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [Column1]     NVARCHAR (255) NULL,
    [IdProveedor] INT            NULL,
    [Proveedor]   NVARCHAR (MAX) NULL,
    [IdFactura]   INT            NULL,
    CONSTRAINT [PK_f-lukoil] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

