CREATE TABLE [dbo].[CO_SubcontratistaCatalogo] (
    [IdSubcontratistaCatalogo] INT IDENTITY (1, 1) NOT NULL,
    [IdSubcontratista]         INT NULL,
    [IdCatalogoCuentasSH]      INT NULL,
    CONSTRAINT [PK_CO_SubcontratistaCatalogo] PRIMARY KEY CLUSTERED ([IdSubcontratistaCatalogo] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

