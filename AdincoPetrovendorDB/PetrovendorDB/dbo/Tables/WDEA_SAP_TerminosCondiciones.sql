CREATE TABLE [dbo].[WDEA_SAP_TerminosCondiciones] (
    [IdCatTerminosCondiciones] INT          IDENTITY (1000, 1) NOT NULL,
    [Clabe]                    VARCHAR (30) NULL,
    [DiasCredito]              INT          NULL,
    CONSTRAINT [PK_WDEA_SAP_TerminosCondiciones] PRIMARY KEY CLUSTERED ([IdCatTerminosCondiciones] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

