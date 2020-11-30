-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ReporteLayoutProgramaACDESC_V2] 
-- Add the parameters for the stored procedure here
@IdPresupuesto INT          = 0,
@Anio          NVARCHAR(10),
@IdActividad   INT          = 0
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @Label NVARCHAR(50);
         SELECT @Label = 'ID_ADMON'
         WHERE @IdActividad = 1;
         SELECT @Label = 'ID_DUCTO'
         WHERE @IdActividad = 2;
         SELECT @Label = 'ID_ESTUDIO'
         WHERE @IdActividad = 3;
         SELECT @Label = 'ID_INSTALA'
         WHERE @IdActividad = 4;
         SELECT @Label = 'ID_POZO'
         WHERE @IdActividad = 5;
         SELECT @Label = ''
         WHERE @IdActividad = 6;

	    --select @Label
         -- Insert statements for procedure here

         SELECT AC.ID_CATACTIV AS [ID_CATACTIV],
                SA.ID_CATSUBACTIV AS [ID Subatividad],
                ID_TIPOSER AS [ID_TIPOSER],
                ROUND(SUM(LP.Monto), 2) AS [AC_PRESUP_MES],
                --I.NombreInstalacion AS [AC_NOMBRE],
                S.NombreServicio AS [AC_NOMBRE],
                SA.NombreSubactividad AS [AC_DESCRIPCION],
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_INI), MONTH(LP.AC_FEC_INI), DAY(LP.AC_FEC_INI))), 103) AS [AC_FEC_INI], --CONCAT('01/', RIGHT('00'+CONVERT( NVARCHAR(2), MONTH(LP.AC_FEC_FIN)), 2), '/', YEAR(LP.AC_FEC_FIN)) AS [AC_FEC_INI],
                CONVERT(CHAR(10), (DATEFROMPARTS(YEAR(LP.AC_FEC_FIN), MONTH(LP.AC_FEC_FIN), DAY(LP.AC_FEC_FIN))), 103) AS [AC_FEC_FIN], --CONCAT(DATEPART(d, EOMONTH(CAST(CONCAT(YEAR(LP.AC_FEC_FIN), RIGHT('00'+CONVERT( NVARCHAR(2), MONTH(LP.AC_FEC_FIN)), 2), '01') AS DATE))), '/', RIGHT('00'+CONVERT(NVARCHAR(2), MONTH(LP.AC_FEC_FIN)), 2), '/', YEAR(LP.AC_FEC_FIN)) AS [AC_FEC_FIN],
                'N' AS [AC_TERMINADO],
                ISNULL(I.IdInstalacionPemex, 0) AS [ID_INSTALACION],
                AH.ID_CATACTHC AS [ID_CATACTHC],
                @Label AS Etiqueta
         FROM CO_LineaPresupuestoMes LP
              LEFT JOIN CO_Servicio S ON LP.idServicio = S.IdServicio
              LEFT JOIN CO_SubactividadCIEP SA ON LP.IdSubactividad = SA.IdSubactividad
              LEFT JOIN CO_Instalacion I ON LP.IdInstalacion = I.IdInstalacion
              LEFT JOIN CO_ActividadCIEP AC ON LP.IdActividad = AC.IdActividad
              LEFT JOIN CO_TipoServicio TS ON TS.IdTipoServicio = LP.IdTipoServicio
              LEFT JOIN CO_ActividadHidrocarburoCIEP AH ON ah.IdActividadHidrocarburo = LP.IdActvidadHidrocarburo
		    --LEFT JOIN CO_Presupuesto P ON P.IdPresupuesto = LP.IdPresupuesto
		    --LEFT JOIN CO_AnioContractual ANC ON P.IdAnioContractual = ANC.IdAnioContractual
         WHERE LP.IdPresupuesto = @IdPresupuesto
               AND AC.ID_CATACTIV = @IdActividad
               AND YEAR(LP.AC_FEC_INI) = YEAR(@Anio)
	    --AND ANC.Inicio = @Anio
         GROUP BY AC.ID_CATACTIV,
                  SA.ID_CATSUBACTIV,
                  ID_TIPOSER,
                  --I.NombreInstalacion,
                  S.NombreServicio,
                  SA.NombreSubactividad,
                  LP.AC_FEC_INI,
                  LP.AC_FEC_FIN,
                  I.IdInstalacionPemex,
                  ah.ID_CATACTHC
         ORDER BY ID_TIPOSER ASC;

	    --sp_CO_ReporteLayoutProgramaACDESC_V2 10037,'2015',1
	    --sp_CO_ReporteLayoutProgramaACDESC_V2 10000,'2015',1
	    --sp_CO_ReporteLayoutProgramaACDESC_V2 10000,'2015',5
	    --sp_CO_ReporteLayoutProgramaACDESC_V2 10000,'2016',1
     END;