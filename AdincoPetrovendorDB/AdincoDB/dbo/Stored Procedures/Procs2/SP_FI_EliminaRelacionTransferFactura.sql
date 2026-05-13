-- =============================================
-- Author:		Josue Glez
-- ALTER date: 03-05-2017
-- Description:	Elimina una relacion factura- transferencia
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminaRelacionTransferFactura]
	@idTransferFactura int
AS
BEGIN
	SET NOCOUNT ON;

    delete 
	from 
	Fi_transferfactura 
	where IdTRansferFactura = @idTransferFactura
	
END
