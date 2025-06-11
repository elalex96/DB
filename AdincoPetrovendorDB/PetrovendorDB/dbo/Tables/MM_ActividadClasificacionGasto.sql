CREATE TABLE MM_ActividadClasificacionGasto(
Id INT IDENTITY(1,1) NOT NULL, 
Nombre VARCHAR(MAX) NOT NULL,
Activo BIT NOT NULL,
CreadoPor INT NULL,
CreadoEl DATETIME NOT NULL, 
ModificadoPor INT NULL,
ModificadoEl DATETIME  NULL,
CONSTRAINT [PK_MM_ActividadClasificacionGasto] PRIMARY KEY CLUSTERED ([Id] ASC)
)