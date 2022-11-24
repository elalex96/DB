CREATE TABLE [dbo].[FI_CPDocRelacionado] (
    [IdDocRelacionado]    INT            IDENTITY (10000, 1) NOT NULL,
    [IdComplementoDePago] INT            NULL,
    [IdDocumento]         NVARCHAR (300) NULL,
    [Serie]               NVARCHAR (50)  NULL,
    [Folio]               NVARCHAR (50)  NULL,
    [MetodoDePagoDR]      NVARCHAR (50)  NULL,
    [MonedaDR]            NVARCHAR (50)  NULL,
    [ImpSaldoAnt]         MONEY          NULL,
    [ImpSaldoInsoluto]    MONEY          NULL,
    [ImpPagado]           MONEY          NULL,
    [NumParcialidad]      INT            NULL,
    [TipoDeCambioDR]      FLOAT (53)     NULL,
    CONSTRAINT [PK_FI_CPDocRelacionado] PRIMARY KEY CLUSTERED ([IdDocRelacionado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_FI_CPDocRelacionado_FI_ComplementoDePago] FOREIGN KEY ([IdComplementoDePago]) REFERENCES [dbo].[FI_ComplementoDePago] ([IdComplementoDePago])
);


GO
CREATE NONCLUSTERED INDEX [IDX_UUID]
    ON [dbo].[FI_CPDocRelacionado]([IdDocumento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

