-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-08-2018>
-- Description:	<Consulta de materiales por proveedor en pantalla de importacion de materiales>
-- =============================================
-- Author:		<Marcos Neri>
-- Create date: <17-04-2019>
-- Description:	<Agregar IdMaterial concatenado con la descripcion corta>
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_ConsultaMaterialesImportados]	--420
	@IdProveedor INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/

AS 
BEGIN
	SELECT		Fecha = cast (FechaAlta as date),
				m.IdUnidad,
				m.FechaAlta,
				'No. Material: '+CAST(m.IdMaterial AS VARCHAR)+' | Descripción: '+m.DescripcionCorta  AS DescripcionCorta ,
				m.DescripcionLarga,
				CASE WHEN m.IdTipoCatalogoMaestro = 1 THEN 'Material'
					 WHEN m.IdTipoCatalogoMaestro = 2 THEN 'Servicio' 
					 ELSE 'No especificado' END AS Tipo,
				up.Unidad AS UnidadPredeterminada,
				u1.Unidad AS Unidad1,
				u2.Unidad AS Unidad2,
				u3.Unidad AS Unidad3,
				m.Marca,
				m.Modelo,
				m.Presentacion,
				m.TiempoEntregaEstimadoDias,
				m.NumeroParte,
				a.Nombre AS ActividadEconomica,
				m.Consumible,
				m.Inventariable,
				u.Nombre AS Creador
	--into		#tmp
	FROM		dbo.MM_Material m
	inner join	PV_MM_MaterialUnidad	up	ON up.IdUnidad = m.IdUnidad
	left join	PV_MM_MaterialUnidad	u1	ON u1.IdUnidad = m.IdUnidad_1
	left join	PV_MM_MaterialUnidad	u2	ON u2.IdUnidad = m.IdUnidad_2
	left join	PV_MM_MaterialUnidad	u3	ON u3.IdUnidad = m.IdUnidad_3
	left join	MM_BS_Actividad			a	ON a.IdActividad = m.IdBienServicioEconomia
	inner join	dbo.S_Usuario			u	ON u.IdUsuario = m.CreadoPor
	WHERE IdProveedor = @IdProveedor
		AND m.Activo = 1
	ORDER BY FechaAlta DESC

	--select		Fecha from #tmp group by Fecha
	--select		* from #tmp
END

