CREATE TABLE [dbo].[PurchaseOrganization] (
    [IdPurchaseOrganization] INT           NOT NULL,
    [IdContrato]             INT           NULL,
    [Siglas]                 VARCHAR (10)  NULL,
    [Descripcion]            VARCHAR (100) NULL,
    CONSTRAINT [PK_PurchaseOrganization] PRIMARY KEY CLUSTERED ([IdPurchaseOrganization] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

