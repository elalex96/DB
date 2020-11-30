CREATE TABLE [dbo].[CO_SAPSESData] (
    [IdSAPSES]           INT          NOT NULL,
    [IdContrato]         INT          NOT NULL,
    [SESNumber]          VARCHAR (50) NOT NULL,
    [IdSAPPO]            INT          NOT NULL,
    [Currency]           VARCHAR (50) NOT NULL,
    [UOM]                VARCHAR (50) NOT NULL,
    [SESPostingDate]     VARCHAR (15) NOT NULL,
    [SESServiceStart]    VARCHAR (15) NOT NULL,
    [SESServiceEnd]      VARCHAR (15) NOT NULL,
    [Plant]              VARCHAR (20) NOT NULL,
    [SESReferenceNumber] VARCHAR (20) NOT NULL,
    [CreadoEl]           DATETIME     NOT NULL,
    [CreadoPor]          INT          NOT NULL,
    [ModificadoEl]       DATETIME     NULL,
    [ModificadoPor]      INT          NULL,
    CONSTRAINT [PK_CO_SAPSESData] PRIMARY KEY CLUSTERED ([IdSAPSES] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPSESData_CO_SAPPOData] FOREIGN KEY ([IdSAPPO]) REFERENCES [dbo].[CO_SAPPOData] ([IdSAPData])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_SAPSESData]
    ON [dbo].[CO_SAPSESData]([IdContrato] ASC, [SESNumber] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

