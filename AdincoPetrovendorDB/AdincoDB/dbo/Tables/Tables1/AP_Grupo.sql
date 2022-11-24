CREATE TABLE [dbo].[AP_Grupo] (
    [IdGrupo]       INT            IDENTITY (10000, 1) NOT NULL,
    [ClaveGrupo]    NVARCHAR (MAX) NULL,
    [NombreGrupo]   NVARCHAR (MAX) NULL,
    [GroupName]     NVARCHAR (MAX) NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEl]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEl]  DATETIME       NULL,
    [Activo]        BIT            NULL,
    CONSTRAINT [PK_Grupos] PRIMARY KEY CLUSTERED ([IdGrupo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

