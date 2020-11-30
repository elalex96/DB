-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/10/2019
-- Description:	Revisa si la carta de contenido es requerida o no, 
--				se utiliza en la pantalla de aceptacion pedido detalle, para llenar el check de carta de contenido
-- =============================================
CREATE PROCEDURE [dbo].[Sp_EsRequeridaCartaContenido] @IdAceptacionPedido INT
AS
BEGIN
    SELECT ISNULL(PedirCarta, 0)
    FROM dbo.RelacionCartaCNPedido
    WHERE IdAceptacionPedido = @IdAceptacionPedido
END

