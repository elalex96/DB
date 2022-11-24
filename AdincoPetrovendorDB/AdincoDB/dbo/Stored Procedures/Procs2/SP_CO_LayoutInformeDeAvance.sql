-- =============================================
-- Author:		Manuel CD
-- Create date: 28-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_LayoutInformeDeAvance]
	-- Add the parameters for the stored procedure here
@IdPresupuesto INT,
@IdActividad   INT,
@Anio          INT,
@Mes INT

AS
--SP_CO_LayoutInformeDeAvance @IdPresupuesto=10188,@IdActividad=1,@Anio=2021,@Mes=9

     BEGIN
         SET NOCOUNT ON;

         DECLARE @Etiqueta1 NVARCHAR(50);
         DECLARE @Etiqueta2 NVARCHAR(50);
         SELECT @Etiqueta1 = 'ID_ADMON'           WHERE @IdActividad = 1;
         SELECT @Etiqueta1 = 'ID_DUCTO'           WHERE @IdActividad = 2;
         SELECT @Etiqueta1 = 'ID_ESTUDIO'         WHERE @IdActividad = 3;
         SELECT @Etiqueta1 = 'ID_INSTALA'         WHERE @IdActividad = 4;
         SELECT @Etiqueta1 = 'ID_POZO'            WHERE @IdActividad = 5;
         SELECT @Etiqueta1 = '-'				  WHERE @IdActividad = 6;
         SELECT @Etiqueta2 = 'AC_UNIDAD_INSTALA'  WHERE @IdActividad = 4;
         SELECT @Etiqueta2 = 'AC_PRODUCCION_POZO' WHERE @IdActividad = 5;


		
		SELECT CO_ActividadCIEP.ID_CATACTIV AS ID_CATACTIV,
			   0 AS ID_CATSUBACTIV,
			   CO_LineaPresupuestoMes.IdTipoServicio AS ID_TIPOSER,
			   CAST(SUM(GastosAmatitlan2020.MontoUSDConMarkup) AS DECIMAL(18, 2)) AS AC_PRESUP_MES,
			   SUBSTRING(GastosAmatitlan2020.Servicio, 0, 500) AS AC_NOMBRE,
			   SUBSTRING(GastosAmatitlan2020.Servicio, 0, 10) AS AC_DESCRIPCION,
			   CONVERT(
						  CHAR(10),
						  (DATEFROMPARTS(
											YEAR(GastosAmatitlan2020.FechaInicio),
											MONTH(GastosAmatitlan2020.FechaInicio),
											DAY(GastosAmatitlan2020.FechaInicio)
										)
						  ),
						  103
					  ) AS AC_FEC_INI,
			   CONVERT(
						  CHAR(10),
						  (DATEFROMPARTS(
											YEAR(GastosAmatitlan2020.FechaFin),
											MONTH(GastosAmatitlan2020.FechaFin),
											DAY(GastosAmatitlan2020.FechaFin)
										)
						  ),
						  103
					  ) AS AC_FEC_FIN,
			   'S' AS AC_TERMINADO,
			   @Etiqueta1 AS Etiqueta1,
			   @Etiqueta2 AS Etiqueta2,
			   1 AS ID_CATACTHC,
			   0 AS ID_ACTIVIDAD_P,
			   @Etiqueta2 AS Etiqueta2,
			   CASE
				   WHEN @IdActividad = 4 THEN
					   ISNULL(CO_Instalacion.IdInstalacionPemex, '500084001')
				   WHEN @IdActividad = 5 THEN
					   ''                                             -- se tiene que validar el pozo
				   WHEN @IdActividad = 1 THEN
					   ISNULL(CO_Instalacion.IdInstalacionPemex, '1') --Esta es la instalacion que viene del gasto
				   WHEN @IdActividad = 3 THEN
					   ISNULL(CO_Instalacion.IdInstalacionPemex, '0') --  
				   ELSE
					   ISNULL(CO_Instalacion.IdInstalacionPemex, '')
			   END AS [ID_INSTALACION],
			   CASE
				   WHEN @IdActividad = 4 THEN
					   SUBSTRING(ISNULL(CO_Instalacion.NombreInstalacion, 'AREA CONTRACTUAL AMATITLAN'), 0, 10)
				   WHEN @IdActividad = 5 THEN
					   '0'
			   END AS Columna,
			   CO_TipoServicio.NombreTipoServicio
		FROM GastosAmatitlan2020
			INNER JOIN CO_Registro (NOLOCK)
				ON GastosAmatitlan2020.IdRegistro = CO_Registro.IdRegistro
			INNER JOIN CO_ActividadCIEP (NOLOCK)
				ON UPPER(LTRIM(RTRIM(GastosAmatitlan2020.Actividad))) = UPPER(LTRIM(RTRIM((CO_ActividadCIEP.NombreActividad))))
				   AND CO_ActividadCIEP.ID_CATACTIV = @IdActividad
			INNER JOIN CO_LineaPresupuestoMes (NOLOCK)
				ON GastosAmatitlan2020.LineaPresupuesto = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
				   AND CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
			LEFT JOIN CO_Instalacion (NOLOCK)
				ON CO_Registro.IdInstalacion = CO_Instalacion.IdInstalacion
			LEFT JOIN CO_TipoServicio (NOLOCK)
				ON UPPER(LTRIM(RTRIM(GastosAmatitlan2020.TipoDeServicio))) = UPPER(LTRIM(RTRIM((CO_TipoServicio.NombreTipoServicio))))
		WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
			  AND CO_ActividadCIEP.ID_CATACTIV = @IdActividad
			  AND YEAR(GastosAmatitlan2020.MesPresentacion) = @Anio
			  AND Month(GastosAmatitlan2020.MesPresentacion) = @Mes
		GROUP BY CO_LineaPresupuestoMes.IdTipoServicio,
				 CO_ActividadCIEP.ID_CATACTIV,
				 GastosAmatitlan2020.Servicio,
				 GastosAmatitlan2020.FechaInicio,
				 GastosAmatitlan2020.FechaFin,
				 CO_Instalacion.IdInstalacionPemex,
				 CO_Instalacion.NombreInstalacion,
				 CO_TipoServicio.NombreTipoServicio
     END;




