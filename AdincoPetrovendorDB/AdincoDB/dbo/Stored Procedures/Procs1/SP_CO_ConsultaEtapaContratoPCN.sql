-- =============================================
-- Author:		Marcos Garcia
-- Create date: 07-02-2020
-- Description:	Consulta Todos los Tipos de Programa
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaEtapaContratoPCN]
-- Add the parameters for the stored procedure here
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT PPP.IdPCNPorPeriodo, 
               CONCAT(PPP.IdPCNPorPeriodo, ' - ', SUBSTRING(TPA.TipoPrograma, 6, 50), ' - ', C.NumeroContrato) AS EtapaContrato
        FROM dbo.CO_PCNPorPeriodos PPP
             LEFT JOIN dbo.CO_Contrato C ON PPP.IdContrato = C.IdContrato
             LEFT JOIN dbo.CO_TipoProgramaActividad TPA ON PPP.IdTipoPgrogramaActividad = TPA.IdTipoProgramaActividad
        ORDER BY c.IdContrato DESC, 
                 PPP.IdTipoPgrogramaActividad ASC;
    END;
