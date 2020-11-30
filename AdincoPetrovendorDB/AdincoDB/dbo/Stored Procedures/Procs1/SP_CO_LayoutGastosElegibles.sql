-- =============================================
-- Author:		Manuel CD
-- Create date: 19-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_LayoutGastosElegibles]
	-- Add the parameters for the stored procedure here
@IdPresupuesto INT,
@IdActividad   INT,
@Anio          INT,
@Mes			INT
AS
--SP_CO_LayoutGastosElegibles 1,2016,10000
--SP_CO_LayoutGastosElegibles 5,2016,10000
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @Etiqueta1 NVARCHAR(50);
         SELECT @Etiqueta1 = 'ID_ADMON'
         WHERE @IdActividad = 1;
         SELECT @Etiqueta1 = 'ID_DUCTO'
         WHERE @IdActividad = 2;
         SELECT @Etiqueta1 = 'ID_ESTUDIO'
         WHERE @IdActividad = 3;
         SELECT @Etiqueta1 = 'ID_INSTALA'
         WHERE @IdActividad = 4;
         SELECT @Etiqueta1 = 'ID_POZO'
         WHERE @IdActividad = 5;
    -- Insert statements for procedure here

         SELECT AC.ID_CATACTIV AS ID_CATACTIV,
                SA.ID_CATSUBACTIV AS ID_CATSUBACTIV,
                YEAR(LPM.AC_FEC_FIN) AS PR_ANO,
                P.Version AS PR_VERSION,
                 @Mes AS AC_MES,
                'Datos para la etiqueta1' AS Actividad,
                '' AS GE_NO_COMPROBANTE,
                '' AS GE_MONTO,
                '' AS GE_REF_DOCUMENTO,
                '' AS GE_PROVEEDOR,
                '' AS GE_DESCRIPCION,
                '' AS GE_MES,
                @Etiqueta1 AS Etiqueta1
         FROM CO_LineaPresupuestoMes LPM
              LEFT JOIN CO_Presupuesto P ON P.IdPresupuesto = LPM.IdPresupuesto
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
               AND YEAR(R.MesPresentacion) = @Anio;
     END;

