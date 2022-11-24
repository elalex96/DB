CREATE TABLE [dbo].[CO_SAPInformesEmail] (
    [IdInformesEmail] INT           NOT NULL,
    [IdContratista]   INT           NULL,
    [Email]           VARCHAR (100) NULL,
    CONSTRAINT [PK_CO_SAPInformesEmail] PRIMARY KEY CLUSTERED ([IdInformesEmail] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPInformesEmail_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

