CREATE TABLE [dbo].[CO_SAPPOData] (
    [IdSAPData]       INT           NOT NULL,
    [IdContrato]      INT           NOT NULL,
    [SAPPONumber]     VARCHAR (20)  NOT NULL,
    [VersionNumber]   TINYINT       NULL,
    [SAPVendorNumber] VARCHAR (20)  NULL,
    [Currency]        VARCHAR (50)  NULL,
    [Deliveryaddress] VARCHAR (250) NULL,
    [Comments]        VARCHAR (250) NULL,
    [CostObject]      VARCHAR (20)  NULL,
    [Plant]           VARCHAR (15)  NULL,
    [CreadoEl]        DATETIME      NULL,
    [CreadoPor]       INT           NULL,
    [ModificadoEl]    DATETIME      NULL,
    [Activo]          BIT           NULL,
    [CanceladoPor]    INT           NULL,
    [CanceladoEl]     DATETIME      NULL,
    CONSTRAINT [PK_CO_SAPData] PRIMARY KEY CLUSTERED ([IdSAPData] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPData_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_SAPData]
    ON [dbo].[CO_SAPPOData]([IdContrato] ASC, [SAPPONumber] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

