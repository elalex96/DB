CREATE TABLE [dbo].[VU_Beneficiario] (
    [Id]             INT           IDENTITY (1, 1) NOT NULL,
    [Nombre]         VARCHAR (250) NULL,
    [Cuenta]         VARCHAR (50)  NULL,
    [Clabe]          VARCHAR (50)  NULL,
    [Banco]          INT           NULL,
    [RFC]            VARCHAR (50)  NULL,
    [CuentaRegistro] INT           NULL,
    CONSTRAINT [PK_Beneficiario] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

