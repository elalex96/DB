
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <25-09-2018>
-- Description:	<Se consulta el requisitor de una solicitud de pedido>
-- =============================================

CREATE PROCEDURE MM_SP_ConsultarRequisitor
    @IdSolicitudPedido INT,
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
           u.IdUsuario
    FROM dbo.MM_SolicitudPedido sp
        INNER JOIN dbo.S_Usuario u
            ON u.IdUsuario = sp.IdUsuarioSolicitante
    WHERE sp.IdSolicitudPedido = @IdSolicitudPedido;
END;