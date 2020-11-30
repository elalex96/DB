CREATE TABLE [dbo].[CO_SAPProformaBitacora] (
    [id]                INT           IDENTITY (1, 1) NOT NULL,
    [IdSAPProforma]     INT           NULL,
    [IdSAPPO]           INT           NULL,
    [Descripcion]       VARCHAR (250) NULL,
    [Reference]         VARCHAR (50)  NULL,
    [IdEstatus]         INT           NULL,
    [IdProveedorPetro]  INT           NULL,
    [Total]             MONEY         NULL,
    [ComentarioInterno] VARCHAR (350) NULL,
    [CreadoEl]          DATETIME      NULL,
    [CreadoPor]         INT           NULL,
    [ModificadoEl]      DATETIME      NULL,
    [ModificadoPor]     INT           NULL,
    [IdSAPGR]           INT           NULL,
    [IdSAPSES]          INT           NULL,
    PRIMARY KEY CLUSTERED ([id] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_SAPProformaBitacora_SAPGRData] FOREIGN KEY ([IdSAPGR]) REFERENCES [dbo].[CO_SAPGRData] ([IdSAPGR]),
    CONSTRAINT [FK_SAPProformaBitacora_SAPSESData] FOREIGN KEY ([IdSAPSES]) REFERENCES [dbo].[CO_SAPSESData] ([IdSAPSES])
);

