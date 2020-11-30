CREATE TABLE [dbo].[CO_SAPGRDataDetalle] (
    [IdSAPGRDetalle]     INT           NOT NULL,
    [IdSAPGR]            INT           NOT NULL,
    [POLineNumber]       VARCHAR (50)  NOT NULL,
    [Quantity]           FLOAT (53)    NOT NULL,
    [UnitPrice]          FLOAT (53)    NOT NULL,
    [Importe]            FLOAT (53)    NOT NULL,
    [CostObject]         VARCHAR (50)  NOT NULL,
    [MaterialGroup]      VARCHAR (50)  NOT NULL,
    [MaterialGroupDesc2] VARCHAR (50)  NOT NULL,
    [MaterialNumber]     VARCHAR (50)  NOT NULL,
    [MaterialDescShort]  VARCHAR (150) NOT NULL,
    [MatDocN]            VARCHAR (15)  NOT NULL,
    [MatDocItem]         VARCHAR (15)  NOT NULL,
    [CreadoEl]           DATETIME      NOT NULL,
    [CreadoPor]          INT           NOT NULL,
    [ModificadoEl]       DATETIME      NULL,
    [ModificadoPor]      INT           NULL,
    [DocumentDate]       VARCHAR (15)  NULL,
    CONSTRAINT [PK_CO_SAPGRDataDetalle] PRIMARY KEY CLUSTERED ([IdSAPGRDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPGRDataDetalle_CO_SAPGRData] FOREIGN KEY ([IdSAPGR]) REFERENCES [dbo].[CO_SAPGRData] ([IdSAPGR])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_SAPGRDataDetalle]
    ON [dbo].[CO_SAPGRDataDetalle]([IdSAPGR] ASC, [POLineNumber] ASC, [MatDocN] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

