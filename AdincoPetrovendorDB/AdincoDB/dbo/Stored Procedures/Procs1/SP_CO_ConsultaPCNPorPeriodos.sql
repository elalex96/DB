-- =============================================
-- Author:		Marcos Garcia
-- Create date: 2020-02-10
-- Description:	Consulta Todos las PCN por Periodos 
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaPCNPorPeriodos]
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT PCN.IdPCNPorPeriodo, 
               SUBSTRING(TPA.TipoPrograma, 6, 50) AS Etapa, 
               C.NumeroContrato, 
               PCN.Anios, 
               PCN.AnioInicio, 
               PCN.PCNPorPeriodoMin, 
               PCN.PCNPorPeriodoMax, 
               AC.Nombre AS CreadoPor, 
               CONVERT(DATE, PCN.CreadoEn) AS CreadoEn, 
               AM.Nombre AS ModificadoPor, 
               CONVERT(DATE, PCN.ModificadoEn) AS ModificadoEn, 
               PCN.IdContrato, 
               PCN.IdTipoPgrogramaActividad
        FROM dbo.CO_PCNPorPeriodos PCN
             JOIN dbo.CO_Contrato C ON PCN.IdContrato = C.IdContrato
             JOIN dbo.CO_TipoProgramaActividad TPA ON PCN.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
             LEFT JOIN dbo.AP_Usuario AC ON PCN.CreadoPor = AC.UsuarioID
             LEFT JOIN dbo.AP_Usuario AM ON PCN.ModificadoPor = AM.UsuarioID
        GROUP BY SUBSTRING(TPA.TipoPrograma, 6, 50), 
                 CONVERT(DATE, PCN.CreadoEn), 
                 CONVERT(DATE, PCN.ModificadoEn), 
                 PCN.IdPCNPorPeriodo, 
                 C.NumeroContrato, 
                 PCN.Anios, 
                 PCN.AnioInicio, 
                 PCN.PCNPorPeriodoMin, 
                 PCN.PCNPorPeriodoMax, 
                 AC.Nombre, 
                 AM.Nombre, 
                 PCN.IdContrato, 
                 PCN.IdTipoPgrogramaActividad
        ORDER BY PCN.IdPCNPorPeriodo DESC;
    END;