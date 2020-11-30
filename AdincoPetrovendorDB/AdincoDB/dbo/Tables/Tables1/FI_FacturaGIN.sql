CREATE TABLE [dbo].[FI_FacturaGIN] (
    [Id]       INT             IDENTITY (1, 1) NOT NULL,
    [Fecha]    DATE            NULL,
    [Grupo]    VARCHAR (50)    NULL,
    [Acreedor] INT             NULL,
    [Sociedad] INT             NULL,
    [Pedido]   VARCHAR (50)    NULL,
    [Serie]    VARCHAR (50)    NULL,
    [Folio]    VARCHAR (50)    NULL,
    [Moneda]   VARCHAR (50)    NULL,
    [Subtotal] DECIMAL (19, 2) NULL,
    [VOBT]     FLOAT (53)      NULL,
    [VOBI]     FLOAT (53)      NULL,
    [CIBT]     FLOAT (53)      NULL,
    [CIBI]     FLOAT (53)      NULL,
    [GIN]      DECIMAL (3, 2)  NULL,
    [Factura]  INT             NULL,
    CONSTRAINT [PK_GIN] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

