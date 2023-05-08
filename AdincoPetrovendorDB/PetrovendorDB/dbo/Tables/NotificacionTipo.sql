CREATE TABLE [dbo].[NotificacionTipo] (
    [IdTipoNoticacion] INT             IDENTITY (1, 1) NOT NULL,
    [Nombre]           VARCHAR (500)   NULL,
    [Descripcion]      NVARCHAR (2000) NULL,
    [Activo]           BIT             NULL,
    CONSTRAINT [PK_NotificacionTipo] PRIMARY KEY CLUSTERED ([IdTipoNoticacion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

