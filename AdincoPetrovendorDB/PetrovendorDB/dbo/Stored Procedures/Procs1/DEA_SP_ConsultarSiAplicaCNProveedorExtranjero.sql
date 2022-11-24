
CREATE PROCEDURE [dbo].[DEA_SP_ConsultarSiAplicaCNProveedorExtranjero] 
@IdPedido INT = 0,
@IdAceptacionPedido INT = 0,
@Filtro NVARCHAR(100)
AS
BEGIN
		
		 DECLARE @IdProveedorVenta INT 		
		 DECLARE @IdContrato INT 

		IF @Filtro ='ACEPTACION_PEDIDO'
		BEGIN 
			SELECT @IdPedido=IdPedido
			FROM MM_AceptacionPedido 			
			WHERE IdAceptacionPedido=@IdAceptacionPedido
			AND IdNacionalidadProveedor=2  --> CTE ES DE UNA ACEPTACION DE PEDIDO DE PROVEEDOR EXTRANJERO
		END 


		SELECT @IdContrato			= P.IdContrato,
			@IdProveedorVenta	= P.IdSubcontratista					
		FROM MM_Pedido P				
		WHERE P.IdPedido = @IdPedido

		SELECT COUNT(1) AS AplicaCNExtranjero
		FROM DEA_SolicitudCNProveedorExtranjero 
		WHERE IdContrato = @IdContrato
		AND IdProveedor = @IdProveedorVenta
		AND Activo= 1	
			
END