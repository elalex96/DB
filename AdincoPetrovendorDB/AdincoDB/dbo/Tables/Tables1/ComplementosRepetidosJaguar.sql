CREATE TABLE [dbo].[ComplementosRepetidosJaguar] (
    [CantComplementos]       INT            NULL,
    [IdDocumento]            NVARCHAR (300) NULL,
    [Serie]                  NVARCHAR (50)  NULL,
    [Folio]                  NVARCHAR (50)  NULL,
    [MetodoDePagoDR]         NVARCHAR (50)  NULL,
    [MonedaDR]               NVARCHAR (50)  NULL,
    [ImpSaldoAnt]            MONEY          NULL,
    [ImpSaldoInsoluto]       MONEY          NULL,
    [ImpPagado]              MONEY          NULL,
    [NumParcialidad]         INT            NULL,
    [CantFacturas]           INT            NULL,
    [TieneTransfer]          BIT            NULL,
    [IdDocRelacionadoQuitar] INT            NULL,
    [IdComplementoQuitar]    INT            NULL
);

