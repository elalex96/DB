CREATE TABLE [dbo].[CO_CatalogoCuentaSH] (
    [IdCatalogoCuentasSH] INT            IDENTITY (1, 1) NOT NULL,
    [IdVersion]           INT            NULL,
    [Consecutivo]         FLOAT (53)     NULL,
    [Nivel1]              NVARCHAR (MAX) NULL,
    [Nivel2]              NVARCHAR (MAX) NULL,
    [Nivel3]              NVARCHAR (MAX) NULL,
    [Descripcion]         NVARCHAR (MAX) NULL,
    [Nivel]               NVARCHAR (MAX) NULL,
    [CreadoPor]           INT            NULL,
    [Todo]                NVARCHAR (MAX) NULL,
    [Inversion]           BIT            NULL,
    [Operacion]           BIT            NULL,
    CONSTRAINT [PK_CatalogoCuentasSH] PRIMARY KEY CLUSTERED ([IdCatalogoCuentasSH] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_CatalogoCuentaSH_CO_VersionCatalogoCuentasSH] FOREIGN KEY ([IdVersion]) REFERENCES [dbo].[CO_VersionCatalogoCuentasSH] ([IdVersion])
);

