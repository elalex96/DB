CREATE TABLE [dbo].[CO_SAPPODataDetalle] (
    [IdSAPDataDetalle]         INT           NOT NULL,
    [ItemNumber]               TINYINT       NOT NULL,
    [SAPMaterialNumber]        VARCHAR (50)  NULL,
    [Quantity]                 FLOAT (53)    NULL,
    [UnitPrice]                FLOAT (53)    NULL,
    [Total]                    FLOAT (53)    NULL,
    [DeliveryDate]             VARCHAR (8)   NULL,
    [MaterialGroup]            VARCHAR (50)  NULL,
    [MaterialGroupDescription] VARCHAR (250) NULL,
    [ServiceLineNumber]        VARCHAR (50)  NULL,
    [Quantity2]                FLOAT (53)    NULL,
    [Price2]                   FLOAT (53)    NULL,
    [CostObject2]              VARCHAR (20)  NULL,
    [ServiceGroup]             VARCHAR (50)  NULL,
    [ShortText]                VARCHAR (100) NULL,
    [ParentLineUOM]            VARCHAR (50)  NULL,
    [ServiceShortText]         VARCHAR (50)  NULL,
    [ServicesUOM]              VARCHAR (50)  NULL,
    [POItemCategory]           TINYINT       NULL,
    [CreadoEl]                 DATETIME      NULL,
    [CreadoPor]                INT           NULL,
    [ModificadoEl]             DATETIME      NULL,
    [IdSAPData]                INT           NULL,
    CONSTRAINT [PK_CO_SAPDataDetalle] PRIMARY KEY CLUSTERED ([IdSAPDataDetalle] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    FOREIGN KEY ([IdSAPData]) REFERENCES [dbo].[CO_SAPPOData] ([IdSAPData])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_SAPDataDetalle]
    ON [dbo].[CO_SAPPODataDetalle]([ItemNumber] ASC, [SAPMaterialNumber] ASC, [IdSAPData] ASC, [ServiceLineNumber] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

