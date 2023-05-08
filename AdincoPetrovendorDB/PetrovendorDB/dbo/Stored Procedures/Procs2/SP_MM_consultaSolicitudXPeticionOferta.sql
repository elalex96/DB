-- =============================================
-- Author:		JG
-- Create date: 06/09/17
-- Description:	Obtiene el iddesolicitud de pedido por medio del id de solicitud de peticion
--de oferta
-- Author Update: DAC
-- Create date: 07/09/17
-- Description: Se cambio USE Petrovendor redireccionaba a las Master
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_consultaSolicitudXPeticionOferta]
-- 1274
	@IdPeticionOferta int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    Select ISNULL(IdSolicitudPedido, 0) from MM_PeticionOferta where IdPeticionOferta = @IdPeticionOferta
END

