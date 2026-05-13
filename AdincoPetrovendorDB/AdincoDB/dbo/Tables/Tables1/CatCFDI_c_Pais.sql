CREATE TABLE [dbo].[CatCFDI_c_Pais] (
    [IdPais]                                INT            IDENTITY (1, 1) NOT NULL,
    [c_Pais]                                NVARCHAR (255) NULL,
    [Descripcion]                           NVARCHAR (255) NULL,
    [Formatocodigopostal]                   NVARCHAR (255) NULL,
    [FormatoRegistroIdentidadTributaria]    NVARCHAR (255) NULL,
    [ValidacionRegistroIdentidadTributaria] NVARCHAR (255) NULL,
    [Agrupaciones]                          NVARCHAR (255) NULL
);

