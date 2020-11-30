-- =============================================
-- Author:		Daniel AC
-- Create date: 02-05-17
-- Description:	Consultar el numero de peticiones agregadas al pedido
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaNumPeticionesAgregasPedido]
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido int 
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT COUNT(POD.IDPETICIONOFERTA) 
    FROM MM_PETICIONOFERTADETALLE AS POD 
    INNER JOIN MM_PETICIONOFERTA AS PO ON PO.IDPETICIONOFERTA = POD.IDPETICIONOFERTA 
	WHERE PO.IDSOLICITUDPEDIDO = @IdSolicitudPedido AND ADDPEDIDOTEMP = 1


END

