
CREATE PROCEDURE [dbo].[CO_EliminaPuntosdeEntrega]
	@PuntoEntregaID int,
	@idusuario int=0,
	@idContrato int=0
AS
BEGIN
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 07/03/18
-- Description:	Elimina un punto de entrega
-- =============================================
	SET NOCOUNT ON
-- =============================================

	UPDATE CO_PuntosdeEntrega 
		SET Activo		=	0,
		ModificadoPor	=	@idusuario,
		ModificadoEl	=	GETDATE()
	WHERE
		PuntoEntregaID = @PuntoEntregaID
END

