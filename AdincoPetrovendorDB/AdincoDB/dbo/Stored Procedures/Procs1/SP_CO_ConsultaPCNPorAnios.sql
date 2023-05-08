-- =============================================
-- Author:		Marcos Garcia
-- Create date: 2020-02-10
-- Description:	Consulta los PCN Minimos Por Años
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaPCNPorAnios] 
--[SP_CO_ConsultaPCNPorAnios] 0,0
-- Add the parameters for the stored procedure here
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT PCNA.IdPCNPeriodosPorAnios, 
                PCNA.IdPCNPorPeriodo, 
                SUBSTRING(TPA.TipoPrograma, 6, 50) AS Etapa, 
                C.NumeroContrato, 
                PCNA.Anio, 
                PCNA.PCNMinimo, 
                Ac.Nombre AS CreadoPor, 
                CONVERT(DATE, PCNA.CreadoEn) AS CreadoEn, 
                AM.Nombre AS ModificadoPor, 
                CONVERT(DATE, PCNA.ModificadoEl) AS ModificadoEl, 
                C.IdContrato, 
                TPA.IdTipoProgramaActividad
         FROM dbo.CO_PCNPeriodosPorAnios PCNA
              JOIN dbo.CO_PCNPorPeriodos PCN ON PCNA.IdPCNPorPeriodo = PCN.IdPCNPorPeriodo
              JOIN dbo.CO_Contrato C ON PCN.IdContrato = C.IdContrato
              JOIN dbo.CO_TipoProgramaActividad TPA ON PCN.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
              LEFT JOIN dbo.AP_Usuario AC ON PCNA.CreadoPor = AC.UsuarioID
              LEFT JOIN dbo.AP_Usuario AM ON PCNA.ModificadoPor = AM.UsuarioID
        GROUP BY SUBSTRING(TPA.TipoPrograma, 6, 50),
                 CONVERT(DATE, PCNA.CreadoEn),
                 CONVERT(DATE, PCNA.ModificadoEl),
                 PCNA.IdPCNPeriodosPorAnios,
                 PCNA.IdPCNPorPeriodo,
                 C.NumeroContrato,
                 PCNA.Anio,
                 PCNA.PCNMinimo,
                 AC.Nombre,
                 AM.Nombre,
                 C.IdContrato,
                 TPA.IdTipoProgramaActividad
         ORDER BY PCNA.IdPCNPeriodosPorAnios DESC;
     END;