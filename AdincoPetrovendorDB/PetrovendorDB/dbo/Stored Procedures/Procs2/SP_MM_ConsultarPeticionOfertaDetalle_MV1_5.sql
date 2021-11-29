DROP PROCEDURE IF EXISTS SP_MM_ConsultarPeticionOfertaDetalle_MV1_5
GO
-- =============================================
-- Author:   Daniel AC
-- Create date: 18/12/2017
-- Description: Consulta detalle de la petición de oferta - Cotización del lado del proveedor  venta
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <10/04/2018>
-- Description:	<Se agrega ultima columna con el estatus de cotizacion del material>
-- =============================================
-- Author:		<Alexander Gomez>
-- Create date: <25/03/2019>
-- Description:	<Se agrego el isnull en la unidad cuando no se cotiza,ya que editar la cotizacion aparecia sin unidad>
-- =============================================
-- =============================================
-- Author:           Daniel AC
-- Create date: 13-08-2019
-- Description: Add Marca, Modelo, No Parte a Descripción material 
-- =============================================
-- =============================================
-- Modified:      <Luis David>									
-- Updated date: <01/11/2021>									
-- Description: <Reacomodo de tablas para optimización>	
-- =============================================
-- =============================================
-- Modified:      <Luis David>									
-- Updated date: <26/11/2021>									
-- Description: <Se contemplan los nulls con el método isnull>	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarPeticionOfertaDetalle_MV1_5] --2822,44
	-- Add the parameters for the stored procedure here
	@IdPeticionOferta INT, 
	@IdProveedorVenta INT ,
	@IdContrato INT = null, 
	@IdUsuario INT = null, 
	@FechaRegistro DATETIME = null

AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets  from
		-- interfering with SELECT statements.
		SET NOCOUNT ON ;

		-- Insert statements for procedure here
		SELECT	POD.IdPeticionOfertaDetalle, 
				POD.IdMaterial, 
				CONCAT (MM.DescripcionCorta,
				 ' Marca: ', CASE WHEN ISNULL(LEN(MM.Marca),0)>0 THEN MM.Marca ELSE ' S/M' END,
				 ' Modelo: ', CASE WHEN ISNULL(LEN(MM.Modelo),0)>0 THEN MM.Modelo ELSE ' S/M' END,
				 ' No. Parte: ',CASE WHEN ISNULL(LEN(MM.NumeroParte),0)>0 THEN MM.NumeroParte  ELSE ' S/NP' END ) AS MaterialSolitadoTextC,
				--MM.DescripcionCorta AS MaterialSolitadoTextC ,
				POD.ComentariosComprador, POD.NoMaterialesRequeridos, 
				ISNULL(U.Unidad,UN.Unidad) AS Unidad,
				CASE
					WHEN PO.CotizacionRestringida = 1 THEN SPD.IdMaterial
					ELSE POD.IdMaterialVendedor
				END AS IdMaterialVendedor, 
				CASE
					WHEN PO.CotizacionRestringida = 1 THEN SPD.IdUnidad
					ELSE POD.IdUnidadProveedor
				END AS IdUnidadVendedor ,
				POD.PrecioUnitario, 
				CASE WHEN POD.NoCotizar IS NULL THEN 
					1 -->DEFAULT EN PESOS 
				ELSE 
				POD.IdMoneda
				END IdMoneda,
				CASE WHEN POD.NoCotizar IS NULL THEN 
					POD.NoMaterialesRequeridos
				ELSE  
				POD.Disponibilidad
				END AS Disponibilidad, 
				POD.ComentarioSubcontratista, 
				CASE
					WHEN ISNULL ( POD.Disponibilidad, 0 ) = 0 AND ISNULL(PO.CotizacionRestringida,0) = 1 THEN NULL
					ELSE POD.SubTotal
				END AS SubTotal ,
				POD.FechaVigencia ,
				( ISNULL ( D.Calle, '' ) + ' ' + ISNULL ( D.NoExterior, '' ) + ' ' + ISNULL ( D.NoInterior, '' ) + ' '
				  + ISNULL ( D.Colonia, '' ) + ' ' + ISNULL ( D.Municipio, '' ) + ' ' + ISNULL ( D.Estado, '' ) + ' '
				  + ISNULL ( D.CodigoPostal, '' )) AS DomicilioEntrega, ISNULL ( POD.NoCotizar, 'false' ) AS NoCotizar ,
				UP.Unidad AS UnidadProveedor, POD.IdUnidadProveedor, MM.DescripcionLarga AS MaterialSolitadoTextL ,
				--Encabezados para el grid
				CASE 
					WHEN ISNULL ( POD.NoCotizar, 0 ) = 1 THEN
						 'No cotizado'
					WHEN ISNULL ( POD.Disponibilidad, 0 ) > 0 THEN
						'Cotizado'
					ELSE
						'Pendiente'
				END AS EstadoCotizacion, 
				'Partida solicitada:' AS Encabezado1, 
				'Partida a cotizar:' AS Encabezado2 ,
				i.NombreInstalacion,
				POD.FechaEntrega,
				CASE
					WHEN PO.CotizacionRestringida = 1 
					THEN 'Está Cotización tiene los Materiales/Servicios a Cotizar Restringidos por Cliente, solo se pueden cotizar exactamente los Materiales/Servicios que el cliente Solicita.'
					ELSE '' 
				END AS CotizacionRestringida,
				CASE
					WHEN PO.CotizacionRestringida = 1 
					THEN 'Si los materiales no estan dentro de su catálogo, se agregaran automáticamente al cotizar el material.'
					ELSE '' 
				END AS CotizacionRestringida2,
				ISNULL(POD.NoCotizar,1) IdCondicionPago,
				CASE WHEN POD.NoCotizar IS NULL THEN 
					0  --> SI ESTA PENDIENTE PONER EN 1
				ELSE 
					POD.DiasCredito 
				END AS DiasCredito,
				POD.IdPeticionOferta
		  FROM	
				 MM_PeticionOferta AS PO
				INNER JOIN MM_PeticionOfertaDetalle AS POD
						   ON PO.IdPeticionOferta = POD.IdPeticionOferta 
						   AND PO.IdSubcontratista = @IdProveedorVenta  
						   AND PO.IdPeticionOferta = @IdPeticionOferta
				INNER JOIN MM_SolicitudPedido AS SP
						   ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
				INNER JOIN MM_SolicitudPedidoDetalle AS SPD
						   ON SP.IdSolicitudPedido = SPD.IdSolicitudPedido
							  AND	POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
				INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto AS spdlp
						   ON SPD.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
				LEFT JOIN Adinco.dbo.CO_Instalacion i
						  ON spdlp.IdInstalacion = i.IdInstalacion
				LEFT JOIN dbo.MM_Material AS MM
						  ON POD.IdMaterial = MM.IdMaterial
				LEFT JOIN PV_MM_MaterialUnidad AS U
						  ON POD.IdUnidad = U.IdUnidad
				LEFT JOIN PV_MM_MaterialUnidad AS UP
						  ON POD.IdUnidadProveedor = UP.IdUnidad
				LEFT JOIN DG_Domicilio AS D
						  ON SPD.IdDomicilioEntrega = D.IdDomicilio
				LEFT JOIN PV_MM_MaterialUnidad AS UN
						  ON SPD.IdUnidad = UN.IdUnidad
		 GROUP BY POD.IdPeticionOfertaDetalle, POD.IdMaterial, MM.DescripcionCorta, POD.ComentariosComprador ,
				  NoMaterialesRequeridos , U.Unidad, POD.IdMaterialVendedor, POD.PrecioUnitario, POD.IdMoneda ,
				  POD.Disponibilidad, POD.ComentarioSubcontratista, POD.SubTotal, POD.FechaVigencia, D.Calle ,
				  D.NoExterior, D.NoInterior, D.Colonia, D.Municipio, D.Estado, D.CodigoPostal, POD.NoCotizar ,
				  UP.Unidad, POD.IdUnidadProveedor, MM.DescripcionLarga, sp.IdTipoSolicitudPedido, i.NombreInstalacion ,
				  POD.FechaEntrega,UN.Unidad,PO.CotizacionRestringida,SPD.IdMaterial,SPD.IdUnidad, MM.Marca, MM.Modelo, MM.NumeroParte,
				  POD.IdEstatus, POD.IdCondicionPago,POD.DiasCredito,POD.IdPeticionOferta
	END
