USE petrovendor
GO
DROP PROC IF EXISTS SP_RPT_MM_ConsultaSolicitudesPedido_MasterDetail
GO
-- Author:		LUIS DAVID
-- Create date: 24/09/2024
-- Description:	Se ajusta la consulta para validar que si es empresa pcm, pico, altamira entonces se muestre la columna localidad
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_MM_ConsultaSolicitudesPedido_MasterDetail]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, 
	@IdUsuario INT = NULL, 
	@IdContrato INT = NULL,
	@RFC varchar(100) = null
AS
	BEGIN
		SET NOCOUNT ON

		drop table if exists #SolpedProveedor
		CREATE TABLE #SolpedProveedor
		(	
			IdSolicituidPedido int
		)
		--##Master
		IF(@RFC IN (
				'PCM171127RVA', --Cardenas Mora
				'PAL120710ID0', --COMPAÑIA PETROLERA DE ALTAMIRA
				'PMS090112TB0' -- PICO MEXICO SERVICIOS PETROLEROS
				))
		BEGIN
			insert into #SolpedProveedor
			SELECT 
				SP.IdSolicitudPedido
			FROM MM_SolicitudPedido AS SP
			JOIN MM_TipoSolicitudPedido AS TSP
				ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
			JOIN TA_Operacion AS TAO
				ON TAO.IdDocumento = SP.IdSolicitudPedido
				AND TAO.IdTipoOperacion = 2 -- Operación Requisición
			JOIN TA_Estatus AS TE
				ON TE.IdEstatus = TAO.IdEstatusOperacion
			JOIN S_Usuario AS U
				ON SP.IdUsuarioSolicitante = U.IdUsuario
			LEFT JOIN MM_Localidades AS L
				ON SP.IdLocalidad = L.Id
			WHERE
				SP.IdProveedor = @IdProveedor
				AND ISNULL ( SP.Visible, 1 ) = 1
				AND TE.IdEstatus IN (1,2) -- Estatus En Aprobación(1) y Aprobado(2)
			GROUP BY	
				SP.IdSolicitudPedido, 
				SP.MotivoUrgencia, 
				TSP.TipoSolicitudPedido, 
				SP.FechaAlta, 
				U.Nombre ,
				SP.MotivoUrgencia, 
				TE.Nombre, 
				SP.IdEstatusEliminado, 
				SP.IdProveedor, 
				SP.PeticionEnviada,
				TAO.Descripcion,
				L.Nombre
			ORDER BY SP.FechaAlta DESC
			SELECT
			SP.IdSolicitudPedido, 
			SP.MotivoUrgencia, 
			TSP.TipoSolicitudPedido, 
			SP.FechaAlta ,
			U.Nombre AS NombreUsuario, 
			TAO.Descripcion, 
			TE.Nombre,
			CASE 
				WHEN ISNULL(SP.IdEstatusEliminado,0) <> 1 THEN 'Activo'
				ELSE 'Eliminado'
			END AS Activo,
			ISNULL(L.Nombre,'') AS 'Localidad'
		FROM MM_SolicitudPedido AS SP
		JOIN MM_TipoSolicitudPedido AS TSP     
			ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
		JOIN TA_Operacion AS TAO
			ON TAO.IdDocumento = SP.IdSolicitudPedido
			AND TAO.IdTipoOperacion = 2 -- Operación Requisición
		JOIN TA_Estatus AS TE
			ON TE.IdEstatus = TAO.IdEstatusOperacion
		JOIN S_Usuario AS U
			ON SP.IdUsuarioSolicitante = U.IdUsuario
		LEFT JOIN MM_Localidades AS L
			ON SP.IdLocalidad = L.Id
		WHERE
			SP.IdProveedor = @IdProveedor
			AND ISNULL ( SP.Visible, 1 ) = 1
			AND TE.IdEstatus IN (1,2) -- Estatus En Aprobación(1) y Aprobado(2)
		GROUP BY	
			SP.IdSolicitudPedido, 
			SP.MotivoUrgencia, 
			TSP.TipoSolicitudPedido, 
			SP.FechaAlta, 
			U.Nombre ,
			SP.MotivoUrgencia, 
			TE.Nombre, 
			SP.IdEstatusEliminado, 
			SP.IdProveedor, 
			SP.PeticionEnviada,
			TAO.Descripcion,
			L.Nombre
		ORDER BY SP.FechaAlta DESC
		END
		ELSE 
		BEGIN
			insert into #SolpedProveedor
			SELECT 
				SP.IdSolicitudPedido
			FROM MM_SolicitudPedido AS SP
			JOIN MM_TipoSolicitudPedido AS TSP
				ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
			JOIN TA_Operacion AS TAO
				ON TAO.IdDocumento = SP.IdSolicitudPedido
				AND TAO.IdTipoOperacion = 2
			JOIN TA_Estatus AS TE
				ON TE.IdEstatus = TAO.IdEstatusOperacion
			JOIN S_Usuario AS U
						ON SP.IdUsuarioSolicitante = U.IdUsuario
			JOIN dbo.MM_PeticionOferta PO
				ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
			WHERE
				SP.IdProveedor = @IdProveedor
				AND ISNULL ( SP.Visible, 1 ) = 1
			GROUP BY	
				SP.IdSolicitudPedido, 
				SP.MotivoUrgencia, 
				TSP.TipoSolicitudPedido, 
				SP.FechaAlta, 
				U.Nombre ,
				SP.MotivoUrgencia, 
				TE.Nombre, 
				SP.IdEstatusEliminado, 
				SP.IdProveedor, 
				SP.PeticionEnviada,
				TAO.Descripcion
			ORDER BY SP.FechaAlta DESC
			SELECT 
			SP.IdSolicitudPedido, 
			SP.MotivoUrgencia, 
			TSP.TipoSolicitudPedido, 
			SP.FechaAlta ,
			U.Nombre AS NombreUsuario, 
			TAO.Descripcion, 
			TE.Nombre,
			CASE 
				WHEN ISNULL(SP.IdEstatusEliminado,0) <> 1 THEN 'Activo'
				ELSE 'Eliminado'
			END AS Activo
		FROM MM_SolicitudPedido AS SP
		JOIN MM_TipoSolicitudPedido AS TSP
			ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
		JOIN TA_Operacion AS TAO
			ON TAO.IdDocumento = SP.IdSolicitudPedido
			AND TAO.IdTipoOperacion = 2
		JOIN TA_Estatus AS TE
			ON TE.IdEstatus = TAO.IdEstatusOperacion
		JOIN S_Usuario AS U
					ON SP.IdUsuarioSolicitante = U.IdUsuario
		JOIN dbo.MM_PeticionOferta PO
			ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
		WHERE
			SP.IdProveedor = @IdProveedor
			AND ISNULL ( SP.Visible, 1 ) = 1
		GROUP BY	
			SP.IdSolicitudPedido, 
			SP.MotivoUrgencia, 
			TSP.TipoSolicitudPedido, 
			SP.FechaAlta, 
			U.Nombre ,
			SP.MotivoUrgencia, 
			TE.Nombre, 
			SP.IdEstatusEliminado, 
			SP.IdProveedor, 
			SP.PeticionEnviada,
			TAO.Descripcion
		ORDER BY SP.FechaAlta DESC
		END

		--###Detail
		SELECT	SPD.IdSolicitudPedido,SPD.IdSolicitudPedidoDetalle, MM.DescripcionCorta AS DescripcionCorta, MM.IdMaterial AS IdMaterial ,
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
				WHERE	SPD.IdSolicitudPedido in (select IdSolicituidPedido from #SolpedProveedor)


END
