CREATE TABLE [dbo].[CO_SAPFI_Invoice] (
    [IdContrato]              INT           NOT NULL,
    [InvoiceNumber]           VARCHAR (20)  NOT NULL,
    [InvoiceLine]             TINYINT       NOT NULL,
    [FiscalYear]              SMALLINT      NOT NULL,
    [PostingDate]             VARCHAR (10)  NOT NULL,
    [VendorNumber]            VARCHAR (20)  NOT NULL,
    [VendorName]              VARCHAR (150) NOT NULL,
    [InvoiceAmount]           FLOAT (53)    NOT NULL,
    [Currency]                VARCHAR (5)   NOT NULL,
    [ReferenceDocumentNumber] VARCHAR (10)  NOT NULL,
    [CostCentre]              VARCHAR (10)  NOT NULL,
    [WBS]                     VARCHAR (20)  NOT NULL,
    [GLAccount]               VARCHAR (20)  NOT NULL,
    [LineAmount]              FLOAT (53)    NOT NULL,
    [CreadoEl]                DATETIME      NOT NULL,
    CONSTRAINT [PK_CO_SAP_FI_Invoice_1] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [InvoiceNumber] ASC, [InvoiceLine] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

