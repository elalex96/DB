-- =============================================
-- Author:		Pedro Acuña
-- Create date: 11/01/2019
-- Description:	 se agrega la fecha de entrega por partida
-- =============================================

CREATE PROCEDURE [dbo].[SP_CO_ActualizarNoCotizar] @IdPeticionOferta INT, @IdPeticionOfertaDetalle INT, @IdUsuario INT ,
												   @IdProveedor INT
AS
	BEGIN
		DECLARE @IdEdicionCotizacion INT
		DECLARE @IdEstatusEdicionCotizacion INT
		DECLARE @NoCotizado_Actual BIT
		DECLARE @Detalle NVARCHAR (MAX)
		DECLARE @NOMBRE_USUARIO NVARCHAR (350)

		SET @IdEdicionCotizacion = (   SELECT	IdEdicionCotizacion
										 FROM	dbo.MM_EdicionCotizacion
										WHERE	IdPeticionOferta = @IdPeticionOferta )

		IF ISNULL ( @IdEdicionCotizacion, 0 ) <> 0
			BEGIN
				SET @IdEstatusEdicionCotizacion = (	  SELECT	IdEstatus
														FROM	dbo.MM_EdicionCotizacion
													   WHERE	IdPeticionOferta = @IdPeticionOferta )

				IF @IdEstatusEdicionCotizacion = 1 ---Estatus en edición de cotización
					BEGIN
						SET @NoCotizado_Actual = (	 SELECT NoCotizar
													   FROM dbo.MM_PeticionOferta
													  WHERE IdPeticionOferta = @IdPeticionOferta )

						IF @NoCotizado_Actual = 0
							BEGIN
								SET @Detalle = N'Se cambio de Cotizar a  No Cotizar'

								INSERT INTO MM_HistorialEdicionCotizacion
									( [IdEdicionCotizacion], [IdUsuario], [IdProveedor], [Fecha], [Descripcion] )
								VALUES
									( @IdEdicionCotizacion, @IdUsuario, @IdProveedor, GETDATE (), @Detalle )

								INSERT INTO MM_HistorialEdicionCotizacion
									( [IdEdicionCotizacion], [IdUsuario], [IdProveedor], [Fecha] ,
									  [IdPeticionOfertaDetalle] , [Descripcion] )
								SELECT	@IdEdicionCotizacion, @IdUsuario, @IdProveedor, GETDATE () ,
										POD.IdPeticionOfertaDetalle ,
										CASE WHEN POD.Cotizado = 1 THEN
												 'Cambio de cotizado a no cotizado. valores que fueron restablecidos *Material: '
												 + CAST(ISNULL ( POD.IdMaterialVendedor, 0 ) AS NVARCHAR (MAX)) + ' - '
												 + ISNULL ( M.DescripcionCorta, 'No identificado' )
												 + ' * Precio unitario: '
												 + CAST(ISNULL ( POD.PrecioUnitario, 0 ) AS NVARCHAR (MAX))
												 + ' *Cantidad disponible a cotizar:'
												 + CAST(ISNULL ( POD.Disponibilidad, 0 ) AS NVARCHAR (MAX))
												 + ' *Tipo de moneda: '
												 + ISNULL ( TM.TipoMonedaCorto, 'No identificada' )
												 + ' *Fecha límite de la oferta: '
												 + CAST(ISNULL ( POD.FechaVigencia, GETDATE ()) AS NVARCHAR (MAX))
												 + ' *Observaciones:'
												 + ISNULL ( POD.ComentarioSubcontratista, 'Sin observaciones' )
												 + ' *Fecha de entrega: '
												 + CAST(ISNULL ( POD.FechaEntrega, GETDATE ()) AS NVARCHAR (MAX))
											ELSE
												'Material ya se encontraba sin cotizar'
										END AS Detalle
								  FROM	dbo.MM_PeticionOfertaDetalle POD
										INNER JOIN dbo.MM_PeticionOferta PO
												   ON PO.IdPeticionOferta = POD.IdPeticionOferta
										LEFT JOIN dbo.PV_TipoMoneda TM
												  ON TM.IdMoneda = POD.IdMoneda
										LEFT JOIN dbo.MM_Material M
												  ON M.IdMaterial = POD.IdMaterialVendedor
								 WHERE	POD.IdPeticionOferta = @IdPeticionOferta
								 ORDER BY POD.IdPeticionOfertaDetalle ASC
							END
					END
			END

		--#Actualizar todas las peticiones oferta detalle 
		UPDATE	POD
		   SET	POD.[NoCotizar] = 1, POD.[PrecioUnitario] = NULL, POD.[ComentarioSubcontratista] = NULL ,
				POD.[ModificadoPor] = @IdUsuario, POD.[ModificadoEl] = GETDATE (), POD.[IdMoneda] = NULL ,
				POD.[Disponibilidad] = NULL, POD.[Cotizado] = 0, POD.[SubTotal] = NULL, POD.[FechaVigencia] = NULL ,
				POD.[ModificadoProveedorPor] = @IdProveedor, POD.[IdMaterialVendedor] = NULL, POD.FechaEntrega = NULL,
				POD.IdUnidad = NULL, POD.IdUnidadProveedor = NULL
		  FROM	[dbo].[MM_PeticionOfertaDetalle] AS POD
				INNER JOIN dbo.MM_PeticionOferta AS PO
						   ON PO.IdPeticionOferta = POD.IdPeticionOferta
		 WHERE	POD.IdPeticionOferta = @IdPeticionOferta ;

		UPDATE	MM_PeticionOferta
		   SET	NoCotizar = 1, Cotizado = 0
		 WHERE	IdPeticionOferta = @IdPeticionOferta

		IF ISNULL ( @IdEdicionCotizacion, 0 ) <> 0
			BEGIN
				SET @IdEstatusEdicionCotizacion = (	  SELECT	IdEstatus
														FROM	dbo.MM_EdicionCotizacion
													   WHERE	IdPeticionOferta = @IdPeticionOferta )

				IF @IdEstatusEdicionCotizacion = 1 ---Estatus en edición de cotización
					BEGIN
						UPDATE	dbo.MM_EdicionCotizacion
						   SET	ModificadoEl = GETDATE (), ModificadoPor = @IdUsuario, IdEstatus = 2	--ESTATUS APROBADO = EN EDICION FINALIZADA
						 WHERE	IdEdicionCotizacion = @IdEdicionCotizacion

						SET @NOMBRE_USUARIO = ( SELECT Nombre  FROM S_Usuario WHERE IdUsuario = @IdUsuario )
						SET @DETALLE = ( 'Edición finalizada' )

						INSERT INTO MM_HistorialEdicionCotizacion
							( [IdEdicionCotizacion], [IdUsuario], [IdProveedor], [Fecha], [EdicionCabecera] ,
							  [Descripcion] )
						VALUES
							( @IdEdicionCotizacion, @IdUsuario, @IdProveedor, GETDATE (), 1, @DETALLE )
					END
			END
	END
