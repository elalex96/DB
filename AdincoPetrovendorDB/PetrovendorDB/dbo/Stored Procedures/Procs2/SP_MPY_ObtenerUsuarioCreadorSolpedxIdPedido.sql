-- =============================================
-- Author:		Pedro Acuña
-- Create date: 16/04/2018
-- Description:	obtener el id del usuario creador de la solped
-- =============================================

CREATE procedure [dbo].[SP_MPY_ObtenerUsuarioCreadorSolpedxIdPedido] ( @IdPedido INT )
AS
	BEGIN
		SELECT CreadorPor
		FROM dbo.MPY_MM_AceptacionPedido
		WHERE IdPedido = @IdPedido
	END
