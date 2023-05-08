-- =============================================
-- Author:		Pedro Acuña
-- Create date: 20/03/2018
-- Description:	retornar la fecha de vigencia por idoperacion				
-- =============================================
CREATE PROCEDURE sp_RetornarFechaVigenciaxOperacion @IdOperacion INT
AS
BEGIN
    SELECT HVP.FechaVigencia
    FROM dbo.TA_Operacion TAO
        INNER JOIN dbo.MM_Pedido P
            ON TAO.IdDocumento = P.IdSolicitudPedido
        INNER JOIN dbo.MM_HorasVigenciaPedido HVP
            ON HVP.IdPedido = P.IdPedido
    WHERE TAO.IdOperacion = @IdOperacion
END