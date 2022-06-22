USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'DEA_SP_ConsultarSiAplicaCNProveedorExtranjero'
)
    DROP PROCEDURE DEA_SP_ConsultarSiAplicaCNProveedorExtranjero;
	GO
/****** Object:  StoredProcedure [dbo].[SRAP_ConsultarSolicitudesAceptacionPedido]    Script Date: 08/06/2022 03:15:13 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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