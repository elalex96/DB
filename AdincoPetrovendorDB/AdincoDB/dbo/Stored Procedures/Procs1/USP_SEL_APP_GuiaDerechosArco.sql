IF EXISTS
    (
        SELECT
            1
        FROM
            dbo.sysobjects
        WHERE
            name = 'USP_SEL_APP_GuiaDerechosArco'
    )
    DROP PROCEDURE USP_SEL_APP_GuiaDerechosArco;
GO
-- =============================================  
-- Author: Reyna Olvera
-- Create date:   20250618
-- Description:  
-- =============================================  
CREATE PROCEDURE [dbo].[USP_SEL_APP_GuiaDerechosArco]
AS 
  BEGIN 
      SET NOCOUNT ON; 

	SELECT  DerechosArco FROM APP_GuiaDerechosArco (NOLOCK) WHERE ACTIVO=1

  END; 
