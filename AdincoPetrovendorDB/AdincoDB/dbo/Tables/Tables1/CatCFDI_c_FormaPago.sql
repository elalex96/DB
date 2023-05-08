CREATE TABLE [dbo].[CatCFDI_c_FormaPago] (
    [Idformapago]                          INT            IDENTITY (1, 1) NOT NULL,
    [c_FormaPago]                          NVARCHAR (255) NULL,
    [Descripcion]                          NVARCHAR (255) NULL,
    [Bancarizado]                          NVARCHAR (255) NULL,
    [Numeroperacion]                       NVARCHAR (255) NULL,
    [RFCEmisorcuentaordenante]             NVARCHAR (255) NULL,
    [Cuenta Ordenante]                     NVARCHAR (255) NULL,
    [Patroncuentaordenante]                NVARCHAR (255) NULL,
    [RFCEmisorCuentaBeneficiario]          NVARCHAR (255) NULL,
    [CuentaBenenficiario]                  NVARCHAR (255) NULL,
    [PatroncuentaBeneficiaria]             NVARCHAR (255) NULL,
    [TipoCadenaPago]                       NVARCHAR (255) NULL,
    [NombreBancoemisorcordenantextranjero] NVARCHAR (255) NULL,
    [Fechainiciovigencia]                  DATETIME       NULL,
    [Fechafinvigencia]                     NVARCHAR (255) NULL
);

