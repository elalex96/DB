-- =============================================
-- Author:        Daniel AC
-- Create date: 02/07/2018
-- Description:    Se agrega filtro para mostrar solo aprobaciones con estatus diferente de eliminado, 
-- y agregue filtro para mostrar solo las operaciones donde el aprobador tiene pendiente de aprobación sin tomar en cuenta el estatus general de la aprobación
-- Se agrego columna de IdOperacion
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 04-12-18
-- Description:	Se agrega el filtro de los pedidos para las solicitudes seriales
-- =============================================

CREATE PROCEDURE [dbo].[SP_ConsultarSolicitudes] @idProveedor INT, @IdContrato INT, @IdUsuario INT ,
												 @FechaRegistro DATETIME
AS
	BEGIN
		-- SET NOCOUNT ON added to prevent extra result sets from
		-- interfering with SELECT statements.
		SET NOCOUNT ON

		SET LANGUAGE Español

		-- *************************************
		--INICIO para filtrar los pedidos seriales
		-- *************************************
		DECLARE @FlujoSerial TABLE
			( IdOperacion INT ,
			  NoSecuencia INT ) ;

		DECLARE @OperacionNoAprobadas TABLE
			( IdOperacion INT ) ;

		INSERT INTO @FlujoSerial
			( IdOperacion, NoSecuencia )
		SELECT		O.IdOperacion, t.NoSecuencia
		FROM		dbo.TA_Operacion O
		LEFT JOIN	dbo.MM_Pedido p
			ON p.IdSolicitudPedido = O.IdDocumento
			   AND	p.Version = O.NoVersion
		INNER JOIN	dbo.TA_Tarea t
			ON t.IdOperacion = O.IdOperacion
		WHERE
					O.IdTipoOperacion = 9
					AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 -->APROBACIÓN NO ESTE ELIMINADO
					AND t.IdAprobador = @IdUsuario
					AND t.NoSecuencia > 1 ;

		INSERT INTO @OperacionNoAprobadas
			( IdOperacion )
		SELECT		O.IdOperacion
		FROM		dbo.TA_Operacion O
		INNER JOIN	@FlujoSerial f
			ON f.IdOperacion = O.IdOperacion
		INNER JOIN	dbo.TA_Tarea T
			ON T.IdOperacion = O.IdOperacion
			   AND	T.NoSecuencia = ( f.NoSecuencia - 1 )
		WHERE
					O.IdTipoOperacion = 9
					AND T.IdEstatus <> 2 ;

		-- *************************************
		--FIN SECCION para filtrar los pedidos seriales
		-- *************************************
		SELECT		*
		FROM
					(
						/*APROBACIONES DE SOLICITUD DE PEDIDO*/
						SELECT		O.IdDocumento, O.IdAsignador, U.Nombre AS Asignador ,
									( LEFT(O.FechaRegistro, 11) + ' a las' + RIGHT(O.FechaRegistro, 8)) AS FechaRegistro ,
									O.Descripcion, O.IdTipoOperacion, TTO.NombreOperacion ,
									LEFT(( DATEADD ( DAY, TV.DiaVencimiento, O.FechaRegistro )), 11) + ' a las'
									+ RIGHT(( DATEADD ( DAY, TV.DiaVencimiento, O.FechaRegistro )), 8) AS FechaFinalizacion ,
									O.IdOperacion
						FROM		dbo.TA_Operacion O
						INNER JOIN	dbo.TA_TipoOperacion TTO
							ON TTO.IdTipoOperacion = O.IdTipoOperacion
						INNER JOIN	dbo.TA_Tarea tarea
							ON tarea.IdOperacion = O.IdOperacion
						INNER JOIN	dbo.TA_Estatus TE
							ON O.IdEstatusOperacion = TE.IdEstatus
						LEFT JOIN	dbo.S_Usuario U
							ON O.IdAsignador = U.IdUsuario
						LEFT JOIN	dbo.TA_Vencimiento TV
							ON O.IdVigencia = TV.IdVencimiento
						WHERE
									tarea.IdEstatus = 1
									AND O.IdProveedor = @idProveedor
									AND TTO.IdTipoOperacion = 2
									AND tarea.IdAprobador = @IdUsuario
									AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 --> QUE NO ESTE ELIMINADO
						GROUP BY	O.IdDocumento, O.IdAsignador, U.Nombre, O.FechaRegistro, O.Descripcion, O.IdTipoOperacion ,
									TTO.NombreOperacion, TV.DiaVencimiento, O.FechaRegistro, O.IdOperacion
						UNION ALL
						/*APROBACIONES DE COMPRA DIRECTA*/
						SELECT		R.IdPedido AS IdDocumento, O.IdAsignador, U.Nombre AS Asignador ,
									( LEFT(O.FechaRegistro, 11) + ' a las' + RIGHT(O.FechaRegistro, 8)) AS FechaRegistro ,
									O.Descripcion, O.IdTipoOperacion, TTO.NombreOperacion ,
									LEFT(( DATEADD ( DAY, TV.DiaVencimiento, O.FechaRegistro )), 11) + ' a las'
									+ RIGHT(( DATEADD ( DAY, TV.DiaVencimiento, O.FechaRegistro )), 8) AS FechaFinalizacion ,
									O.IdOperacion
						FROM		dbo.TA_Operacion O
						LEFT JOIN	dbo.MM_Pedidos R
							ON R.IdIdentificador = O.IdDocumento
							   AND	@IdProveedor = R.IdProveedorCliente
						INNER JOIN	dbo.TA_TipoOperacion TTO
							ON TTO.IdTipoOperacion = O.IdTipoOperacion
						INNER JOIN	dbo.TA_Tarea tarea
							ON tarea.IdOperacion = O.IdOperacion
						INNER JOIN	dbo.TA_Estatus TE
							ON O.IdEstatusOperacion = TE.IdEstatus
						LEFT JOIN	dbo.S_Usuario U
							ON O.IdAsignador = U.IdUsuario
						LEFT JOIN	dbo.TA_Vencimiento TV
							ON O.IdVigencia = TV.IdVencimiento
						WHERE
									tarea.IdEstatus = 1
									AND O.IdProveedor = @idProveedor
									AND TTO.IdTipoOperacion = 14
									AND tarea.IdAprobador = @IdUsuario
						GROUP BY	O.IdDocumento, O.IdAsignador, U.Nombre, O.FechaRegistro, O.Descripcion, O.IdTipoOperacion ,
									TTO.NombreOperacion, TV.DiaVencimiento, O.FechaRegistro, R.IdPedido, O.IdOperacion
						UNION ALL
						/*APROBACIONES DE PEDIDO*/
						SELECT		O.IdDocumento, O.IdAsignador, U.Nombre AS Asignador ,
									( LEFT(O.FechaRegistro, 11) + ' a las' + RIGHT(O.FechaRegistro, 8)) AS FechaRegistro ,
									O.Descripcion, O.IdTipoOperacion, TTO.NombreOperacion ,
									LEFT(( DATEADD ( DAY, TV.DiaVencimiento, O.FechaRegistro )), 11) + ' a las'
									+ RIGHT(( DATEADD ( DAY, TV.DiaVencimiento, O.FechaRegistro )), 8) AS FechaFinalizacion ,
									O.IdOperacion
						FROM		dbo.TA_Operacion O
						INNER JOIN	dbo.TA_TipoOperacion TTO
							ON TTO.IdTipoOperacion = O.IdTipoOperacion
						INNER JOIN	dbo.TA_Tarea tarea
							ON tarea.IdOperacion = O.IdOperacion
						INNER JOIN	dbo.TA_Estatus TE
							ON O.IdEstatusOperacion = TE.IdEstatus
						LEFT JOIN	dbo.S_Usuario U
							ON O.IdAsignador = U.IdUsuario
						LEFT JOIN	dbo.MM_Pedido P
							ON O.NoVersion = P.Version
						LEFT JOIN	dbo.TA_Vencimiento TV
							ON O.IdVigencia = TV.IdVencimiento
						WHERE
									tarea.IdEstatus = 1
									AND O.IdProveedor = @idProveedor
									AND TTO.IdTipoOperacion = 9
									AND O.NoVersion IS NOT NULL
									AND tarea.IdAprobador = @IdUsuario
									AND ISNULL ( O.IdEstatusEliminado, 0 ) <> 1 --> QUE NO ESTE ELIMINADO
									AND O.IdOperacion NOT IN
											( SELECT IdOperacion FROM	   @OperacionNoAprobadas )
						GROUP BY	O.IdDocumento, O.IdAsignador, U.Nombre, O.FechaRegistro, O.Descripcion, O.IdTipoOperacion ,
									TTO.NombreOperacion, TV.DiaVencimiento, O.FechaRegistro, O.IdOperacion ) AS Solicitudes
		ORDER BY	Solicitudes.FechaRegistro ASC
	END