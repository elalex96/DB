-- =============================================
-- Author:                       <Pedro Acuña>
-- Create date: <18-10-2018>
-- Description:              <store para validar que solo se esta creando una solicitud de oferta por requisicion>
-- =============================================

CREATE PROCEDURE Sp_ValidarExisteSolOferta @IdSolicitudPedido INT
AS
     BEGIN
         IF NOT EXISTS
         (
             SELECT 1
             FROM dbo.TA_Operacion TAO
             WHERE TAO.IdDocumento = @IdSolicitudPedido
                   AND TAO.IdTipoOperacion = 6
                   AND ISNULL(TAO.IdEstatusEliminado, 0) = 0
         )
             BEGIN
                 SELECT 1;
             END;
             ELSE
         SELECT 0; --No permitir el guardado
     END;
