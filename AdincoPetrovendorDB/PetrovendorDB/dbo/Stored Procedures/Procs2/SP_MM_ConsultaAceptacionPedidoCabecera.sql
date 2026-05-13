-- =============================================
-- Author:		Daniel AC
-- Create date: 24-06-17
-- Description:	CONSULTA Recepcion Pedido
-- =============================================
-- Author:		Daniel AC
-- Create date: 01-06-18
-- Description: Condicion de solo pedidos que no esten eliminados = 1
-- =============================================
-- Author:		Jose Roman
-- Create date: 12-07-2018
-- Description: Condicion para pedido cerrado
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/06/2020
-- Description: se agrego el campo de justificacion para los procesos de procura y OT
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultaAceptacionPedidoCabecera]
	-- Add the parameters for the stored procedure here
	@IdPedido int,
	@IdProveedorComprador int
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @NombreProveedorVendor nvarchar(300)
	
	SET @NombreProveedorVendor = (SELECT ISNULL(RazonSocial,'') + ' '+ISNULL(RegimenCapital,'')
							FROM S_Proveedor AS P
							INNER JOIN MM_PEDIDO AS MP ON MP.IdSubcontratista = P.IdProveedor
							WHERE MP.IdPedido =@IdPedido)


	SELECT P.IdPedido,
			@NombreProveedorVendor AS ProveedorVendedor, 
			ISNULL(AceptacionPedidoGral,'false') AS AceptacionPedidoGral, 
			ISNULL(RecepcionServicio,'false') AS RecepcionServicio,
			ISNULL(P.Cerrado, 'false') AS PedidoCerrado,
			ISNULL(SOT.Objeto,SP.MotivoUrgencia) AS Justificacion
	FROM MM_Pedido AS P
	INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
	LEFT JOIN Adinco.dbo.OT_Estimacion AS OTS ON OTS.IdPedido = P.IdPedido
	LEFT JOIN Adinco.dbo.OT_Solicitud AS SOT ON SOT.IdOTSolicitud = OTS.IdOTSolicitud
	WHERE P.IdPedido = @IdPedido AND SP.IdProveedor= @IdProveedorComprador AND ISNULL(P.IdEstatusEliminado,0)<> 1 --> QUE NO ESTEN ELIMINADOS <> 1
	
END

