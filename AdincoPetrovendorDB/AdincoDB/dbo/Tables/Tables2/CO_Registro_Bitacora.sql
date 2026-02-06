IF OBJECT_ID('dbo.CO_Registro_Bitacora', 'U') IS NOT NULL
BEGIN
    DROP TABLE dbo.CO_Registro_Bitacora;
END
GO

CREATE TABLE dbo.CO_Registro_Bitacora
(
    IdBitacora                  INT IDENTITY(1,1) NOT NULL,
    IdRegistro                  INT NOT NULL,
    CreadoPor                   INT NOT NULL,
    Justificacion               NVARCHAR(500) NULL,

    IdLineaPresupuestoAnterior  INT NULL,
    IdLineaPresupuestoNuevo     INT NULL,

    CreadoEn             DATETIME NOT NULL
        CONSTRAINT DF_CO_Registro_Bitacora_FechaMovimiento DEFAULT (GETDATE()),

    CONSTRAINT PK_CO_Registro_Bitacora
        PRIMARY KEY CLUSTERED (IdBitacora)
);
GO

/*=========================================================
ÍNDICES 
=========================================================*/
IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CO_Registro_Bitacora_IdRegistro' AND object_id = OBJECT_ID('dbo.CO_Registro_Bitacora'))
    DROP INDEX IX_CO_Registro_Bitacora_IdRegistro ON dbo.CO_Registro_Bitacora;
GO
CREATE NONCLUSTERED INDEX IX_CO_Registro_Bitacora_IdRegistro
ON dbo.CO_Registro_Bitacora (IdRegistro);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CO_Registro_Bitacora_Fecha' AND object_id = OBJECT_ID('dbo.CO_Registro_Bitacora'))
    DROP INDEX IX_CO_Registro_Bitacora_Fecha ON dbo.CO_Registro_Bitacora;
GO
CREATE NONCLUSTERED INDEX IX_CO_Registro_Bitacora_Fecha
ON dbo.CO_Registro_Bitacora (CreadoEn DESC);
GO

IF EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_CO_Registro_Bitacora_Usuario' AND object_id = OBJECT_ID('dbo.CO_Registro_Bitacora'))
    DROP INDEX IX_CO_Registro_Bitacora_Usuario ON dbo.CO_Registro_Bitacora;
GO
CREATE NONCLUSTERED INDEX IX_CO_Registro_Bitacora_Usuario
ON dbo.CO_Registro_Bitacora (CreadoPor);
GO
