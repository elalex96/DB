
-- =============================================
-- Author:		Daniel AC
-- Create date: 03-07-17
-- Description:	
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 09-03-18
-- Description:	se agrega el idproveedor para que retorne la consulta
-- Create date: 30-07-18
-- Description:	se agrega que solo retorne los usuarios activos
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <20-09-2018>
-- Description:	<Se consulta si en el pedido se a solicitado o no la carta CN>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <07/07/2020>
-- Description:	<se quito el filtrado por contrato (los proveedores no estan ligados a un contrato)>
-- =============================================

CREATE PROCEDURE [dbo].[MM_ACEP_ConsultarUsuarioVentas]
    @IdAceptacionPedido INT,
    @IdPedido INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT DISTINCT
        U.Nombre,
        U.Correo,
        U.IdTipoUsuario,
        U.IdUsuario,
        PV.IdProveedor,
		U.IdTipoUsuario
    FROM MM_AceptacionPedido AS AP
        INNER JOIN MM_Pedido AS P
            ON P.IdPedido = AP.IdPedido
        INNER JOIN S_Proveedor AS PV
            ON PV.IdProveedor = P.IdSubcontratista
        INNER JOIN S_UsuarioProveedor AS UP
            ON UP.IdProveedor = P.IdSubcontratista --AND UP.IdContrato = P.IdContrato
        INNER JOIN S_Usuario AS U
            ON U.IdUsuario = UP.IdUsuario
    WHERE (U.IdTipoUsuario = 4 OR U.IdTipoUsuario = 3)
          AND U.Activo = 1
          AND AP.IdAceptacionPedido = @IdAceptacionPedido
          AND P.IdPedido = @IdPedido
	GROUP BY U.Nombre,
             U.Correo,
             U.IdTipoUsuario,
             U.IdUsuario,
             PV.IdProveedor;
		  
END;
