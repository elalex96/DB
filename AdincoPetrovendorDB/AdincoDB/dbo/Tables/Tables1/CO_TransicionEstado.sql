CREATE TABLE [dbo].[CO_TransicionEstado] (
    [IdTransicion]        INT            IDENTITY (1, 1) NOT NULL,
    [IdEstadoActual]      INT            NULL,
    [IdEstadoSiguiente]   INT            NULL,
    [NombreCambioEstado]  NVARCHAR (MAX) NULL,
    [ComentarioRequerido] BIT            NULL,
    [CreadoPor]           INT            NULL,
    CreadoEn DATETIME,
    ModificadoPor INT NULL,
    ModificadoEn DATETIME NULL,
    CONSTRAINT FK_AP_Usuario_CO_TransicionEstado_CreadoPor FOREIGN KEY (CreadoPor) REFERENCES AP_Usuario,
    CONSTRAINT FK_AP_Usuario_CO_TransicionEstado_ModificadoPor FOREIGN KEY (ModificadoPor) REFERENCES AP_Usuario,
    CONSTRAINT [PK_Transicion] PRIMARY KEY CLUSTERED ([IdTransicion] ASC) WITH (FILLFACTOR = 80, STATISTICS_NORECOMPUTE = ON)
);

