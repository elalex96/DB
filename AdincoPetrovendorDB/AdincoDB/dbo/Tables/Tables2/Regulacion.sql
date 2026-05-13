CREATE TABLE [dbo].[Regulacion] (
    [ID]               NVARCHAR (255) NULL,
    [TítuloDocumento]  NVARCHAR (MAX) NULL,
    [Dependencia]      NVARCHAR (255) NULL,
    [ClavePublicación] NVARCHAR (255) NULL,
    [ProductoRegulado] NVARCHAR (255) NULL,
    [FechaPublicación] FLOAT (53)     NULL,
    [Publicacion]      NVARCHAR (255) NULL,
    [LigaPublicacion]  NVARCHAR (255) NULL,
    [Anexos]           NVARCHAR (255) NULL,
    [LigaAnexo]        NVARCHAR (255) NULL,
    [PublicadoEn]      NVARCHAR (255) NULL,
    [Empresa]          NVARCHAR (255) NULL
);

