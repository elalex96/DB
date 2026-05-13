-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26/01/2018
-- Description:	para saber si muestro o no el boton de terminar cotizacion o su ultimo movimiento fue  terminarla
-- =============================================
CREATE PROCEDURE [dbo].SP_AD_RevisarHistoricoVigenciaTerminada
    @IdProveedor INT,
    @IdSolicitudPedido INT,
    @IdContrato INT,
    @IdUsuario INT,
    @FechaRegistro DATETIME
AS
BEGIN
    DECLARE @FechaFinalizacion DATETIME

    SELECT TOP 1
        @FechaFinalizacion = O.FechaFinalizacion
    FROM dbo.TA_Operacion AS O
        INNER JOIN dbo.MM_SolicitudPedido AS SP
            ON SP.IdSolicitudPedido = O.IdDocumento
    WHERE SP.IdSolicitudPedido = @IdSolicitudPedido
          AND O.IdTipoOperacion = 6
          AND O.IdProveedor = @IdProveedor
    ORDER BY O.IdOperacion DESC

    -- si la fecha de finalizacion es menor a la fecha actual entonces devuelve true
    IF (@FechaFinalizacion < GETDATE())
        SELECT 1
END