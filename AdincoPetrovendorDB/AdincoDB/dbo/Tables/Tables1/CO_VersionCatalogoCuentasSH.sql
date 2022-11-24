CREATE TABLE [dbo].[CO_VersionCatalogoCuentasSH] (
    [IdVersion]        INT            IDENTITY (10000, 1) NOT NULL,
    [Descripcion]      NVARCHAR (MAX) NULL,
    [FechaPublicacion] DATE           NULL,
    [Activo]           BIT            NULL,
    [CreadoPor]        INT            NULL,
    [CreadoEn]         DATETIME       NULL,
    [ModificadoPor]    INT            NULL,
    [ModificadoEn]     DATETIME       NULL,
    CONSTRAINT [PK_CO_VersionesCatalogoCuentasSH] PRIMARY KEY CLUSTERED ([IdVersion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

