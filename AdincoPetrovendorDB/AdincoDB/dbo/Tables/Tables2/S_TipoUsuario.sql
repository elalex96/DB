CREATE TABLE [dbo].[S_TipoUsuario] (
    [IdTipoUsuario]     INT            IDENTITY (1, 1) NOT NULL,
    [NombreTipoUsuario] NVARCHAR (50)  NULL,
    [Descripcion]       NVARCHAR (250) NULL,
    [Activo]            BIT            NULL,
    CONSTRAINT [PK_S_TipoUsuario] PRIMARY KEY CLUSTERED ([IdTipoUsuario] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

