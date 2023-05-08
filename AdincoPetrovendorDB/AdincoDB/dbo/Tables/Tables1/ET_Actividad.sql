CREATE TABLE [dbo].[ET_Actividad] (
    [IdActividad]    INT            IDENTITY (10000, 1) NOT NULL,
    [IdEscalaTiempo] INT            NULL,
    [Fecha]          DATE           NULL,
    [Hito]           NVARCHAR (MAX) NULL,
    [Cargo]          FLOAT (53)     NULL,
    [Parte]          NVARCHAR (255) NULL,
    [Dias]           INT            NULL,
    [CreadoPor]      INT            NULL,
    [CreadoEn]       DATETIME       NULL,
    [Activo]         BIT            NULL,
    [Eliminado]      BIT            NULL,
    [Pos]            BIT            NULL,
    CONSTRAINT [PK_ET_Actividad] PRIMARY KEY CLUSTERED ([IdActividad] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

