CREATE TABLE [dbo].[FI_Beneficiario] (
    [IdBeneficiario]     INT            IDENTITY (10000, 1) NOT NULL,
    [NombreBeneficiario] NVARCHAR (MAX) NULL,
    [NumeroCuenta]       NVARCHAR (MAX) NULL,
    [IdBanco]            INT            NULL,
    [Descripción]        NVARCHAR (MAX) NULL,
    [Activo]             BIT            NULL,
    CONSTRAINT [PK_FI_Beneficiarios] PRIMARY KEY CLUSTERED ([IdBeneficiario] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

