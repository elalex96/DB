CREATE TABLE [dbo].[FI_CFDIConceptoImpuesto] (
    [IdConceptoImpuesto] INT           IDENTITY (10000, 1) NOT NULL,
    [IdFacturaConcepto]  BIGINT        NULL,
    [IdTipoImpuesto]     INT           NULL,
    [NombreImpuesto]     NVARCHAR (50) NULL,
    [Base]               MONEY         NULL,
    [Impuesto]           NVARCHAR (50) NULL,
    [TipoFactor]         NVARCHAR (50) NULL,
    [Tasa]               FLOAT (53)    NULL,
    [Importe]            MONEY         NULL,
    CONSTRAINT [PK_FI_CFDIConceptoImpuesto] PRIMARY KEY CLUSTERED ([IdConceptoImpuesto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_CFDIConceptoImpuesto_FI_CFDIConceptoImpuesto] FOREIGN KEY ([IdFacturaConcepto]) REFERENCES [dbo].[FI_CFDIConcepto] ([IdFacturaConcepto])
);

