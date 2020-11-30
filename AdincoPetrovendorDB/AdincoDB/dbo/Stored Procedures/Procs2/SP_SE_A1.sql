-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-09-24
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_SE_A1] 
-- [SP_SE_A1] 10018,1,10079,'2019-01-01','2019-12-01'
-- [SP_SE_A1] 3,10113,0,'2018-04-01','2020-02-01'
-- Add the parameters for the stored procedure here
@IdContrato    INT, 
@IdUsuario     INT, 
@IdPresupuesto INT, 
@FInicio       DATE, 
@FFin          DATE
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         SELECT DISTINCT 
                C.NumeroContrato, 
                CAST(@FInicio AS DATE) AS Inicio, 
                CAST(@FFin AS DATE) AS Fin, 
                PPA.PCNMinimo AS PCNC, 
                1 AS DuracionEtapa,
                UPPER(CONCAT(CC.Representante, ', ', CC.PuestoRepresentante, ', ', CC.RazonSocial)) AS Firma
         FROM dbo.CO_Registro R
              JOIN dbo.CO_LineaPresupuestoMes L ON R.IdPrograma = L.IdLineaPresupuestoMes
              JOIN dbo.CO_Presupuesto P ON L.IdPresupuesto = P.IdPresupuesto
              JOIN dbo.CO_ProgramaActividad PA ON P.IdProgramaActividad = PA.IdProgramaActividad
              JOIN dbo.CO_TipoProgramaActividad TPA ON PA.IdTipoProgramaActividad = TPA.IdTipoProgramaActividad
              LEFT JOIN dbo.CO_PCNPorPeriodos PPP ON TPA.IdTipoProgramaActividad = PPP.IdTipoPgrogramaActividad
              LEFT JOIN dbo.CO_PCNPeriodosPorAnios PPA ON PPP.IdPCNPorPeriodo = PPA.IdPCNPorPeriodo
              LEFT JOIN dbo.CO_Contrato C ON PPP.IdContrato = C.IdContrato
              LEFT JOIN dbo.CO_Contratista CC ON C.IdContratista = CC.IdContratista
         WHERE C.IdContrato = @IdContrato 
		 AND  PPA.Anio = YEAR(@FInicio)
         --AND P.IdPresupuesto = @IdPresupuesto;
     END;