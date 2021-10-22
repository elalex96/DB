CREATE TABLE [dbo].[CO_SAP_IMAPConfiguracion] (
    [IdContratista] INT           NOT NULL,
    [ServidorIMAP]  VARCHAR (200) NOT NULL,
    [Email]         VARCHAR (100) NOT NULL,
    [Password]      VARCHAR (20)  NOT NULL,
    [Puerto]        SMALLINT      NOT NULL,
    [CreadoEl]      DATETIME      NOT NULL,
    [FechaUltimoEnvio] DATETIME NULL, 
    CONSTRAINT [PK_CO_SAP_IMAPConfiguracion] PRIMARY KEY CLUSTERED ([IdContratista] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_CO_SAP_IMAPConfiguracion_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

