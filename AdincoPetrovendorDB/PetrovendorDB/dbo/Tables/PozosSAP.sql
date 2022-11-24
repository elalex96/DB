CREATE TABLE [dbo].[PozosSAP] (
    [Id]                  INT          NOT NULL,
    [IdContrato]          INT          NULL,
    [IdPozoSAP]           VARCHAR (10) NULL,
    [IdInstalacionAdinco] INT          NULL,
    CONSTRAINT [PK_PozosSAP] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

