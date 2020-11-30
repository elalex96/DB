CREATE TABLE [dbo].[EN_HistorialHotificacionesEnviadas] (
    [idHistorialNotificacion] INT            IDENTITY (10000, 1) NOT NULL,
    [Para]                    NVARCHAR (MAX) NULL,
    [Asunto]                  NVARCHAR (MAX) NULL,
    [Mensaje]                 NVARCHAR (MAX) NULL,
    [De]                      NVARCHAR (MAX) NULL,
    [idInstanciaEntregable]   INT            NULL,
    [Periodo]                 DATE           NULL,
    [Estado]                  NVARCHAR (MAX) NULL,
    [FECHALIMITEACCION]       DATE           NULL,
    [tipoCorreo]              NVARCHAR (MAX) NULL,
    [IdEntregable]            INT            NULL,
    [CreadoPor]               INT            NULL,
    [CreadoEl]                DATETIME       NULL,
    CONSTRAINT [PK_EN_HistorialHotificacionesEnviadas] PRIMARY KEY CLUSTERED ([idHistorialNotificacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON)
);

