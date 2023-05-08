--============================
--creado por: Luis David
--creado el: 12/10/2021
--descripcion: se utiliza para validar los botones del detalle de la aceptación
--============================
CREATE PROCEDURE SP_MM_ConsultarBotonesodenDetalle
@IdProveedor int,
@RFC varchar(200),
@IdPedido int
AS
BEGIN
	IF EXISTS (SELECT 1 FROM dbo.MM_Pedido AS AP 
				JOIN dbo.S_Proveedor AS P ON AP.IdProveedorCompras = P.IdProveedor
				WHERE AP.IdPedido = @IdPedido
				AND
				p.RFC = 'DDE151002QY9')
			    BEGIN
					SELECT 'MOSTRAR_BOTONES_DEA'
				END
END
