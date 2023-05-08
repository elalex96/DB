-- =============================================
-- Author:		Alexander
-- Create date: 14-04-17
-- Description:	Consultar Solicitudes de Pedido  
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultaRequisiciones]
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario int,
	@TipoUsuario int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	IF @TipoUsuario = 9
	BEGIN	
	SELECT 
	SP.IdSolicitudPedido,
	SP.MotivoUrgencia,
	TE.Nombre AS Estatus
	FROM MM_SolicitudPedido AS SP
	INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = SP.IdEstado 
	WHERE 
	SP.IdUsuarioSolicitante = @IdUsuario AND 
	SP.IdProveedor = @IdProveedor
	END
	IF @TipoUsuario = 5
	BEGIN
	SELECT 
	SP.IdSolicitudPedido,
	SP.MotivoUrgencia,
	TE.Nombre AS Estatus
	FROM MM_SolicitudPedido AS SP
	INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = SP.IdEstado 
	WHERE
	SP.IdProveedor = @IdProveedor
	END
END

