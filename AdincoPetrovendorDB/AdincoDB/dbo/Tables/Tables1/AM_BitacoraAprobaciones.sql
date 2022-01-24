CREATE TABLE AM_BitacoraAprobaciones
(
Id INT IDENTITY(1,1)  PRIMARY KEY,
IdTarea INT NULL,
IdContrato INT NULL,
IdEstatus INT NULL,
Comentario VARCHAR(MAX) NULL,
AprobadorPetrovendor INT NULL,
AprobadorAdinco INT NULL,
FechaAprobacion DATETIME NULL
)