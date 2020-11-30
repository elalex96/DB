CREATE TABLE [dbo].[CO_SAPBankData] (
    [IdContrato]        INT           NOT NULL,
    [BankAccountNumber] VARCHAR (10)  NOT NULL,
    [BankName]          VARCHAR (50)  NOT NULL,
    [AccountOwnerName]  VARCHAR (150) NOT NULL,
    [Currency]          VARCHAR (3)   NOT NULL,
    CONSTRAINT [PK_CO_SAPBankData_1] PRIMARY KEY CLUSTERED ([IdContrato] ASC, [BankAccountNumber] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPBankData_CO_Contrato] FOREIGN KEY ([IdContrato]) REFERENCES [dbo].[CO_Contrato] ([IdContrato])
);

