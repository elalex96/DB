-- =============================================
-- Author:		Manuel CD
-- Create date: 19-10-17
-- Description:	
-- =============================================
-- Modificador:	Neri del Angel
-- Fecha:		19 de Octubre del 2022
-- Descripción:	Se agregan no lock faltantes, se ajusta la consulta a lo deseado
--				Se respeta que el filtrado de mes y año sea por el mes presentación del gasto (CO_registro)
--				Los campos GE_NO_COMPROBANTE, GE_MONTO, GE_PROVEEDOR y GE_DESCRIPCION se obtienen de vista GastosAmatitlan2020
--				EL campo de Actividad [ID_ADMON] se obtiene de CO_Instalacion.IdInstalacionPemex
--				El campo GE_REF_DOCUMENTO se queda en blanco, el campo GE_MES se obtiene del mes en que aprobó Pemex CO_RegistroMarkup.MesEstadoPemex
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_LayoutGastosElegibles]
    @IdPresupuesto INT,
    @IdActividad INT,
    @Anio INT,
    @Mes INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Contrato INT;
    /**/
    SELECT TOP 1
        @Contrato = CO_PeriodoContrato.IdContrato
    FROM CO_Presupuesto (NOLOCK)
        JOIN CO_ProgramaActividad (NOLOCK)
            ON CO_Presupuesto.IdProgramaActividad = CO_ProgramaActividad.IdProgramaActividad
        JOIN CO_PeriodoContrato (NOLOCK)
            ON CO_ProgramaActividad.IdPeriodoContrato = CO_PeriodoContrato.IdPeriodo
    WHERE CO_Presupuesto.IdPresupuesto = @IdPresupuesto
    /**/
    SELECT CO_ActividadCIEP.ID_CATACTIV AS ID_CATACTIV,
           CO_SubactividadCIEP.ID_CATSUBACTIV AS ID_CATSUBACTIV,
           YEAR(CO_LineaPresupuestoMes.AC_FEC_FIN) AS PR_ANO,
           ISNULL(CO_Presupuesto.Version, 1) AS PR_VERSION,
           @Mes AS AC_MES,
           ISNULL(CO_Instalacion.IdInstalacionPemex, '') AS Actividad,
           ISNULL(GastosAmatitlan2020.Numero, '') AS GE_NO_COMPROBANTE,
           ISNULL(GastosAmatitlan2020.MontoUSDConMarkup, 0.00) AS GE_MONTO,
           '' AS GE_REF_DOCUMENTO,
           ISNULL(GastosAmatitlan2020.Subcontratista, '') AS GE_PROVEEDOR,
           ISNULL(GastosAmatitlan2020.Comentarios, '') AS GE_DESCRIPCION,
           ISNULL(MONTH(CO_RegistroMarkup.MesEstadoPemex), '') AS GE_MES,
           CASE
               WHEN @IdActividad = 1 THEN
                   'ID_ADMON'
               WHEN @IdActividad = 2 THEN
                   'ID_DUCTO'
               WHEN @IdActividad = 3 THEN
                   'ID_ESTUDIO'
               WHEN @IdActividad = 4 THEN
                   'ID_INSTALA'
               WHEN @IdActividad = 5 THEN
                   'ID_POZO'
               ELSE
                   ''
           END AS Etiqueta1
    FROM CO_LineaPresupuestoMes (NOLOCK)
        JOIN CO_Instalacion
            ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
        JOIN CO_Presupuesto (NOLOCK)
            ON CO_LineaPresupuestoMes.IdPresupuesto = CO_Presupuesto.IdPresupuesto
               AND CO_Presupuesto.IdPresupuesto = @IdPresupuesto
        JOIN CO_Registro (NOLOCK)
            ON CO_LineaPresupuestoMes.IdLineaPresupuestoMes = CO_Registro.IdPrograma
               AND CO_Registro.IdRegistro IS NOT NULL
               AND MONTH(CO_Registro.MesPresentacion) = @Mes
               AND YEAR(CO_Registro.MesPresentacion) = @Anio
        JOIN CO_RegistroMarkup (NOLOCK)
            ON CO_Registro.IdRegistro = CO_RegistroMarkup.GastoId
        JOIN CO_EstadoRegistro_V2 (NOLOCK)
            ON ISNULL(CO_RegistroMarkup.IdEstadoPemex, 0) = CO_EstadoRegistro_V2.IdClvEstado
               AND CO_EstadoRegistro_V2.NombreEstado = 'Certificado GE Aprobado CACI'
               AND CO_EstadoRegistro_V2.IdContrato = @Contrato
        JOIN GastosAmatitlan2020 (NOLOCK)
            ON CO_Registro.IdRegistro = GastosAmatitlan2020.IdRegistro
        JOIN CO_ActividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IdActividad = CO_ActividadCIEP.IdActividad
               AND CO_ActividadCIEP.ID_CATACTIV = @IdActividad
        LEFT JOIN CO_SubactividadCIEP (NOLOCK)
            ON CO_LineaPresupuestoMes.IdSubactividad = CO_SubactividadCIEP.IdSubactividad
    WHERE CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto
          AND CO_ActividadCIEP.ID_CATACTIV = @IdActividad
          AND MONTH(CO_Registro.MesPresentacion) = @Mes
          AND YEAR(CO_Registro.MesPresentacion) = @Anio;
END;