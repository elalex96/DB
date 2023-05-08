
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 10 Noviembre 2014
-- Description:	Presupuestos
-- =============================================
CREATE PROCEDURE [dbo].[CO_SP_ConsultaLineaPresupuestoMes] 
-- Add the parameters for the stored procedure here
@presupuesto INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         SET LANGUAGE spanish; 
         -- Insert statements for procedure here

         SELECT dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
                CONCAT(RIGHT('00'+CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(month, dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES), ' ', YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES)) AS Mes_Presupuestado,
                --CO_Area.NombreArea AS Area,
                --CO_TipoServicio.ID_TIPOSER,
                --CO_ActividadPetroleraCNH.id_Actividad AS ID_TIPOSER,
                --CO_TipoServicio.NombreTipoServicio AS CO_TipoServicio,
                --CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS CO_TipoServicio,
                --CO_ActividadCIEP.ID_CATACTIV,

                CO_SubactividadPetrolera.[id_Sub-actividad] AS ID_CATACTIV,
                --CO_ActividadCIEP.NombreActividad AS Actividad,

                CO_SubactividadPetrolera.SubactividadPetrolera AS Actividad,


                --CO_SubactividadCIEP.ID_CATSUBACTIV,


                CO_TareaPetrolera.id_Tarea AS ID_CATSUBACTIV,

                --CO_RubroInterno.NombreRubro AS SubActividad,


                CO_TareaPetrolera.TareaPetrolera AS SubActividad
                --CO_ClasificacionAnexo4.ClasificacionAnexo4 AS Anexo4,
                --dbo.CO_LineaPresupuestoMes.ID_PADRE,
                --CO_Servicio.NombreServicio AS Servicio,
                --CO_Instalacion.NombreInstalacion AS Instalacion,
                --CO_Instalacion.IdInstalacionPemex AS ID_PEMEX,
                --dbo.CO_LineaPresupuestoMes.Monto AS [Presupuesto (USD)],
                ----SUM(CASE
                --        WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                --        THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                --        ELSE 0
                --    END) AS [Registrado (USD)],
                --dbo.CO_LineaPresupuestoMes.Monto - SUM(CASE
                --                                           WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                --                                           THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                --                                           ELSE 0
                --                                       END) AS [Saldo (USD)],
                --SUM(CASE
                --        WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                --        THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                --        ELSE 0
                --    END) / dbo.CO_LineaPresupuestoMes.Monto * 100 AS Porcentaje,
                --SUM(CASE
                --        WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                --        THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                --        ELSE 0
                --    END) / dbo.CO_LineaPresupuestoMes.Monto * 100 AS Progreso100,
                --CASE
                --    WHEN((SUM(CASE
                --                  WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                --                  THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                --                  ELSE 0
                --              END) / monto) * 100) > 100
                --    THEN((SUM(CASE
                --                  WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0
                --                  THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio
                --                  ELSE 0
                --              END) / monto) * 100) - 100
                --    ELSE 0
                --END AS ProgresoM100,


			 --    SUM(
--        CASE WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio ELSE 0 END
--    ) AS [Registrado (USD)], 
                --0 AS [Registrado (USD)], 
--    dbo.CO_LineaPresupuestoMes.Monto - SUM(
--        CASE WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio ELSE 0 END
--    ) AS [Saldo (USD)], 
                --0 AS [Saldo (USD)], 
--    SUM(
--        CASE WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio ELSE 0 END
--    ) / dbo.CO_LineaPresupuestoMes.Monto * 100 
                --0 AS Porcentaje, 
--    SUM(
--        CASE WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio ELSE 0 END
--    ) / dbo.CO_LineaPresupuestoMes.Monto * 100 
                --0 AS Progreso100, 
