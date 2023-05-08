CREATE TABLE [dbo].[CatCFDI_c_TasaOCuota] (
    [Idtasacuota]         INT            IDENTITY (1, 1) NOT NULL,
    [Rango_Fijo]          NVARCHAR (255) NULL,
    [TC_Valormin]         NVARCHAR (255) NULL,
    [TC_Valormax]         NVARCHAR (255) NULL,
    [Impuesto]            NVARCHAR (255) NULL,
    [Factor]              NVARCHAR (255) NULL,
    [Traslado]            NVARCHAR (255) NULL,
    [Retencion]           NVARCHAR (255) NULL,
    [Fechainiciovigencia] DATETIME       NULL,
    [Fechafinvigencia]    NVARCHAR (255) NULL
);

