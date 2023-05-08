CREATE TABLE [dbo].[MM_Solicitud_ExclucionCN] (
    [IdAprobacionExclucionCN] INT      IDENTITY (1000, 1) NOT NULL,
    [IdAceptacionPedido]      INT      NULL,
    [IdEstatus]               INT      NULL,
    [IdUsuarioRequesitor]     INT      NULL,
    [FechaSolicitud]          DATETIME NULL,
    [FechaEvaluacion]         DATETIME NULL,
    [UsuarioAprobador]        INT      NULL,
    CONSTRAINT [PK_MM_Solicitud_ExclucionCN] PRIMARY KEY CLUSTERED ([IdAprobacionExclucionCN] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