--    CASE WHEN (
--        (
--            SUM(
--                CASE WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio ELSE 0 END
--            ) / monto
--        ) * 100
--    ) > 100 THEN (
--        (
--            SUM(
--                CASE WHEN ISNULL(CO_Registro.MontoRegistro, 0) <> 0 THEN ISNULL(CO_Registro.MontoRegistro, 0) / CO_TipoCambioMensual.TipoCambio ELSE 0 END
--            ) / monto
--        ) * 100
--    ) -100 ELSE 0 END 
                --0 AS ProgresoM100,
                --dbo.CO_LineaPresupuestoMes.IdExcel AS ID,
                --CO_ActividadPetroleraCNH.id_Actividad,
                --CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
                --CO_SubactividadPetrolera.[id_Sub-actividad],
                --CO_SubactividadPetrolera.SubactividadPetrolera,
                --CO_TareaPetrolera.id_Tarea,
                --CO_TareaPetrolera.TareaPetrolera
         FROM dbo.CO_LineaPresupuestoMes
              LEFT OUTER JOIN CO_ActividadPetroleraCNH ON dbo.CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
              LEFT OUTER JOIN CO_SubactividadPetrolera ON dbo.CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
              LEFT OUTER JOIN CO_TareaPetrolera ON dbo.CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
              LEFT OUTER JOIN CO_ActividadCIEP ON dbo.CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
              LEFT OUTER JOIN CO_TipoServicio ON dbo.CO_LineaPresupuestoMes.IdTipoServicio = CO_TipoServicio.ID_TIPOSER
              LEFT OUTER JOIN CO_SubactividadCIEP ON dbo.CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
              LEFT OUTER JOIN CO_Servicio ON dbo.CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
              LEFT OUTER JOIN CO_Area ON dbo.CO_LineaPresupuestoMes.IdArea = CO_Area.IdArea
              LEFT OUTER JOIN CO_Instalacion ON dbo.CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
              LEFT OUTER JOIN CO_Registro ON dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
              LEFT OUTER JOIN CO_ClasificacionAnexo4 ON dbo.CO_LineaPresupuestoMes.IdAnexo4 = CO_ClasificacionAnexo4.IdAnexo4
              LEFT OUTER JOIN FI_Factura ON FI_Factura.IdFactura = CO_Registro.IdFactura
              LEFT OUTER JOIN CO_TipoCambioMensual ON CO_TipoCambioMensual.IdMoneda = FI_Factura.IdMoneda
                                                      AND CO_TipoCambioMensual.IdMes = MONTH(CO_Registro.MesPresentacion)
                                                      AND CO_TipoCambioMensual.Anio = YEAR(CO_Registro.MesPresentacion)
              LEFT OUTER JOIN CO_RubroInterno ON dbo.CO_LineaPresupuestoMes.IdRubroInterno = CO_RubroInterno.IdRubroInterno
         WHERE(dbo.CO_LineaPresupuestoMes.IdPresupuesto = @presupuesto) --and MONTH ( CO_LineaPresupuestoMes.AC_FEC_INI ) = @mes 
         GROUP BY dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
                  dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES,
                  CO_Area.NombreArea,
                  CO_TipoServicio.ID_TIPOSER,
                  CO_TipoServicio.NombreTipoServicio,
                  CO_ActividadCIEP.ID_CATACTIV,
                  CO_ActividadCIEP.NombreActividad,
                  CO_SubactividadCIEP.ID_CATSUBACTIV,
                  CO_SubactividadCIEP.NombreSubactividad,
                  dbo.CO_LineaPresupuestoMes.ID_PADRE,
                  CO_ClasificacionAnexo4.ClasificacionAnexo4,
                  CO_Servicio.NombreServicio,
                  CO_Instalacion.NombreInstalacion,
                  CO_Instalacion.IdInstalacionPemex,
                  dbo.CO_LineaPresupuestoMes.Monto,
                  dbo.CO_LineaPresupuestoMes.IdExcel,
                  CO_RubroInterno.NombreRubro,
                  CO_ActividadPetroleraCNH.id_Actividad,
                  CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
                  CO_SubactividadPetrolera.[id_Sub-actividad],
                  CO_SubactividadPetrolera.SubactividadPetrolera,
                  CO_TareaPetrolera.id_Tarea,
                  CO_TareaPetrolera.TareaPetrolera
         ORDER BY Mes_Presupuestado,
                  dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES
				  --,Area
     END

