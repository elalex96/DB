CREATE TABLE [dbo].[CO_Perfiles] (
    [IdPerfil]     INT            IDENTITY (1, 1) NOT NULL,
    [NombrePerfil] NVARCHAR (50)  NULL,
    [Descripcion]  NVARCHAR (MAX) NULL,
    [CreadoPor]    INT            NULL,
    CONSTRAINT [PK_Configuracion] PRIMARY KEY CLUSTERED ([IdPerfil] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

