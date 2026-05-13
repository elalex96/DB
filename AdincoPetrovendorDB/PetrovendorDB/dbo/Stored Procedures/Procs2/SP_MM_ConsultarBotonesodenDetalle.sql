USE Petrovendor
GO
DROP PROC IF EXISTS SP_MM_ConsultarBotonesodenDetalle
GO
--============================
--creado por: Luis David
--creado el: 12/10/2021
--descripcion: se utiliza para validar los botones del detalle de la aceptación
--============================
--creado por: Luis David
--creado el: 06/MAYO/2024
--descripcion: Se agrega el RFC de DNA para el flujo de aprobación de Aceptación de Servicios
--============================
CREATE PROCEDURE SP_MM_ConsultarBotonesodenDetalle
@IdProveedor int,
@RFC varchar(200),
@IdPedido int
AS
BEGIN
	IF EXISTS (
    SELECT 1 
    FROM dbo.MM_Pedido AS AP 
    JOIN dbo.S_Proveedor AS P ON AP.IdProveedorCompras = P.IdProveedor
    WHERE AP.IdPedido = @IdPedido
    AND p.RFC IN 
	('DDE151002QY9', --WINTERSHALLDEA
	'LIS130820563' --DNA SERVICIOS(LIS130820563)
	) 
	)
	BEGIN
		SELECT 'MOSTRAR_BOTONES_SAS'
	END
END
