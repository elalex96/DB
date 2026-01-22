IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE name = 'USP_SEL_CO_BitacoraEstadosGasto'
          AND type = 'P'
)
    DROP PROCEDURE USP_SEL_CO_BitacoraEstadosGasto;
GO

CREATE PROCEDURE USP_SEL_CO_BitacoraEstadosGasto
(
    @FechaInicio DATE,
    @FechaFin DATE,
    @IdContrato INT,
    @IdUsuario INT
)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT B.Id,
           B.IdRegistro,
           ERA.NombreEstado AS EstadoAnterior,
           ERN.NombreEstado AS EstadoActual,
           -- dd/MM/yyyy
           CONVERT(VARCHAR(10), B.MesEstadoPemexAnterior, 103) AS MesEstadoPemexAnterior,
           CONVERT(VARCHAR(10), B.MesEstadoPemexActual, 103) AS MesEstadoPemexActual,
           -- dd/MM/yyyy HH:mm
           CONVERT(VARCHAR(16), B.CreadoEn, 103) + ' ' + CONVERT(VARCHAR(5), B.CreadoEn, 108) AS CreadoEn,
           U.Nombre AS CreadoPor
    FROM CO_RegistroMarkupBitacora B WITH (NOLOCK)
        JOIN CO_RegistroMarkup RM WITH (NOLOCK)
            ON B.IdRegistro = RM.GastoId
               AND RM.ContratoId = @IdContrato
        JOIN CO_EstadoRegistro_V2 ERA WITH (NOLOCK)
            ON B.IdEstadoAnterior = ERA.IdClvEstado
               AND ERA.IdContrato = @IdContrato
        JOIN CO_EstadoRegistro_V2 ERN WITH (NOLOCK)
            ON B.IdEstadoActual = ERN.IdClvEstado
               AND ERN.IdContrato = @IdContrato
        JOIN AP_Usuario U WITH (NOLOCK)
            ON B.CreadoPor = U.UsuarioID
    WHERE CAST(B.CreadoEn AS DATE)
    BETWEEN @FechaInicio AND @FechaFin
    ORDER BY B.CreadoEn DESC;

END
GO
