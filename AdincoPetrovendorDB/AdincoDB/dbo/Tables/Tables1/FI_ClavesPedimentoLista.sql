CREATE TABLE [dbo].[FI_ClavesPedimentoLista] (
    [IdPedimentoLista]   INT            IDENTITY (1, 1) NOT NULL,
    [IdClavePedimento]   INT            NULL,
    [TipoClavePedimento] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_FI_PedimentoLista] PRIMARY KEY CLUSTERED ([IdPedimentoLista] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);


GO
CREATE NONCLUSTERED INDEX [IX_FI_ClavesPedimento]
    ON [dbo].[FI_ClavesPedimentoLista]([IdClavePedimento] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

