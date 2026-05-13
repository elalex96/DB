-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <28-10-2018>
-- Description:	<llenar el combo con la descripcion>
-- =============================================

CREATE PROCEDURE ADM_CmbOpcionesRadio
    @IdSolicitudPedido INT,
    @OpcionRadio INT
AS
BEGIN
    DECLARE @TablaCmb TABLE
    (
        Id INT,
        Texto NVARCHAR(MAX)
    )

    IF (ISNULL(@OpcionRadio, 0) = 1) -- requisicion por material
    BEGIN
        INSERT INTO @TablaCmb
        SELECT spd.IdSolicitudPedidoDetalle,
               CONCAT('Material solicitado: (', spd.Cantidad, ')', ' - ', m.DescripcionCorta, ' - ', m.DescripcionLarga) AS material
        FROM dbo.MM_SolicitudPedidoDetalle spd
            INNER JOIN dbo.MM_Material m
                ON m.IdMaterial = spd.IdMaterial
        WHERE spd.IdSolicitudPedido = @IdSolicitudPedido
    END

    IF (ISNULL(@OpcionRadio, 0) = 7) -- aceptacion de servicio
    BEGIN
        INSERT INTO @TablaCmb
        SELECT ap.IdAceptacionPedido,
               CONCAT(
                         '(Aceptación número: ',
                         ap.IdAceptacionPedido,
                         ') - (Número de pedido: ',
                         ps.IdPedido,
                         ') - (Requisición: ',
                         p.IdSolicitudPedido,
                         ') - (Proveedor: ',
                         prov.RazonSocial,
                         ')'
                     )
        FROM dbo.MM_Pedido p
            INNER JOIN dbo.MM_AceptacionPedido ap
                ON ap.IdPedido = p.IdPedido
            INNER JOIN dbo.S_Proveedor prov
                ON prov.IdProveedor = p.IdSubcontratista
            INNER JOIN dbo.MM_Pedidos ps
                ON ps.IdIdentificador = p.IdPedido
                   AND ap.IdProveedor = p.IdProveedorCompras
        WHERE p.IdSolicitudPedido = @IdSolicitudPedido
              AND ISNULL(ap.IdEstatusEliminado, 0) = 0
    END

	IF (ISNULL(@OpcionRadio, 0) = 8) --cotizacion por material
    BEGIN
		INSERT INTO @TablaCmb
		SELECT pod.IdSolicitudPedidoDetalle, 
		 CONCAT('Material cotizado: ', m.DescripcionCorta, ' - ', m.DescripcionLarga) AS material 
		FROM dbo.MM_SolicitudPedidoDetalle spd 
		INNER JOIN dbo.MM_PeticionOfertaDetalle pod ON pod.IdSolicitudPedidoDetalle = spd.IdSolicitudPedidoDetalle
		INNER JOIN dbo.MM_Material m ON pod.IdMaterial = m.IdMaterial
		WHERE spd.IdSolicitudPedido = @IdSolicitudPedido AND pod.Cotizado = 1
		GROUP BY m.DescripcionCorta, m.DescripcionLarga,
                 pod.IdSolicitudPedidoDetalle
	END	

    IF (ISNULL(@OpcionRadio, 0) = 10) -- anexos al pedido
    BEGIN
        INSERT INTO @TablaCmb
        SELECT p.IdPedido,
               CONCAT(
                         '(Pedido número: ',
                         ps.IdPedido,
                         ') - (Solicitud pedido: ',
                         p.IdSolicitudPedido,
                         ') - (Proveedor: ',
                         prov.RazonSocial,
                         ')'
                     )
        FROM dbo.MM_Pedido p
            INNER JOIN dbo.MM_Pedidos ps
                ON ps.IdIdentificador = p.IdPedido
                   AND p.IdProveedorCompras = ps.IdProveedorCliente
            INNER JOIN dbo.S_Proveedor prov
                ON prov.IdProveedor = p.IdSubcontratista
        WHERE p.IdSolicitudPedido = @IdSolicitudPedido
              AND ISNULL(p.IdEstatusEliminado, 0) = 0
    END

    SELECT Id,
           Texto
    FROM @TablaCmb
    ORDER BY Texto
END
