CREATE FUNCTION [dbo].[fn_SC_AdquisicionMaterialesCarso]
(
    @IdPedido INT
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    DECLARE @Retorno NVARCHAR(MAX);

    SELECT @Retorno =
    (
        SELECT STUFF(
               (
                   SELECT CAST('\ ' AS VARCHAR(MAX)) + CONVERT(NVARCHAR(MAX), C.Item)
                   FROM Petrovendor..MM_Pedido P
                       LEFT JOIN Petrovendor..MM_PedidoDetalle PD
                           ON PD.IdPedido = P.IdPedido
                       LEFT JOIN Petrovendor..MM_PeticionOferta PO
                           ON PO.IdPeticionOferta = P.IdPeticionOferta
                       LEFT JOIN Petrovendor..MM_PeticionOfertaDetalle POD
                           ON PO.IdPeticionOferta = POD.IdPeticionOferta
                              AND PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle
                       LEFT JOIN Petrovendor..MM_SolicitudPedido SP
                           ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
                              AND P.IdSolicitudPedido = SP.IdSolicitudPedido
                       LEFT JOIN Petrovendor..MM_SolicitudPedidoDetalle AS SPD
                           ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
                              AND SPD.IdSolicitudPedidoDetalle = POD.IdSolicitudPedidoDetalle
                       LEFT JOIN Petrovendor..AX_Comparativa AS C
                           ON C.IdSolicitudPedido = SP.IdSolicitudPedido
                              AND C.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle							  
                   WHERE P.IdPedido = @IdPedido
				   GROUP BY C.Item
                   FOR XML PATH('')
               ),
               1,
               1,
               ''
                    ) AS IdUsuario
    );

    RETURN @Retorno;
END;




