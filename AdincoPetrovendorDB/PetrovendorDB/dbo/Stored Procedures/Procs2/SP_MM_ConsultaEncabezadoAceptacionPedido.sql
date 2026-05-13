
-- =============================================
-- Author:		Daniel AC
-- Create date: 07-02-17
-- Description:	Consultar encabezado de aceptación de pedido
-- =============================================
-- Author:		Jose Roman
-- Create date: 16-10-2018
-- Description:	se agregan datos capturados en la aceptacion faltantes.
-- =============================================

CREATE PROCEDURE SP_MM_ConsultaEncabezadoAceptacionPedido
    @IdProveedor INT,
    @IdAceptacionPedido INT
AS
BEGIN

    SELECT AP.IdAceptacionPedido,
           PG.IdPedido,
           AP.Comentario,
           CONCAT(D.Calle, ' ', D.NoExterior, ' ', D.NoInterior, ' ', D.Colonia, ' ', D.Municipio, ' ', D.Estado, ' ', D.CodigoPostal, ' ', P.pais) AS Domicilio,
           CONCAT(ISNULL(pp.RazonSocial, ''), CASE WHEN rc.IdRegimenCapital IS NULL THEN  '' ELSE ', ' END, ISNULL(rc.Regimen, '')) AS Operadora,
		   CONCAT(ISNULL(sp.RazonSocial, ''), CASE WHEN r.IdRegimenCapital IS NULL THEN  '' ELSE ', ' END, ISNULL(r.Regimen, '')) AS Proveedor,
           AP.Creado,
           AP.NombreRecibidoPor,
		   AP.NombreUsuarioEntrega
    FROM MM_AceptacionPedido AS AP
		INNER JOIN dbo.S_Proveedor pp ON pp.IdProveedor = AP.IdProveedor
		LEFT JOIN dbo.RegimenCapital rc ON rc.IdRegimenCapital = pp.IdRegimenCapital
        INNER JOIN dbo.MM_Pedido AS MP ON MP.IdPedido = AP.IdPedido
		INNER JOIN dbo.S_Proveedor AS sp ON sp.IdProveedor = MP.IdSubcontratista
		LEFT JOIN dbo.RegimenCapital r ON r.IdRegimenCapital = sp.IdRegimenCapital
        INNER JOIN MM_Pedidos AS PG ON MP.IdPedido = PG.IdIdentificador AND PG.IdProveedorCliente = ap.IdProveedor
        LEFT JOIN DG_Domicilio AS D ON D.IdDomicilio = AP.IdDomicilioEntrega
        LEFT JOIN PV_PaisRepublica AS P ON P.id = D.IdDomicilio
    WHERE AP.IdAceptacionPedido = @IdAceptacionPedido;

END;


