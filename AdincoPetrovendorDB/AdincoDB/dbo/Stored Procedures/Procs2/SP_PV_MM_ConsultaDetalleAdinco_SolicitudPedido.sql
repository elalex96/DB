-- =============================================
-- Author:		Daniel AC
-- Create date: 08-08-17
-- Description: Obtener información relacionada con solicitud de pedido
-- =============================================
create PROCEDURE [dbo].[SP_PV_MM_ConsultaDetalleAdinco_SolicitudPedido]
	-- Add the parameters for the stored procedure here
	@IdContrato int, 
	@IdPeriodo int, 
	@IdPresupuesto int,
	@IdLineaPresupuesto int
	 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	---ADINCO_DESARROLLO.dbo.PV_Subcontratista ADINCO
	DECLARE @CONTRATO NVARCHAR(max)
	DECLARE @PRESUPUESTO NVARCHAR(max)
	DECLARE @PERIODO NVARCHAR(max)
	DECLARE @LINEAPRESUPUESTO NVARCHAR(max)
	SET LANGUAGE spanish; 
	 
	 SET @PERIODO  =(SELECT Top 1 NombrePeriodo  as NombreParaMostrar
    FROM         Adinco.dbo.CO_PeriodoContrato 
    WHERE        (IdContrato = @IdContrato AND IdPeriodo=@IdPeriodo))

 
		SET @PRESUPUESTO  = (SELECT ISNULL((SELECT Top 1 CONCAT(CO_Presupuesto.Nombre, ' [', CO_Presupuesto.IdPresupuestoCNH, ']')AS Nombre
                
         FROM CO_ProgramaActividad
              INNER JOIN CO_PeriodoContrato ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
              INNER JOIN CO_Presupuesto ON CO_ProgramaActividad.IdProgramaActividad = CO_Presupuesto.IdProgramaActividad
         WHERE(CO_PeriodoContrato.IdPeriodo = @IdPeriodo AND CO_Presupuesto.IdPresupuesto =@IdPresupuesto )
              AND (CO_Presupuesto.Activo = 1)),'No disponible') AS Presupuesto);
		
       SET @LINEAPRESUPUESTO =  (SELECT ISNULL(( SELECT Top 1
                CONCAT(RIGHT('00'+CAST(MONTH(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES) AS VARCHAR(2)), 2), ' ', DATENAME(month, dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES), ' ', YEAR(dbo.CO_LineaPresupuestoMes.AC_PRESUP_MES), ' - ', CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, '(',CO_SubactividadPetrolera.SubactividadPetrolera,')') AS Mes_Presupuestado
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
         WHERE(dbo.CO_LineaPresupuestoMes.IdPresupuesto =@IdPresupuesto ) AND  dbo.CO_LineaPresupuestoMes.IdLineaPresupuestoMes=@IdLineaPresupuesto ),'No Disponible') AS LINEA_PRESUPUESTO)




	  SELECT ISNULL(@PERIODO, 'NoDisponible') AS Periodo,@PRESUPUESTO AS Presupuesto,@LINEAPRESUPUESTO AS LineaPresupuesto
	
END


