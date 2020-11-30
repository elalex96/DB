CREATE TABLE [dbo].[AP_Lista] (
    [IdLista]       INT            IDENTITY (10000, 1) NOT NULL,
    [IdGrupo]       INT            NULL,
    [IdClave]       INT            NULL,
    [Nombre]        NVARCHAR (MAX) NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_Listas] PRIMARY KEY CLUSTERED ([IdLista] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_Listas_Grupos] FOREIGN KEY ([IdGrupo]) REFERENCES [dbo].[AP_Grupo] ([IdGrupo])
);

