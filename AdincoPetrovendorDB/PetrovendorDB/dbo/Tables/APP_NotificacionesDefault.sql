CREATE TABLE APP_NotificacionesDefault
(
Id INT PRIMARY KEY IDENTITY(1,1),
ContratoId INT,
Titulo NVARCHAR(200),
Mensaje NVARCHAR(MAX),
CreadoEl DATETIME,
ModificadoEl DATETIME,
FechaInicio  DATETIME,
FechaFinalizacion  DATETIME,
Activo BIT)
GO
CREATE NONCLUSTERED INDEX idx_APP_NotificacionesDefault_ContratoId
    ON [dbo].[APP_NotificacionesDefault](ContratoId ASC)
    INCLUDE(ContratoId) WITH (STATISTICS_NORECOMPUTE = ON);