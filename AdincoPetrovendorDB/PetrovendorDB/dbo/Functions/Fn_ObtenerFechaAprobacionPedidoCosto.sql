-- =============================================
-- Author: Pedro Acu�a
-- Create date: 12/06/2018
-- Description: obtener estatus, costo, fecha del pedido de cada version por solicitud de pedido
-- =============================================

CREATE FUNCTION Fn_ObtenerFechaAprobacionPedidoCosto
	(@IdContrato INT, @IdProveedor INT)
RETURNS @Retorno TABLE
	( IdSolicitudPedido INT ,
	  FechaRegistro DATETIME ,
	  Subtotal FLOAT ,
	  IdOperacion INT ,
	  IdEstatusOperacion INT ,
	  Version INT ,
	  Moneda INT ,
	  IdPeticionOferta INT )
AS
	BEGIN
		INSERT INTO @Retorno
			( IdSolicitudPedido, FechaRegistro, Subtotal, IdOperacion, IdEstatusOperacion, Version, Moneda ,
			  IdPeticionOferta )
		SELECT		P.IdSolicitudPedido, O.FechaRegistro, SUM ( PD.Subtotal ) AS SubTotal, O.IdOperacion ,
					O.IdEstatusOperacion, P.Version, P.IdMoneda, P.IdPeticionOferta
		--,O.Descripcion,E.Nombre AS nombreEstatus, U.Nombre, U.IdUsuario
		FROM		MM_Pedido AS P
		INNER JOIN	MM_PedidoDetalle AS PD
			ON PD.IdPedido = P.IdPedido
		INNER JOIN	MM_SolicitudPedido AS SP
			ON SP.IdSolicitudPedido = P.IdSolicitudPedido
		INNER JOIN	TA_Operacion AS O
			ON O.IdDocumento = SP.IdSolicitudPedido
		INNER JOIN	TA_Tarea AS TA
			ON TA.IdOperacion = O.IdOperacion
		INNER JOIN	TA_TipoOperacion AS TTO
			ON TTO.IdTipoOperacion = O.IdTipoOperacion
		INNER JOIN	TA_Estatus AS E
			ON E.IdEstatus = O.IdEstatusOperacion
		INNER JOIN	S_Usuario AS U
			ON U.IdUsuario = O.IdAsignador
		WHERE
					O.IdTipoOperacion = 9
					AND P.Version = O.NoVersion
					AND TA.IdTarea =
						(	SELECT	TOP 1
									tarea.IdTarea
							FROM	dbo.TA_Tarea tarea
							WHERE
									tarea.IdOperacion = O.IdOperacion
									AND tarea.Activo = 1 ) --ya que por cada aprobador se repiten los registros, solo me traigo el primero para que no me perjudique en la suma del subtotal
									AND P.IdContrato = @IdContrato
									AND SP.IdProveedor = @IdProveedor
		GROUP BY	P.IdSolicitudPedido, O.FechaRegistro, O.IdOperacion, O.IdEstatusOperacion, P.Version, P.IdMoneda ,
					P.IdPeticionOferta

		RETURN
	END