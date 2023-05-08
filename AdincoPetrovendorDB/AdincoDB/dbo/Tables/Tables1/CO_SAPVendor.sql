CREATE TABLE [dbo].[CO_SAPVendor] (
    [VendorIDSAP]        VARCHAR (20)  NOT NULL,
    [IdContrato]         INT           NOT NULL,
    [VendorName]         VARCHAR (250) NULL,
    [TaxID]              VARCHAR (14)  NULL,
    [Country]            VARCHAR (50)  NULL,
    [Address]            VARCHAR (300) NULL,
    [ContactName]        VARCHAR (250) NULL,
    [ContactEmail]       VARCHAR (100) NULL,
    [CreadoEl]           DATETIME      NULL,
    [CreadoPor]          INT           NULL,
    [ModificadoEl]       DATETIME      NULL,
    [CompanyCode]        VARCHAR (4)   NULL,
    [VendorAccountGroup] VARCHAR (10)  NULL,
    [Activo]             BIT           NULL,
    [KeyLastImport]      VARCHAR (50)  NULL,
    CONSTRAINT [PK_CO_MapeoInterfazVendor] PRIMARY KEY CLUSTERED ([VendorIDSAP] ASC, [IdContrato] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_MapeoInterfazVendor_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

