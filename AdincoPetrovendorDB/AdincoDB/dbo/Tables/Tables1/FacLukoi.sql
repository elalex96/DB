CREATE TABLE [dbo].[FacLukoi] (
    [Id]          INT            IDENTITY (1, 1) NOT NULL,
    [NombrePDF]   NVARCHAR (255) NULL,
    [IdProveedor] INT            NULL,
    [Proveedor]   NVARCHAR (MAX) NULL,
    [IdFactura]   INT            NULL,
    CONSTRAINT [PK_FacLukoi] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

