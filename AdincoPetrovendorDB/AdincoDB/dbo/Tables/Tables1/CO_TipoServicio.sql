CREATE TABLE [dbo].[CO_TipoServicio] (
    [IdTipoServicio]     INT            IDENTITY (1, 1) NOT NULL,
    [ID_TIPOSER]         INT            NULL,
    [NombreTipoServicio] NVARCHAR (MAX) NULL,
    [Orden]              INT            NULL,
    [IdUsuario]          INT            NULL,
    [FecMovto]           DATETIME       NULL,
    [Activo]             BIT            NULL,
    [CreadoPor]          INT            NULL,
    CONSTRAINT [PK_TipoServicio] PRIMARY KEY CLUSTERED ([IdTipoServicio] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

