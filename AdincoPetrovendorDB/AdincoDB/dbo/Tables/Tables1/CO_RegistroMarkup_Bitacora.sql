CREATE TABLE dbo.CO_RegistroMarkup_Bitacora
(
    BitacoraId        INT IDENTITY(1,1) NOT NULL,
	IdContrato        INT NOT NULL,
    GastoId           INT NOT NULL,
    IdEstadoOrigen    INT NOT NULL,
    IdEstadoDestino   INT NOT NULL,
    Justificacion     NVARCHAR(500) NOT NULL,
    UsuarioId         INT NOT NULL,
    FechaMovimiento   DATETIME NOT NULL DEFAULT(GETDATE()),

    CONSTRAINT PK_CO_RegistroMarkup_Bitacora 
        PRIMARY KEY CLUSTERED (BitacoraId)
);