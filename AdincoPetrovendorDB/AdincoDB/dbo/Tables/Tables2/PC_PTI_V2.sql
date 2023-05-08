CREATE TABLE [dbo].[PC_PTI_V2] (
    [IdPTI]           INT            IDENTITY (10000, 1) NOT NULL,
    [IdContrato]      INT            NULL,
    [FechaReporte]    DATE           NULL,
    [Sociedad]        NVARCHAR (255) NULL,
    [Estado]          NVARCHAR (255) NULL,
    [TipoDoc]         NVARCHAR (255) NULL,
    [NombreCliente]   NVARCHAR (255) NULL,
    [UUID]            NVARCHAR (255) NULL,
    [Ejercicio]       NVARCHAR (255) NULL,
    [Serie]           NVARCHAR (255) NULL,
    [Factura]         NVARCHAR (255) NULL,
    [Emisor]          NVARCHAR (255) NULL,
    [Receptor]        NVARCHAR (255) NULL,
    [FechaFactura]    NVARCHAR (50)  NULL,
    [TipoComp]        NVARCHAR (255) NULL,
    [Subtotal]        MONEY          NULL,
    [Impuestos]       MONEY          NULL,
    [Total]           MONEY          NULL,
    [FechaExpedicion] NVARCHAR (50)  NULL,
    [Moneda]          NVARCHAR (50)  NULL,
    [Tasa]            FLOAT (53)     NULL,
    [ClaveCliente]    NVARCHAR (255) NULL,
    [Folio]           NVARCHAR (255) NULL,
    [FechaTimbrado]   NVARCHAR (50)  NULL,
    [MetodoPago]      NVARCHAR (255) NULL,
    [CreadoPor]       INT            NULL,
    [CreadoEn]        DATETIME       NULL,
    CONSTRAINT [PK_PC_PTI_V2] PRIMARY KEY CLUSTERED ([IdPTI] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_PC_PTI_V2_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);


GO
CREATE NONCLUSTERED INDEX [idx_Factura]
    ON [dbo].[PC_PTI_V2]([Factura] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);


GO
CREATE NONCLUSTERED INDEX [idx_UUID]
    ON [dbo].[PC_PTI_V2]([UUID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

