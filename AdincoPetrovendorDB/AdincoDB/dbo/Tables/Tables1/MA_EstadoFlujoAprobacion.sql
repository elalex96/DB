CREATE TABLE [dbo].[MA_EstadoFlujoAprobacion] (
    [IdEstado]            INT            IDENTITY (1, 1) NOT NULL,
    [NombreEstado]        NVARCHAR (200) NULL,
    [Descripcion]         NVARCHAR (MAX) NULL,
    [EstadosSubsecuentes] NVARCHAR (MAX) NULL,
    [CreadoPor]           INT            NULL,
    [CreadoEl]            DATETIME       NULL,
    [EditadoPor]          INT            NULL,
    [EditadoEl]           DATETIME       NULL,
    CONSTRAINT [PK_MA_EstadoFlujoAprobacion] PRIMARY KEY CLUSTERED ([IdEstado] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

