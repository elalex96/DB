CREATE TABLE [dbo].[WDEA_SAP_CentroCostos] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [IdCentroCostosADINCO] INT           NULL,
    [AcronimoSAP]          VARCHAR (300) NULL,
    [WBS_Element]          VARCHAR (300) NULL,
    [IdContrato]           INT           NULL,
    [IdProveedor]          INT           NULL,
    [Activo]               BIT           NULL,
    [CreadoEl]             DATETIME      NULL,
    [ModificadoEl]         DATETIME      NULL,
    [CreadoPor]            INT           NULL,
    [ModificadoPor]        INT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

