-- =============================================
-- Author:		Manuel CD
-- Create date: 28-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_LayoutInformeDeAvance]
	-- Add the parameters for the stored procedure here
@IdPresupuesto INT,
@IdActividad   INT,
@Anio          INT

AS
--SP_CO_LayoutReporteGastosElegiblesPorActividadMes_2 1,02,2016,10000
--SP_CO_LayoutReporteGastosElegiblesPorActividadMes_2 5,02,2016,10000
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         --DECLARE @IdActividad INT= 1;
         DECLARE @Etiqueta1 NVARCHAR(50);
         DECLARE @Etiqueta2 NVARCHAR(50);
         SELECT @Etiqueta1 = 'ID_ADMON'           WHERE @IdActividad = 1;
         SELECT @Etiqueta1 = 'ID_DUCTO'           WHERE @IdActividad = 2;
         SELECT @Etiqueta1 = 'ID_ESTUDIO'         WHERE @IdActividad = 3;
         SELECT @Etiqueta1 = 'ID_INSTALA'         WHERE @IdActividad = 4;
         SELECT @Etiqueta1 = 'ID_POZO'            WHERE @IdActividad = 5;
         SELECT @Etiqueta1 = '-'			     WHERE @IdActividad = 6;
         SELECT @Etiqueta2 = 'AC_UNIDAD_INSTALA'  WHERE @IdActividad = 4;
         SELECT @Etiqueta2 = 'AC_PRODUCCION_POZO' WHERE @IdActividad = 5;
    -- Insert statements for procedure here

         SELECT AC.ID_CATACTIV AS ID_CATACTIV,
                SA.ID_CATSUBACTIV AS ID_CATSUBACTIV,
                LPM.IdTipoServicio AS ID_TIPOSER,
                SUM(CASE 
				    WHEN CONVERT(MONEY, ISNULL(R.MontoRegistro ,0))<>0
				    THEN CONVERT(MONEY, ISNULL(R.MontoRegistro,0))/CONVERT(MONEY, TCM.TipoCambio)    
				ELSE 0 END) AS AC_PRESUP_MES,
                AC.NombreActividad AS AC_NOMBRE,
                SA.NombreSubactividad AS AC_DESCRIPCION,
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LPM.AC_FEC_INI), MONTH(LPM.AC_FEC_INI), DAY(LPM.AC_FEC_INI))), 103) AS AC_FEC_INI,
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LPM.AC_FEC_FIN), MONTH(LPM.AC_FEC_FIN), DAY(LPM.AC_FEC_FIN))), 103) AS AC_FEC_FIN,
                CONVERT(INT,LPM.AC_TERMINADO) AS AC_TERMINADO,
			 ISNULL(I.IdInstalacionPemex, 0) AS [ID_INSTALACION],
                @Etiqueta1 AS Etiqueta1,
                1 AS ID_CATACTHC,
                LPM.ID_PADRE AS ID_ACTIVIDAD_P,
                @Etiqueta2 AS Etiqueta2,
			 CASE
                    WHEN @IdActividad = 4
                    THEN ISNULL(I.IdInstalacionPemex, 0)
                    WHEN @IdActividad = 5
                    THEN '0'
                END AS Columna
         FROM CO_LineaPresupuestoMes LPM
              LEFT JOIN CO_Servicio S ON LPM.IdServicio = S.IdServicio
              LEFT JOIN CO_ActividadCIEP AC ON LPM.IdActividad = AC.IdActividad
              LEFT JOIN CO_Instalacion I ON LPM.IdInstalacion = I.IdInstalacion
              LEFT JOIN CO_Registro R ON LPM.IdLineaPresupuestoMes = R.IdPrograma
              LEFT JOIN CO_SubactividadCIEP SA ON LPM.IdSubactividad = SA.IdSubactividad
              LEFT JOIN FI_Factura F ON R.IdFactura = F.IdFactura
              LEFT JOIN CO_TipoCambioMensual TCM ON F.IdMoneda = TCM.IdMoneda
                                                    AND TCM.IdMes = MONTH(R.MesPresentacion)
                                                    AND TCM.Anio = YEAR(R.MesPresentacion)
         WHERE LPM.IdPresupuesto = @IdPresupuesto
               AND AC.ID_CATACTIV = @IdActividad
               AND YEAR(R.MesPresentacion) = @Anio

         GROUP BY AC.ID_CATACTIV,
			SA.ID_CATSUBACTIV,
			LPM.IdTipoServicio,
			AC.NombreActividad,
			SA.NombreSubactividad,
               LPM.AC_FEC_INI,
               LPM.AC_FEC_FIN,
			LPM.AC_TERMINADO,
			LPM.ID_PADRE,
			I.IdInstalacionPemex
         ORDER BY AC.ID_CATACTIV,
                  SA.ID_CATSUBACTIV
     END;
