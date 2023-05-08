-- =============================================
-- Author:		Marcos Garcia
-- Create date: 07-02-2020
-- Description:	Consulta Todos los Tipos de Programa
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultaTipProgActividaAdminPCN]
-- Add the parameters for the stored procedure here
@IdContrato INT = 0, 
@IdUsuario  INT = 0
AS
    BEGIN
        SET NOCOUNT ON;
        SELECT IdTipoProgramaActividad AS IdEtapa, 
               SUBSTRING(TipoPrograma, 6, 50) AS TipoPrograma
        FROM dbo.CO_TipoProgramaActividad;
    END;
