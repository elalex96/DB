USE Petrovendor
GO
DROP PROC IF EXISTS SP_RPT_MM_ConsultaSolicitudesPedido
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 05-06-18
-- Description:	Consultar Solicitudes de Pedido  y filtro de activo o eliminado
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 22-10-18
-- Description:	se agregan columnas solicitadas (Si fue Cotizado, Sol Oferta Enviada, Fecha de Vencimiento Cotizacion, Proveedores a cotizar
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 05/07/2020
-- Description:	se optimizo la consulta eliminando relaciones y campos que no son necesarios en la vista
-- =============================================
-- Author:		LUIS DAVID
-- Create date: 24/09/2024
-- Description:	Se ajusta la consulta para validar que si es empresa pcm, pico, altamira entonces se muestre la columna localidad
-- =============================================
CREATE PROCEDURE [dbo].[SP_RPT_MM_ConsultaSolicitudesPedido]
	-- Add the parameters for the stored procedure here
	@IdProveedor INT, 
	@IdUsuario INT, 
	@IdContrato INT = NULL, 
	@FechaRegistro DATETIME = NULL,
	@RFC VARCHAR(100)
AS
	BEGIN
	SET NOCOUNT ON
	
	IF(@RFC IN (
	'PCM171127RVA', --Cardenas Mora
	'PAL120710ID0', --COMPAÑIA PETROLERA DE ALTAMIRA
	'PMS090112TB0' -- PICO MEXICO SERVICIOS PETROLEROS
	))
	BEGIN
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
			AND ISNULL(SP.IdEstatusEliminado,0)<>1
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
				AND TAO.IdTipoOperacion = 2
			JOIN TA_Estatus AS TE
				ON TE.IdEstatus = TAO.IdEstatusOperacion
			JOIN S_Usuario AS U
						ON SP.IdUsuarioSolicitante = U.IdUsuario
			JOIN dbo.MM_PeticionOferta PO
				ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
			LEFT JOIN MM_Localidades AS L
					ON SP.IdLocalidad = L.Id
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
				TAO.Descripcion,
				L.Nombre
			ORDER BY SP.FechaAlta DESC
	END
END
