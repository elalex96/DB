CREATE TABLE [dbo].[PV_Beneficiario] (
    [IdBeneficiario]     INT            IDENTITY (10000, 1) NOT NULL,
    [NombreBeneficiario] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_PV_Beneficiario] PRIMARY KEY CLUSTERED ([IdBeneficiario] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

