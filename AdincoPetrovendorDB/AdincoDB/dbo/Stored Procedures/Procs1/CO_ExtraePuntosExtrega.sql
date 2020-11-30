-- =============================================
-- Author:		Reyna O.
-- Create date: 13/02/18
-- Description:	ExtraePuntos de entrega para nominación
-- =============================================
CREATE PROCEDURE [dbo].[CO_ExtraePuntosExtrega]
	-- Add the parameters for the stored procedure here
@idContrato int =0,
@idUser int=0

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	Select PEC.PuntoentregaID,Nombre as nombreMostrar
	from CO_PuntosdeEntrega PE
	JOIN CO_PuntosdeEntregaContrato PEC on PE.PuntoEntregaID = PEC.PuntoEntregaID
	where idContrato= @idContrato and Pe.Activo=1 and PEC.Activo=1



END
