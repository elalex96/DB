CREATE TABLE [dbo].[ET_EscalaTiempo] (
    [IdEscalaTiempo]     INT            IDENTITY (10000, 1) NOT NULL,
    [NombreEscalaTiempo] NVARCHAR (MAX) NULL,
    [CreadoPor]          INT            NULL,
    [CreadoEn]           DATETIME       NULL,
    [Activo]             BIT            NULL,
    [Eliminado]          BIT            NULL,
    CONSTRAINT [PK_ET_EscalaTiempoProyecto] PRIMARY KEY CLUSTERED ([IdEscalaTiempo] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

