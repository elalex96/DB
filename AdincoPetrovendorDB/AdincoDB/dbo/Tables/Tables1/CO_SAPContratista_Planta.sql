CREATE TABLE [dbo].[CO_SAPContratista_Planta] (
    [IdContratista] INT          NOT NULL,
    [Planta]        VARCHAR (15) NOT NULL,
    [CompanyCode]   VARCHAR (5)  NOT NULL,
    CONSTRAINT [PK_CO_SAP_Contratista_Planta] PRIMARY KEY CLUSTERED ([IdContratista] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAPContratista_Planta_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

