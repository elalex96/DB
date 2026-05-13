CREATE TABLE [dbo].[IN_AreaEmpresa] (
    [idAreaEmpresa] INT          IDENTITY (1, 1) NOT NULL,
    [NombreArea]    VARCHAR (50) NULL,
    [idContratista] INT          NULL,
    [CreadoPor]     INT          NULL,
    [CreadoEl]      DATETIME     NULL,
    [ModificadoPor] INT          NULL,
    [ModificadoEl]  DATETIME     NULL,
    [Activo]        BIT          NULL,
    CONSTRAINT [PK__IN_AreaE__47C266E56F369BDD] PRIMARY KEY CLUSTERED ([idAreaEmpresa] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [fk_AreaEmpresaContratista] FOREIGN KEY ([idContratista]) REFERENCES [dbo].[CO_Contratista] ([IdContratista])
);

