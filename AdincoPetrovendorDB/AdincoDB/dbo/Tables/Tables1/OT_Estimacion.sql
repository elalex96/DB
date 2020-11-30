CREATE TABLE [dbo].[OT_Estimacion] (
    [IdOTEstimacion]    INT          NOT NULL,
    [IdOTSolicitud]     INT          NOT NULL,
    [FolioEstimacion]   VARCHAR (50) NOT NULL,
    [Consecutivo]       SMALLINT     NOT NULL,
    [FechaCorteInicio]  DATETIME     NOT NULL,
    [FechaCorteFin]     DATETIME     NOT NULL,
    [CreadoEl]          DATETIME     NOT NULL,
    [CreadoPor]         INT          NOT NULL,
    [Total]             MONEY        NULL,
    [IdSolicitudPedido] INT          NULL,
    [IdPedido]          INT          NULL,
    [IdPedidoGeneral]   INT          NULL,
    [Cancelada]         BIT          NULL,
    [FechaCancelacion]  DATE         NULL,
    CONSTRAINT [PK_OT_Estimacion] PRIMARY KEY CLUSTERED ([IdOTEstimacion] ASC) WITH (STATISTICS_NORECOMPUTE = ON),
    CONSTRAINT [FK_OT_Estimacion_AP_Usuario] FOREIGN KEY ([CreadoPor]) REFERENCES [dbo].[AP_Usuario] ([UsuarioID]),
    CONSTRAINT [FK_OT_Estimacion_OT_Solicitud] FOREIGN KEY ([IdOTSolicitud]) REFERENCES [dbo].[OT_Solicitud] ([IdOTSolicitud])
);

