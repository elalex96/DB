
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <29-09-2018>
-- Description:	<Se consulta los datos del requisitor por medio de un IdPedido>
-- =============================================

CREATE PROCEDURE MM_SP_ConsultarRequisitorPorPedido	
	@IdPedido INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT u.Nombre,
           u.Correo,
           sp.IdProveedor,
           u.IdUsuario,
		   sp.IdSolicitudPedido
	FROM dbo.MM_Pedido p
	INNER JOIN dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = p.IdSolicitudPedido
	INNER JOIN dbo.S_Usuario u ON u.IdUsuario = sp.IdUsuarioSolicitante
	WHERE p.IdPedido = @IdPedido
END
