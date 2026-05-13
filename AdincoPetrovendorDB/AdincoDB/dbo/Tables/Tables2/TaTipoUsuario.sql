CREATE TABLE [dbo].[TaTipoUsuario] (
    [IdTipoUsuario]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreTipoUsuario] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_TaTipoUsuario] PRIMARY KEY CLUSTERED ([IdTipoUsuario] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

