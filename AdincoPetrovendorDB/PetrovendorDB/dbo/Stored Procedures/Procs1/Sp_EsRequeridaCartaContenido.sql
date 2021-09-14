DROP PROCEDURE IF EXISTS Sp_EsRequeridaCartaContenido
go
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 18/10/2019
-- Description:	Revisa si la carta de contenido es requerida o no, 
--				se utiliza en la pantalla de aceptacion pedido detalle, para llenar el check de carta de contenido
-- =============================================
-- Author:		DAVID DE LA CRUZ
-- Create date: 13/09/2021
-- Description:	SE VALIDA QUE CUANDO SEA PROVEEDOR EXTRANGERO SE MUESTRE EL SWITCH COMO NO
-- =============================================
CREATE PROCEDURE [dbo].[Sp_EsRequeridaCartaContenido] @IdAceptacionPedido INT
AS
BEGIN
    SELECT 
	CASE WHEN P.IdNacionalidad = 2
	THEN 0
	ELSE
	ISNULL(PedirCarta, 0) 
	END AS CARTACN
    FROM dbo.RelacionCartaCNPedido as RCN
	JOIN  MM_Pedido AS PD 
	ON RCN.IdPedido = PD.IdPedido
	JOIN S_Proveedor AS P ON
	PD.IdSubcontratista = P.IdProveedor
    WHERE IdAceptacionPedido = @IdAceptacionPedido
END
