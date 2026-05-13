-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_OCM_ConsultaAceptacionPedido] 
	-- Add the parameters for the stored procedure here
	@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT AP.NombreRecibidoPor NOMBRE, 
	--		AP.Creado AS FECHA, 
	--		(SELECT '') AS IDFIRMAELECTRONICA
	--FROM dbo.MM_AceptacionPedido AS AP
	--LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
	--LEFT JOIN dbo.TA_Operacion AS OP ON OP.IdDocumento = P.IdSolicitudPedido AND OP.IdTipoOperacion = 6
	--LEFT JOIN dbo.TA_Tarea AS TT ON TT.IdOperacion = OP.IdOperacion
	--WHERE P.IdPedido = @IdPedido
	SELECT u.Nombre,
			p.FechaRecepcionServicio,
			p.IdFirma
		FROM dbo.MM_Pedido p
		INNER JOIN dbo.S_Usuario u ON u.IdUsuario = p.IdUsuarioRecepcionServicio 
		WHERE IdPedido = @IdPedido
END

