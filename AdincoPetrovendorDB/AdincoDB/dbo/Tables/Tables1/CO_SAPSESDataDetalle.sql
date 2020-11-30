CREATE TABLE [dbo].[CO_SAPSESDataDetalle] (
    [IdSAPSESDetalle]    INT           NOT NULL,
    [IdSAPSES]           INT           NOT NULL,
    [SESLine]            VARCHAR (50)  NOT NULL,
    [Quantity]           FLOAT (53)    NOT NULL,
    [UnitPrice]          FLOAT (53)    NOT NULL,
    [Importe]            FLOAT (53)    NOT NULL,
    [AccountAssignment]  VARCHAR (50)  NOT NULL,
    [MaterialGroup]      VARCHAR (250) NULL,
    [MaterialGroupDesc2] VARCHAR (250) NULL,
    [CostObject]         VARCHAR (50)  NOT NULL,
    [CreadoEl]           DATETIME      NOT NULL,
    [CreadoPor]          INT           NOT NULL,
    [ModificadoEl]       DATETIME      NULL,
    [ModificadoPor]      INT           NULL,
    CONSTRAINT [PK_CO_SAPSESDetalle] PRIMARY KEY CLUSTERED ([IdSAPSESDetalle] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPSESDataDetalle_CO_SAPSESData] FOREIGN KEY ([IdSAPSES]) REFERENCES [dbo].[CO_SAPSESData] ([IdSAPSES])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_SAPSESDataDetalle]
    ON [dbo].[CO_SAPSESDataDetalle]([SESLine] ASC, [IdSAPSES] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

