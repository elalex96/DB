CREATE TABLE [dbo].[CAT_TipoInstalacion] (
    [IdTipoInstalacion] INT          NOT NULL,
    [TipoInstalacion]   VARCHAR (50) NULL,
    CONSTRAINT [PK_CAT_TipoInstalacion] PRIMARY KEY CLUSTERED ([IdTipoInstalacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

