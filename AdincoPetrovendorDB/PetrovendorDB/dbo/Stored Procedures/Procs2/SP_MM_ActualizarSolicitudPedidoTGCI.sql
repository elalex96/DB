-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarSolicitudPedidoTGCI]
@IdTipoGasto INT,
@IdTipoCI    INT,
@Finanzas    BIT,
@IdSolPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE MM_SolicitudPedido
	SET
	IdTipoGasto = @IdTipoGasto,
	IdTerminoInternacionales = @IdTipoCI,
	Fianza = @Finanzas
	WHERE IdSolicitudPedido = @IdSolPedido

END

