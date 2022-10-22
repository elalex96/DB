
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20/10/2022
-- Description:	se agregan los valores por si acaso es null de las instalaciones y los pozos
-- y se agrega la etiqueta y valores nuevos
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ReporteLayoutProgramaACDESC_V2] 
@IdPresupuesto INT          = 0,
@Anio          VARCHAR(10),
@IdActividad   INT          = 0
AS
     BEGIN
         SET NOCOUNT ON;
         DECLARE @Label VARCHAR(50), @Etiqueta2 VARCHAR(50);

		 SELECT @Label =
		 CASE @IdActividad
			WHEN 1
			THEN 'ID_ADMON'
			WHEN 2
			THEN 'ID_DUCTO'
			WHEN 3
			THEN 'ID_ESTUDIO'
			WHEN 4
			THEN 'ID_INSTALA'
			WHEN 5
			THEN 'ID_POZO'
		ELSE
			''
		END,
		@Etiqueta2=
		 CASE @IdActividad
			WHEN 4
			THEN 'AC_UNIDAD_INSTALA'
			WHEN 5
			THEN 'AC_PRODUCCION_POZO'
		ELSE
			''
		END
      
         SELECT AC.ID_CATACTIV AS [ID_CATACTIV],
                SA.ID_CATSUBACTIV AS [ID Subatividad],
                ID_TIPOSER AS [ID_TIPOSER],
				CAST(SUM(LP.Monto) AS DECIMAL(15, 2)) AS [AC_PRESUP_MES],
                SUBSTRING( S.NombreServicio,0,500) AS [AC_NOMBRE],
				SUBSTRING( S.NombreServicio,0,10)  AS [AC_DESCRIPCION],
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_INI), MONTH(LP.AC_FEC_INI), DAY(LP.AC_FEC_INI))), 103) AS [AC_FEC_INI], 
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_FIN), MONTH(LP.AC_FEC_FIN), DAY(LP.AC_FEC_FIN))), 103) AS [AC_FEC_FIN],
                'S' AS [AC_TERMINADO],
				CASE
                    WHEN @IdActividad = 4
                    THEN  ISNULL(I.IdInstalacionPemex,'500084001') 
                    WHEN @IdActividad = 5
                    THEN  ISNULL(I.IdInstalacionPemex,'300085036') 
                END AS [ID_INSTALACION],
                1 AS [ID_CATACTHC],
                @Label AS Etiqueta,
				@Etiqueta2 AS Etiqueta2,
				CASE
                    WHEN @IdActividad = 4
                    THEN SUBSTRING(ISNULL(I.NombreInstalacion, 'AREA CONTRACTUAL AMATITLAN'),0,10)
                    WHEN @IdActividad = 5
                    THEN '0'
                END AS Columna
         FROM CO_LineaPresupuestoMes LP (NOLOCK) 
              LEFT JOIN 
				CO_Servicio S	(NOLOCK) 
				ON LP.idServicio = S.IdServicio
              LEFT JOIN 
				CO_SubactividadCIEP SA	(NOLOCK) 
				ON LP.IdSubactividad = SA.IdSubactividad
              LEFT JOIN 
				CO_Instalacion I	(NOLOCK) 
				ON LP.IdInstalacion = I.IdInstalacion
              LEFT JOIN 
				CO_ActividadCIEP AC	(NOLOCK) 
				ON LP.IdActividad = AC.IdActividad
              LEFT JOIN 
				CO_TipoServicio TS	(NOLOCK) 
				ON LP.IdTipoServicio = TS.IdTipoServicio 
              LEFT JOIN 
				CO_ActividadHidrocarburoCIEP AH	(NOLOCK) 
				ON ah.IdActividadHidrocarburo = LP.IdActvidadHidrocarburo
         WHERE 
				LP.IdPresupuesto = @IdPresupuesto
				AND AC.ID_CATACTIV = @IdActividad
				AND YEAR(LP.AC_FEC_INI) = YEAR(@Anio)
         GROUP BY AC.ID_CATACTIV,
                  SA.ID_CATSUBACTIV,
                  ID_TIPOSER,
                  S.NombreServicio,
                  SA.NombreSubactividad,
                  LP.AC_FEC_INI,
                  LP.AC_FEC_FIN,
                  CASE
                    WHEN @IdActividad = 4
                    THEN  ISNULL(I.IdInstalacionPemex,'500084001') 
                    WHEN @IdActividad = 5
                    THEN  ISNULL(I.IdInstalacionPemex,'300085036') 
                END ,
                  ah.ID_CATACTHC,
				  CASE
                    WHEN @IdActividad = 4
                    THEN SUBSTRING(ISNULL(I.NombreInstalacion, 'AREA CONTRACTUAL AMATITLAN'),0,10)
                    WHEN @IdActividad = 5
                    THEN '0'
                END 
         ORDER BY ID_TIPOSER ASC;
     END;

