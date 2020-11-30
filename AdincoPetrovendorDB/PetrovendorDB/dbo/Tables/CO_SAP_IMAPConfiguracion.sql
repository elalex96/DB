CREATE TABLE [dbo].[CO_SAP_IMAPConfiguracion] (
    [IdServidorIMAP] INT           NOT NULL,
    [ServidorIMAP]   VARCHAR (200) NOT NULL,
    [Email]          VARCHAR (100) NOT NULL,
    [Password]       VARCHAR (20)  NOT NULL,
    [Puerto]         SMALLINT      NOT NULL,
    [CreadoEl]       DATETIME      NOT NULL,
    CONSTRAINT [PK_CO_SAP_IMAPConfiguracion] PRIMARY KEY CLUSTERED ([IdServidorIMAP] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

