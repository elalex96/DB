
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <25-09-2018>
-- Description:	<Se consulta el requisitor de una solicitud de pedido>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <23/01/2023>
-- Description:	<solo se consultar usuario activos>
-- =============================================

CREATE PROCEDURE [dbo].[MM_SP_ConsultarRequisitor]
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
         JOIN dbo.S_Usuario u
            ON sp.IdUsuarioSolicitante = u.IdUsuario
			AND ISNULL(U.Activo,0) = 1
			AND ISNULL(U.IsEliminado,0) = 0
    WHERE sp.IdSolicitudPedido = @IdSolicitudPedido;

END;