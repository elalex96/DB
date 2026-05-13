CREATE TABLE [dbo].[PV_MM_MaterialGrupo] (
    [IdGrupo]       INT            IDENTITY (10000, 1) NOT NULL,
    [CodGrupo]      NVARCHAR (50)  NULL,
    [Grupo]         NVARCHAR (150) NULL,
    [IsActivo]      BIT            NULL,
    [IsEliminado]   BIT            NULL,
    [CreadoPor]     INT            NULL,
    [CreadoEn]      DATETIME       NULL,
    [ModificadoPor] INT            NULL,
    [ModificadoEn]  DATETIME       NULL,
    CONSTRAINT [PK_PV_MM_MaterialGrupo] PRIMARY KEY CLUSTERED ([IdGrupo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

