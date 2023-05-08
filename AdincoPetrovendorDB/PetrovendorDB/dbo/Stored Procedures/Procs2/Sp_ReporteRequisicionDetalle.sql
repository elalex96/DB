CREATE PROCEDURE Sp_ReporteRequisicionDetalle @IdSolicitudPedido INT, @IdUsuario INT = NULL, @IdContrato INT = NULL ,
											  @FechaRegistro DATETIME = NULL
AS
	BEGIN
		SET NOCOUNT ON

		SELECT	SPD.IdSolicitudPedidoDetalle, MM.DescripcionCorta AS DescripcionCorta, MM.IdMaterial AS IdMaterial ,
				SPD.Cantidad, SPD.Observaciones, U.Unidad AS NombreUnidad ,
				CONCAT (
					D.Calle, ' ', D.NoExterior, ' ', D.NoInterior, ' ', D.Colonia, ' ', D.Municipio, ' ', D.Estado ,
					' ' , D.CodigoPostal, ' (', CAST(TD.TipoDomicilio AS NVARCHAR (MAX)), ')' ) AS DomicilioEntrega ,
				MM.DescripcionLarga AS TextoLargo, ISNULL ( SPD.IdUnidad, 0 ) AS IdUnidad, cc.CentroCosto ,
				i.NombreInstalacion ,
				dbo.Fn_RetornarMesProgramadoActividadConcat ( lp.IdLineaPresupuestoMes ) AS SubActividad
		  FROM	MM_SolicitudPedidoDetalle AS SPD
				INNER JOIN dbo.MM_Material AS MM
						   ON MM.IdMaterial = SPD.IdMaterial
				LEFT JOIN PV_MM_MaterialUnidad AS U
						  ON U.IdUnidad = SPD.IdUnidad
				LEFT JOIN DG_Domicilio AS D
						  ON D.IdDomicilio = SPD.IdDomicilioEntrega
				LEFT JOIN dbo.DG_TipoDomicilio TD
						  ON TD.IdTipoDomicilio = D.IdTipoDomicilio
				INNER JOIN MM_SolicitudPedidoDetalleLineaPresupuesto spdl
						   ON SPD.IdSolicitudPedidoDetalle = spdl.IdSolicitudPedidoDetalle
				LEFT JOIN Petrovendor.dbo.CC_CentroCosto AS cc
						  ON cc.IdCentroCosto = spdl.IdCentroCosto
				LEFT JOIN Adinco.dbo.CO_Instalacion AS i
						  ON i.IdInstalacion = spdl.IdInstalacion
				LEFT JOIN Adinco.dbo.CO_LineaPresupuestoMes AS lp
						  ON lp.IdLineaPresupuestoMes = spdl.IdLineaPresupuesto
				LEFT JOIN Adinco.dbo.CO_TareaPetrolera AS t
						  ON t.IdTareaPetrolera = lp.IdTareaPetrolera
		 WHERE	IdSolicitudPedido = @IdSolicitudPedido
	ENd