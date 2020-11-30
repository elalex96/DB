CREATE TABLE [dbo].[CO_SAPProforma] (
    [IdSAPProforma]     INT           NOT NULL,
    [IdSAPPO]           INT           NOT NULL,
    [Reference]         VARCHAR (50)  NOT NULL,
    [IdEstatus]         INT           NOT NULL,
    [IdProveedorPetro]  INT           NOT NULL,
    [Total]             MONEY         NOT NULL,
    [ComentarioInterno] VARCHAR (350) NULL,
    [CreadoEl]          DATETIME      NOT NULL,
    [CreadoPor]         INT           NOT NULL,
    [ModificadoEl]      DATETIME      NULL,
    [ModificadoPor]     INT           NULL,
    [IdSAPGR]           INT           NULL,
    [IdSAPSES]          INT           NULL,
    CONSTRAINT [PK_CO_SAPProforma] PRIMARY KEY CLUSTERED ([IdSAPProforma] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPProforma_CO_SAPPOData] FOREIGN KEY ([IdSAPPO]) REFERENCES [dbo].[CO_SAPPOData] ([IdSAPData]),
    CONSTRAINT [FK_SAPProforma_SAPGRData] FOREIGN KEY ([IdSAPGR]) REFERENCES [dbo].[CO_SAPGRData] ([IdSAPGR]),
    CONSTRAINT [FK_SAPProforma_SAPSESData] FOREIGN KEY ([IdSAPSES]) REFERENCES [dbo].[CO_SAPSESData] ([IdSAPSES])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CO_SAPProforma]
    ON [dbo].[CO_SAPProforma]([IdSAPPO] ASC, [Reference] ASC, [IdEstatus] ASC) WITH (STATISTICS_NORECOMPUTE = ON);

