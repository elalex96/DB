-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/10/2019
-- Description:	Revisa el estatus de la Factura, esto con el fin de saber si se habilita o deshbailita
--				el check de Carta contenido nacional que se encuentra en la aceptacion de pedido detalle
-- =============================================
CREATE PROCEDURE [dbo].[Sp_RevisarEstatusFacturaDocumento] @IdAceptacionPedido INT
AS
BEGIN

    SELECT CASE
               WHEN IdEstatusXML IN ( 1, 2, 3 )
                    OR IdEstatusPDF IN ( 1, 2, 3 ) THEN
                   1 -- bloquear el btn de Carta Contenido
               ELSE
                   0 -- desbloquear el btn de Carta Contenido
           END
    FROM dbo.MM_AceptacionFactura
    WHERE IdAceptacionPedido = @IdAceptacionPedido


END

