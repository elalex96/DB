CREATE TYPE CO_Type_SAPVendor AS TABLE
(
	[NumeroFila] INT NULL,
    [VendorIDSAP] VARCHAR(20)  NULL,
    [VendorName] VARCHAR(250) NULL,
    [TaxID] VARCHAR(14) NULL,
    [Country] VARCHAR(50) NULL,
    [Address] VARCHAR(300) NULL,
    [ContactName] VARCHAR(250) NULL,
    [ContactEmail] VARCHAR(100) NULL,
    [CompanyCode] VARCHAR(4) NULL,
    [VendorAccountGroup] VARCHAR(10) NULL,
    [KeyLastImport] VARCHAR(50) NULL
);