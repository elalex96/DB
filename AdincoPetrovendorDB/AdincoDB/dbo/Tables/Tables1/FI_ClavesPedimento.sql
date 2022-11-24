CREATE TABLE [dbo].[FI_ClavesPedimento] (
    [IdPedimento]      INT            IDENTITY (1, 1) NOT NULL,
    [Clave]            NVARCHAR (MAX) NULL,
    [Descripcion]      NVARCHAR (MAX) NULL,
    [IdClavePedimento] INT            NULL,
    CONSTRAINT [PK_FI_ClavesPedimento_1] PRIMARY KEY CLUSTERED ([IdPedimento] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

