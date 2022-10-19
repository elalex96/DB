-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ReporteLayoutProgramaACDESC_V2] 
@IdPresupuesto INT          = 0,
@Anio          NVARCHAR(10),
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
                S.NombreServicio AS [AC_NOMBRE],
				S.NombreServicio AS [AC_DESCRIPCION],
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_INI), MONTH(LP.AC_FEC_INI), DAY(LP.AC_FEC_INI))), 103) AS [AC_FEC_INI], --CONCAT('01/', RIGHT('00'+CONVERT( NVARCHAR(2), MONTH(LP.AC_FEC_FIN)), 2), '/', YEAR(LP.AC_FEC_FIN)) AS [AC_FEC_INI],
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_FIN), MONTH(LP.AC_FEC_FIN), DAY(LP.AC_FEC_FIN))), 103) AS [AC_FEC_FIN], --CONCAT(DATEPART(d, EOMONTH(CAST(CONCAT(YEAR(LP.AC_FEC_FIN), RIGHT('00'+CONVERT( NVARCHAR(2), MONTH(LP.AC_FEC_FIN)), 2), '01') AS DATE))), '/', RIGHT('00'+CONVERT(NVARCHAR(2), MONTH(LP.AC_FEC_FIN)), 2), '/', YEAR(LP.AC_FEC_FIN)) AS [AC_FEC_FIN],
                'S' AS [AC_TERMINADO],
                ISNULL(I.IdInstalacionPemex, 0) AS [ID_INSTALACION],
                1 AS [ID_CATACTHC],
                @Label AS Etiqueta,
				@Etiqueta2 AS Etiqueta2,
				CASE
                    WHEN @IdActividad = 4
                    THEN ISNULL(I.IdInstalacionPemex, 0)
                    WHEN @IdActividad = 5
                    THEN '0'
                END AS Columna
         FROM CO_LineaPresupuestoMes LP
              LEFT JOIN CO_Servicio S ON LP.idServicio = S.IdServicio
              LEFT JOIN CO_SubactividadCIEP SA ON LP.IdSubactividad = SA.IdSubactividad
              LEFT JOIN CO_Instalacion I ON LP.IdInstalacion = I.IdInstalacion
              LEFT JOIN CO_ActividadCIEP AC ON LP.IdActividad = AC.IdActividad
              LEFT JOIN CO_TipoServicio TS ON TS.IdTipoServicio = LP.IdTipoServicio
              LEFT JOIN CO_ActividadHidrocarburoCIEP AH ON ah.IdActividadHidrocarburo = LP.IdActvidadHidrocarburo
         WHERE LP.IdPresupuesto = @IdPresupuesto
               AND AC.ID_CATACTIV = @IdActividad
               AND YEAR(LP.AC_FEC_INI) = YEAR(@Anio)
         GROUP BY AC.ID_CATACTIV,
                  SA.ID_CATSUBACTIV,
                  ID_TIPOSER,
                  S.NombreServicio,
                  SA.NombreSubactividad,
                  LP.AC_FEC_INI,
                  LP.AC_FEC_FIN,
                  I.IdInstalacionPemex,
                  ah.ID_CATACTHC
         ORDER BY ID_TIPOSER ASC;
     END;