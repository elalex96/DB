
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_FI_ConsultaContratistaSubcontratista'
)
    DROP PROCEDURE SP_FI_ConsultaContratistaSubcontratista
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 24/05/2017
-- Description:	Obtiene la razon social del subcontratista
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ConsultaContratistaSubcontratista] 
@IdContratista INT
AS
     BEGIN

         SET NOCOUNT ON;

         SELECT DISTINCT 
                S.IdSubcontratista, 
                UPPER(S.RazonSocial) AS RazonSocial, 
                S.RFC
         FROM PV_Subcontratista AS S (NOLOCK)
         WHERE S.RazonSocial <> ''
               AND S.RazonSocial <> '-'
               AND S.RFC IS NOT NULL
               AND S.RFC <> '-'
               AND S.RFC <> ''
               AND S.IsEliminado = 0
               AND S.IsActivo = 1
         ORDER BY UPPER(S.RazonSocial);
     END;