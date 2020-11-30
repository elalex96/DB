-- =============================================
-- Author:		Pedro Acuña
-- Create date: 26/03/2018
-- Description:	obtener los datos de la operacion filtrados por la solicitud de pedido y el tipo de operacion
-- =============================================
CREATE PROCEDURE SP_ConsultarTaOperacionXIdSolPed
    @IdTipoOperacion INT,
    @IdSolicitudPedido INT
AS
BEGIN
    SELECT IdOperacion,
           IdDocumento,
           IdFlujoTarea,
           IdEstatusOperacion,
           Descripcion,
           IdPrioridad,
           IdVigencia
    FROM dbo.TA_Operacion
    WHERE IdTipoOperacion = @IdTipoOperacion
          AND IdDocumento = @IdSolicitudPedido

END