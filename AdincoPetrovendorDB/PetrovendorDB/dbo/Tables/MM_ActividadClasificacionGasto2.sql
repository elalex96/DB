CREATE TABLE MM_ActividadClasificacionGasto2(
Id INT IDENTITY(1,1)  NOT NULL,  
ActividadClasificacionGastoId INT  NOT NULL, 
Nombre VARCHAR(MAX) NOT NULL, 
Activo BIT NOT NULL, 
CreadoPor INT NULL,
CreadoEl DATETIME NOT NULL, 
ModificadoPor INT NULL,
ModificadoEl DATETIME NULL,
CONSTRAINT [PK_MM_ActividadClasificacionGasto2] PRIMARY KEY CLUSTERED ([Id] ASC),
CONSTRAINT [FK_MM_ActividadClasificacionGasto2_MM_ActividadClasificacionGasto] FOREIGN KEY ([ActividadClasificacionGastoId]) REFERENCES [dbo].[MM_ActividadClasificacionGasto] ([Id])
)