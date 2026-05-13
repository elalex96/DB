-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-09-24
-- Description:	
-- =============================================
-- Modificado Por:	Neri del Angel
-- Create date:		04 de Abril del 2022
-- Description:		Se agrega filtrado de todos
--					los presupuestos del periodo
--					seleccionado
-- =============================================
CREATE PROCEDURE [dbo].[SP_SE_A1]
    @IdContrato INT,
    @IdUsuario INT,
    @IdPresupuesto INT,
    @FInicio DATE,
    @FFin DATE,
    @IdPeriodo INT,
    @Etapa VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @IdTipoProgramaActividad INT;
    SELECT TOP 1
        @IdTipoProgramaActividad = IdTipoProgramaActividad
    FROM CO_TipoProgramaActividad
    WHERE TipoPrograma LIKE '%' + @Etapa + '%';
    /*Obtencion de los Datos*/
    SELECT DISTINCT
        C.NumeroContrato,
        CAST(@FInicio AS DATE) AS Inicio,
        CAST(@FFin AS DATE) AS Fin,
        PPA.PCNMinimo AS PCNC,
        1 AS DuracionEtapa,
        UPPER(CONCAT(CC.Representante, ', ', CC.PuestoRepresentante, ', ', CC.RazonSocial)) AS Firma
    FROM dbo.CO_Registro R (NOLOCK)
        JOIN dbo.CO_LineaPresupuestoMes L (NOLOCK)
            ON R.IdPrograma = L.IdLineaPresupuestoMes
        JOIN dbo.CO_Presupuesto P (NOLOCK)
            ON L.IdPresupuesto = P.IdPresupuesto
        JOIN dbo.CO_ProgramaActividad PA (NOLOCK)
            ON P.IdProgramaActividad = PA.IdProgramaActividad
        JOIN dbo.CO_TipoProgramaActividad TPA (NOLOCK)
            ON TPA.IdTipoProgramaActividad = @IdTipoProgramaActividad
               AND PA.IdTipoProgramaActividad = TPA.IdTipoProgramaActividad
        LEFT JOIN dbo.CO_PCNPorPeriodos PPP (NOLOCK)
            ON TPA.IdTipoProgramaActividad = PPP.IdTipoPgrogramaActividad
        LEFT JOIN dbo.CO_PCNPeriodosPorAnios PPA (NOLOCK)
            ON PPP.IdPCNPorPeriodo = PPA.IdPCNPorPeriodo
        LEFT JOIN dbo.CO_Contrato C (NOLOCK)
            ON PPP.IdContrato = C.IdContrato
        LEFT JOIN dbo.CO_Contratista CC (NOLOCK)
            ON C.IdContratista = CC.IdContratista
    WHERE C.IdContrato = @IdContrato
          AND PPA.Anio = YEAR(@FInicio)
END;
