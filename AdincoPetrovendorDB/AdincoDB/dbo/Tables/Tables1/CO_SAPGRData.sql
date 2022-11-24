CREATE TABLE [dbo].[CO_SAPGRData] (
    [IdSAPGR]           INT          NOT NULL,
    [IdSAPPO]           INT          NOT NULL,
    [DocumentDate]      VARCHAR (15) NOT NULL,
    [UOM]               VARCHAR (50) NOT NULL,
    [DocPostingDate]    VARCHAR (15) NOT NULL,
    [Plant]             VARCHAR (15) NOT NULL,
    [ReferenceNumber]   VARCHAR (20) NOT NULL,
    [Moneda]            VARCHAR (50) NOT NULL,
    [AccountAssignment] VARCHAR (1)  NOT NULL,
    [CreadoEl]          DATETIME     NOT NULL,
    [CreadoPor]         INT          NOT NULL,
    [ModificadoEl]      DATETIME     NULL,
    [ModificadoPor]     INT          NULL,
    [MatDocN]           VARCHAR (15) NULL,
    CONSTRAINT [PK_CO_SAPGRData] PRIMARY KEY CLUSTERED ([IdSAPGR] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPGRData_CO_SAPPOData] FOREIGN KEY ([IdSAPPO]) REFERENCES [dbo].[CO_SAPPOData] ([IdSAPData])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_SAPGRData]
    ON [dbo].[CO_SAPGRData]([IdSAPPO] ASC, [DocumentDate] ASC, [MatDocN] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON);

