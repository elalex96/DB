CREATE TABLE [dbo].[PV_TipoPersonaFiscal] (
    [TipoPersonaFiscalID] INT          IDENTITY (1, 1) NOT NULL,
    [TipoPersonaFiscal]   VARCHAR (50) NOT NULL,
    CONSTRAINT [PK_Cat_OrigenEmpresa] PRIMARY KEY CLUSTERED ([TipoPersonaFiscalID] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

