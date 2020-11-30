CREATE TABLE [dbo].[PV_ClasificacionPyMES] (
    [IdClasificacion] INT            IDENTITY (1, 1) NOT NULL,
    [Nombre]          NVARCHAR (MAX) NOT NULL,
    CONSTRAINT [PK_PV_ClasificacionPyMES] PRIMARY KEY CLUSTERED ([IdClasificacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

