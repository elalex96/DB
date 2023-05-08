-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_PV_ExisteSubcontratista] 
-- Add the parameters for the stored procedure here
@RFC NVARCHAR(MAX)
AS
     DECLARE @ENCONTRADOS AS INT;
     DECLARE @RFCReplace AS NVARCHAR(MAX);
     BEGIN
         -- =============================================
         SET @RFCReplace =
         (
             SELECT REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@RFC, '!', ''), '#', ''), '$', ''), ' ', ''), '-', ''), '_', ''), '.', '')
         );
         -- =============================================
         SELECT @ENCONTRADOS = COUNT(*)
         FROM PV_Subcontratista S
         WHERE UPPER(RTRIM(S.RFC)) = UPPER(RTRIM(@RFCReplace))
               AND S.IsActivo = 1;
         -- =============================================
         IF(@ENCONTRADOS > 0)
             SELECT TOP 1 IdSubcontratista, 
                          RazonSocial
             FROM PV_Subcontratista S
             WHERE UPPER(RTRIM(S.RFC)) = UPPER(RTRIM(@RFCReplace))
                   AND S.IsActivo = 1
             ORDER BY S.IdSubcontratista ASC;
             ELSE
         SELECT 0 AS IdSubcontratista, 
                'NO EXISTE' AS RazonSocial;
     END;