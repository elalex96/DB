CREATE TABLE [dbo].[PR_FI_CFDIConceptoImpuesto] (
    [IdConceptoImpuesto] INT           IDENTITY (10000, 1) NOT NULL,
    [IdFacturaConcepto]  BIGINT        NULL,
    [IdTipoImpuesto]     INT           NULL,
    [NombreImpuesto]     NVARCHAR (50) NULL,
    [Base]               MONEY         NULL,
    [Impuesto]           NVARCHAR (50) NULL,
    [TipoFactor]         NVARCHAR (50) NULL,
    [Tasa]               FLOAT (53)    NULL,
    [Importe]            MONEY         NULL,
    [IdEliminacion]      INT           NULL,
    CONSTRAINT [PK_PR_FI_CFDIConceptoImpuesto] PRIMARY KEY CLUSTERED ([IdConceptoImpuesto] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

