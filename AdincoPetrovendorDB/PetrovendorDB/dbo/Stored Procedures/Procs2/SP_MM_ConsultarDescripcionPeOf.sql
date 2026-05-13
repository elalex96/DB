-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <22/Mayo/18>
-- Description:	<Consulta la descripcion de la peticion de oferta para enviarla adjunta al correo>
-- =============================================
CREATE PROCEDURE SP_MM_ConsultarDescripcionPeOf
@IdSolicitudPedido INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT Descripcion FROM dbo.TA_Operacion WHERE IdDocumento = @IdSolicitudPedido AND IdTipoOperacion = 6
END
