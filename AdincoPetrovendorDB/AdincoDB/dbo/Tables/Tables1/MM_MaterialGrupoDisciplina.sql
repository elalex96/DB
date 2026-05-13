CREATE TABLE [dbo].[MM_MaterialGrupoDisciplina] (
    [IdGrupoDisciplina] INT            IDENTITY (10000, 1) NOT NULL,
    [MaterialGrupo]     NVARCHAR (MAX) NULL,
    [Activo]            BIT            NULL,
    CONSTRAINT [PK_MM_MaterialGrupo] PRIMARY KEY CLUSTERED ([IdGrupoDisciplina] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

