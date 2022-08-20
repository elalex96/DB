USE ADINCO;
GO
-- =============================================
-- Author:      Miguel Gomez
-- Create date: 2017-01-01
-- Description: Consulta Registro de Gasto para Edicion
-- =============================================
-- Author Alter: Neri Garcia
-- Create date: 2021-08-31
-- Description: Se agrega campo IdCatManoObra
-- =============================================
-- Author Alter: Reyna Olvera
-- Create date: 2021-10-01
-- Description: Se retorna el PorcentajeMarkup
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	10 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK y la llamada de columnas con nombre especifico de la tabla durante su llamado y ajustes de lefts.
-- =============================================
-- Author Alter: Reyna Olvera
-- Create date: 17/08/2022
-- Description: Se agrega campo RegistroConAjuste y AsociadoIncrementoPMT
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaRegistroGastoEdicion]
    @IdRegistro INT = 0,
    @IdContrato INT = 0,
    @IdUsuario INT = 0
AS
BEGIN
    SET NOCOUNT ON;
    --
    CREATE TABLE #TableRegistroGastoEdicion
    (
        IdRegistro INT,
        IdPrograma INT,
        IdFactura INT,
        MontoRegistro DECIMAL(18, 4),
        InicioEjecucion DATE,
        FinEjecucion DATE,
        Comentarios VARCHAR(5000),
        MesPresentacion DATE,
        IdEstado INT,
        IdUsuarioCreadoPor INT,
        IdUsuarioModPor INT,
        FecMovto DATETIME,
        IdInstalacion INT,
        CreadoPor INT,
        Fila INT,
        IdPedimentoComprobante INT,
        CvTipoDocFacturacion INT,
        IdCatalogoCuentasSH INT,
        Poliza VARCHAR(50),
        IdPresupuesto INT,
        IdPeriodo INT,
        IdLineaPresupuestoMes INT,
        IdGastoRubro TINYINT,
        IdCatManoObra INT,
        SoloLectura BIT,
        PCN FLOAT,
        CAA BIT,
        InstalacionName INT,
        CapexOpexEdicion INT,
        Operacion BIT,
        PorcentajeMarkup FLOAT,
        FechaFactura DATETIME,
        IdContrato INT,
		RegistroConAjuste BIT  NULL,  
		AsociadoIncrementoPMT BIT  NULL
    )

    INSERT INTO #TableRegistroGastoEdicion
    (
        IdRegistro,
        IdPrograma,
        IdFactura,
        MontoRegistro,
        InicioEjecucion,
        FinEjecucion,
        Comentarios,
        MesPresentacion,
        IdEstado,
        IdUsuarioCreadoPor,
        IdUsuarioModPor,
        FecMovto,
        IdInstalacion,
        CreadoPor,
        Fila,
        IdPedimentoComprobante,
        CvTipoDocFacturacion,
        IdCatalogoCuentasSH,
        Poliza,
        IdPresupuesto,
        IdPeriodo,
        IdLineaPresupuestoMes,
        IdGastoRubro,
        IdCatManoObra,
        SoloLectura,
        PCN,
        CAA,
        InstalacionName,
        CapexOpexEdicion,
        PorcentajeMarkup,
        FechaFactura,
        IdContrato,
		RegistroConAjuste,  
		AsociadoIncrementoPMT
    )
    SELECT CO_Registro.IdRegistro,
           CO_Registro.IdPrograma,
           CO_Registro.IdFactura,
           CO_Registro.MontoRegistro,
           CO_Registro.InicioEjecucion,
           CO_Registro.FinEjecucion,
           CO_Registro.Comentarios,
           CO_Registro.MesPresentacion,
           CO_Registro.IdEstado,
           CO_Registro.IdUsuarioCreadoPor,
           CO_Registro.IdUsuarioModPor,
           CO_Registro.FecMovto,
           CO_Registro.IdInstalacion,
           CO_Registro.CreadoPor,
           CO_Registro.Fila,
           CO_Registro.IdPedimentoComprobante,
           CO_Registro.CvTipoDocFacturacion,
           CO_Registro.IdCatalogoCuentasSH,
           ISNULL(CO_Registro.Poliza, 0),
           CO_LineaPresupuestoMes.IdPresupuesto,
           CO_PeriodoContrato.IdPeriodo,
           CO_LineaPresupuestoMes.IdLineaPresupuestoMes,
           ISNULL(CO_Registro.IdGastoRubro, 0),
           ISNULL(CO_Registro.IdCatManoObra, 0),
           NULL,
           ISNULL(CO_Registro.PCN, 0),
           ISNULL(CO_Registro.CostosAtribuiblesAdministracion, 0),
           NULL,
           CO_Registro.CapexOpexEdicion,
           NULL,
           NULL,
           CO_PeriodoContrato.IdContrato,
		   ISNULL(CO_Registro.RegistroConAjuste,0),  
		   ISNULL(CO_Registro.AsociadoIncrementoPMT,0)
    FROM CO_Registro (NOLOCK)
        INNER JOIN CO_LineaPresupuestoMes (NOLOCK)
            ON CO_Registro.IdRegistro = @IdRegistro
               AND CO_Registro.IdPrograma = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
               AND CO_Registro.IdRegistro = @IdRegistro
        INNER JOIN CO_Presupuesto (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
        INNER JOIN CO_ProgramaActividad (NOLOCK)
            ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
        INNER JOIN CO_PeriodoContrato (NOLOCK)
            ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo


    UPDATE #TableRegistroGastoEdicion
    SET #TableRegistroGastoEdicion.FechaFactura = FI_Factura.Fecha
    FROM #TableRegistroGastoEdicion
        JOIN FI_Factura
            ON #TableRegistroGastoEdicion.IdFactura = FI_Factura.IdFactura

    UPDATE #TableRegistroGastoEdicion
    SET #TableRegistroGastoEdicion.SoloLectura = CAST(ISNULL(CO_EstadoRegistroContrato.SoloLectura, 0) AS BIT)
    FROM #TableRegistroGastoEdicion
        JOIN CO_EstadoRegistroContrato
            ON #TableRegistroGastoEdicion.IdEstado = CO_EstadoRegistroContrato.IdEstadoRegistro
               AND #TableRegistroGastoEdicion.IdContrato = CO_EstadoRegistroContrato.IdContrato

    UPDATE #TableRegistroGastoEdicion
    SET #TableRegistroGastoEdicion.InstalacionName = CO_Instalacion.IdInstalacion
    FROM #TableRegistroGastoEdicion
        JOIN CO_Instalacion
            ON #TableRegistroGastoEdicion.IdInstalacion = CO_Instalacion.IdInstalacion

    UPDATE #TableRegistroGastoEdicion
    SET #TableRegistroGastoEdicion.CapexOpexEdicion = CASE
                                                          WHEN #TableRegistroGastoEdicion.CapexOpexEdicion IS NOT NULL THEN
                                                              CASE
                                                                  WHEN #TableRegistroGastoEdicion.CapexOpexEdicion = 1 THEN
                                                                      1
                                                                  ELSE
                                                                      2
                                                              END
                                                          ELSE
                                                              CASE
                                                                  WHEN ISNULL(CO_CatalogoCuentaSH.Operacion, 0) = 1 THEN
                                                                      1
                                                                  ELSE
                                                                      2
                                                              END
                                                      END
    FROM #TableRegistroGastoEdicion
        JOIN CO_CatalogoCuentaSH
            ON #TableRegistroGastoEdicion.IdCatalogoCuentasSH = CO_CatalogoCuentaSH.IdCatalogoCuentasSH

    UPDATE #TableRegistroGastoEdicion
    SET #TableRegistroGastoEdicion.PorcentajeMarkup = ISNULL(CO_RegistroMarkup.Porcentaje, 0)
    FROM #TableRegistroGastoEdicion
        JOIN CO_RegistroMarkup
            ON #TableRegistroGastoEdicion.IdRegistro = CO_RegistroMarkup.GastoId;

    SELECT IdRegistro,
           IdPrograma,
           IdFactura,
           MontoRegistro,
           InicioEjecucion,
           FinEjecucion,
           Comentarios,
           MesPresentacion,
           IdEstado,
           IdUsuarioCreadoPor,
           IdUsuarioModPor,
           FecMovto,
           IdInstalacion,
           CreadoPor,
           Fila,
           IdPedimentoComprobante,
           CvTipoDocFacturacion,
           IdCatalogoCuentasSH,
           Poliza,
           IdPresupuesto,
           IdPeriodo,
           IdLineaPresupuestoMes,
           IdGastoRubro,
           IdCatManoObra,
           ISNULL(SoloLectura, 0),
           PCN,
           CAA,
           InstalacionName,
           CapexOpexEdicion,
           PorcentajeMarkup,
           FechaFactura,
		   RegistroConAjuste,  
		   AsociadoIncrementoPMT
    FROM #TableRegistroGastoEdicion
END;


