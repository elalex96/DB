CREATE TABLE [dbo].[CO_SAPTaxMinistry] (
    [IdSAPTaxMinistry] TINYINT       NOT NULL,
    [Descripcion]      VARCHAR (100) NOT NULL,
    [CreadoEl]         DATETIME      NOT NULL,
    CONSTRAINT [PK_CO_SAPPaymentForm] PRIMARY KEY CLUSTERED ([IdSAPTaxMinistry] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

