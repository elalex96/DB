
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <10-07-2018>
-- Description:	<Se consulta a los usuarios a notificar cierre de un pedido>
-- =============================================
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <30-07-2018>
-- Description:	<Se agrega el filtro que solo usuarios activos sean notificados>
-- =============================================

CREATE PROCEDURE SP_MM_ConsultarPedidoXID
    @IdPedido INT,
    /*--------------------parametros contrato  --------------------*/
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL
/*-------------------------------------------------------------*/
AS
BEGIN
    SELECT	PG.IdPedido,
			U.Nombre,
			U.Correo,
			PR.IdProveedor,
			U.IdUsuario
    FROM MM_Pedido AS P 
		INNER JOIN S_Proveedor AS PR ON PR.IdProveedor = P.IdSubcontratista
        INNER JOIN S_UsuarioProveedor AS UP ON UP.IdProveedor = PR.IdProveedor
        INNER JOIN S_Usuario AS U ON U.IdUsuario = UP.IdUsuario
        INNER JOIN MM_HorasVigenciaPedido AS H ON H.IdPedido = P.IdPedido
		INNER JOIN dbo.MM_Pedidos AS PG ON PG.IdIdentificador = p.IdPedido
    WHERE P.IdPedido = @IdPedido
          AND (U.IdTipoUsuario = 4 OR U.IdTipoUsuario = 3) AND U.Activo = 1
END;
