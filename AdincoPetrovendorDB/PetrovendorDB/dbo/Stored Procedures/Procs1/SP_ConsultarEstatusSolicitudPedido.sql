-- =============================================
-- Author:		DANIEL AC
-- Create date: 16/01/2018 10:14 AM
-- Description:	CONSULTAR ESTATUS DE SOLPED
-- =============================================
-- Author:		Luis David De La Cruz
-- Create date: 20/03/2021
-- Description:	Se optimiza la consulta para la pantalla detalle_pedido del issue 984
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarEstatusSolicitudPedido]
@IdSolicitudPedido INT,
@IdProveedor INT 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
		
	SELECT E.IdEstatus,E.Nombre 
	FROM TA_Operacion O
	INNER JOIN TA_Estatus AS E 
	ON O.IdEstatusOperacion = E.IdEstatus
	WHERE 
	O.IdTipoOperacion = 2 AND O.IdProveedor = @IdProveedor AND O.IdDocumento = @IdSolicitudPedido 
	--Doned O.IdTipoOperacion = 2 --> solped
END