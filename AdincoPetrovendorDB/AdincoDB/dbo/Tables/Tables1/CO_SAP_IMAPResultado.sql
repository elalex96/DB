CREATE TABLE [dbo].[CO_SAP_IMAPResultado] (
    [IdContratista]  INT           NOT NULL,
    [uIdMail]        VARCHAR (500) NOT NULL,
    [Success]        BIT           NOT NULL,
    [CreadoEl]       DATETIME      NOT NULL,
    [Procesado]      BIT           NULL,
    [FechaProcesado] DATETIME      NULL,
    CONSTRAINT [PK_CO_SAP_IMAP_Resultado] PRIMARY KEY CLUSTERED ([IdContratista] ASC, [uIdMail] ASC),
    CONSTRAINT [FK_CO_SAP_IMAP_Resultado_CO_Contratista] FOREIGN KEY ([IdContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

