CREATE PROCEDURE Sp_RecuperarCarritoAntesDeGeneracionPedido
(@IdSolicitudPedido INT)
AS
BEGIN

    SELECT ROW_NUMBER() OVER (ORDER BY PO.IdSubcontratista ASC) AS Row#,
           PO.IdSubcontratista,
           POD.PrecioUnitario,
           POD.AddCantidadTemp,
           POD.IdMoneda,
           POD.IdPeticionOferta,
           POD.IdPeticionOfertaDetalle
    FROM dbo.MM_PeticionOferta AS PO
        INNER JOIN dbo.MM_PeticionOfertaDetalle AS POD
            ON POD.IdPeticionOferta = PO.IdPeticionOferta
        INNER JOIN dbo.MM_SolicitudPedido AS SP
            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
        INNER JOIN dbo.MM_SolicitudPedidoDetalle AS SPD
            ON SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
    WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
          AND POD.AddValidado = 1
          AND POD.Cotizado = 1
          AND POD.AddPedidoTemp = 1
		  ORDER BY PO.IdPeticionOferta
END