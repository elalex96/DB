CREATE TABLE [dbo].[AD_Documento] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [IdPedido]      INT            NULL,
    [Documento]     IMAGE          NULL,
    [Justificacion] NVARCHAR (MAX) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

