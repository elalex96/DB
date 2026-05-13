CREATE TABLE [dbo].[CatCFDI_c_Impuesto] (
    [IdImpuesto]     INT            IDENTITY (1, 1) NOT NULL,
    [c_Impuesto]     NVARCHAR (255) NULL,
    [Descripcion]    NVARCHAR (255) NULL,
    [Retencion]      NVARCHAR (255) NULL,
    [Traslado]       NVARCHAR (255) NULL,
    [Local_ federal] NVARCHAR (255) NULL,
    [Entidadaplica]  NVARCHAR (255) NULL
);

