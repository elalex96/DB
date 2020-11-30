CREATE TABLE [dbo].[FI_ClavesPedimentoTemp] (
    [IdPedimento]      INT            IDENTITY (1, 1) NOT NULL,
    [Clave]            NVARCHAR (MAX) NULL,
    [Descripcion]      NVARCHAR (MAX) NULL,
    [IdClavePedimento] INT            NULL,
    CONSTRAINT [PK_FI_ClavesPedimento] PRIMARY KEY CLUSTERED ([IdPedimento] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

