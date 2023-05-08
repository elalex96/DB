CREATE TABLE [dbo].[MM_HistorialCierrePedido] (
    [IdHistorialCierrePedido] INT             IDENTITY (1, 1) NOT NULL,
    [IdPedido]                INT             NOT NULL,
    [MotivoExterno]           NVARCHAR (1500) NULL,
    [MotivoInterno]           NVARCHAR (1500) NULL,
    [CambiadoPor]             INT             NULL,
    [CambiadoEl]              SMALLDATETIME   NULL,
    [TipoRegistro]            INT             NOT NULL,
    [UltimoCierre]            BIT             NULL,
    CONSTRAINT [PK_MM_HistorialCierrePedido] PRIMARY KEY CLUSTERED ([IdHistorialCierrePedido] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_MM_HistorialCierrePedido_MM_TipoRegistroHistorialCierrePedido] FOREIGN KEY ([TipoRegistro]) REFERENCES [dbo].[MM_TipoRegistroHistorialCierrePedido] ([IdTipoRegistroHistorialCierrePedido])
);

