CREATE TABLE [dbo].[FI_TextoPDF] (
    [IdFactura]        INT           NOT NULL,
    [TextoPDF]         TEXT          NOT NULL,
    [NumeroDocumento]  VARCHAR (20)  NULL,
    [PuestoExpedicion] VARCHAR (100) NOT NULL,
    [IdConfig]         INT           NOT NULL,
    CONSTRAINT [PK_FI_TextoPDF] PRIMARY KEY CLUSTERED ([IdFactura] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

