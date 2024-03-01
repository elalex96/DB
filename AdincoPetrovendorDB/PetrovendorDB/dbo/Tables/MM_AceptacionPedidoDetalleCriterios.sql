CREATE TABLE MM_AceptacionPedidoDetalleCriterios(
Id INT IDENTITY(1,1) NOT NULL,  
AceptacionPedidoDetalleId INT NOT NULL, 
ClienteProyectoId INT NOT NULL, 
ActividadClasificacionGastoId INT NOT NULL, 
ActividadClasificacionGasto2Id INT NULL, 
CreadoEl DATETIME NOT NULL,  
ModificadoEl DATETIME  NULL,
CONSTRAINT [PK_MM_AceptacionPedidoDetalleCriterios] PRIMARY KEY CLUSTERED ([Id] ASC),
CONSTRAINT [FK_MM_AceptacionPedidoDetalleCriterios_MM_ClienteProyecto] FOREIGN KEY ([ClienteProyectoId]) REFERENCES [dbo].[MM_ClienteProyecto] ([Id]),
CONSTRAINT [FK_MM_AceptacionPedidoDetalleCriterios_MM_ActividadClasificacionGasto] FOREIGN KEY ([ActividadClasificacionGastoId]) REFERENCES [dbo].[MM_ActividadClasificacionGasto] ([Id]),
CONSTRAINT [FK_MM_AceptacionPedidoDetalleCriterios_MM_ActividadClasificacionGasto2] FOREIGN KEY ([ActividadClasificacionGasto2Id]) REFERENCES [dbo].[MM_ActividadClasificacionGasto2] ([Id]),
CONSTRAINT [FK_MM_AceptacionPedidoDetalleCriterios_MM_AceptacionPedidoDetalle] FOREIGN KEY ([AceptacionPedidoDetalleId]) REFERENCES [dbo].[MM_AceptacionPedidoDetalle] ([IdAceptacionPedidoDetalle])
)