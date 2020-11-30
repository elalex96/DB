-- =============================================
-- Author:      Miguel Gomez
-- Create date: 2017-01-01
-- Description: Consulta Registro de Gasto para Edicion
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaRegistroGastoEdicion]
    -- Add the parameters for the stored procedure here
    @IdRegistro INT = 0,
    @IdContrato INT = 0,
    @IdUsuario INT = 0
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from-- interfering with SELECT statements.
  
  SET NOCOUNT ON;
    -- Insert statements for procedure here
    SELECT reg.IdRegistro,
           reg.IdPrograma,
           reg.IdFactura,
           reg.MontoRegistro,
           reg.InicioEjecucion,
           reg.FinEjecucion,
           reg.Comentarios,
           reg.MesPresentacion,
           reg.IdEstado,
           reg.IdUsuarioCreadoPor,
           reg.IdUsuarioModPor,
           reg.FecMovto,
           reg.IdInstalacion,
           reg.CreadoPor,
           reg.Fila,
           reg.IdPedimentoComprobante,
           reg.CvTipoDocFacturacion,
           reg.IdCatalogoCuentasSH,
           Poliza = ISNULL(reg.Poliza, 0),
           lp.IdPresupuesto,
           pc.IdPeriodo,
           lp.IdLineaPresupuestoMes,
           IdGastoRubro = ISNULL(reg.IdGastoRubro, 0),
           SoloLectura = CAST(ISNULL(erc.SoloLectura, 0) AS BIT),
           ISNULL(reg.PCN,0) AS PCN,
           ISNULL(reg.CostosAtribuiblesAdministracion,0) AS CAA,
           --reg.IdCuenta,
           C.IdInstalacion AS InstalacionName
    FROM CO_Registro reg (NOLOCK)
        INNER JOIN CO_LineaPresupuestoMes lp	(NOLOCK)
            ON lp.IdLineaPresupuestoMes = reg.IdPrograma
			AND reg.IdRegistro = @IdRegistro
        INNER JOIN CO_Presupuesto p	(NOLOCK)
            ON p.IdPresupuesto = lp.IdPresupuesto
        INNER JOIN CO_ProgramaActividad pa	(NOLOCK)
            ON pa.IdProgramaActividad = p.IdProgramaActividad
        INNER JOIN CO_PeriodoContrato pc	(NOLOCK)
            ON pc.IdPeriodo = pa.IdPeriodoContrato
        LEFT JOIN [CO_EstadoRegistroContrato] erc	(NOLOCK)
            ON erc.IdEstadoRegistro = reg.IdEstado
               AND erc.IdContrato = pc.IdContrato
        LEFT JOIN
            CO_Instalacion  C	(NOLOCK)
            ON REG.IdInstalacion    =   C.IdInstalacion
    WHERE (IdRegistro = @IdRegistro);
END;
