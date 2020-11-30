CREATE TABLE [dbo].[TaTipoUsuario] (
    [IdTipoUsuario]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreTipoUsuario] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TaTipoUsuario] PRIMARY KEY CLUSTERED ([IdTipoUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

