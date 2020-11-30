CREATE TABLE [dbo].[VU_Cuentas] (
    [Id]         INT           IDENTITY (1, 1) NOT NULL,
    [Cuenta]     VARCHAR (50)  NULL,
    [Banco]      INT           NULL,
    [Sociedad]   INT           NULL,
    [Moneda]     VARCHAR (20)  NULL,
    [Clabe]      VARCHAR (50)  NULL,
    [TextoLibre] VARCHAR (100) NULL,
    CONSTRAINT [PK_Cuentas] PRIMARY KEY CLUSTERED ([Id] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

