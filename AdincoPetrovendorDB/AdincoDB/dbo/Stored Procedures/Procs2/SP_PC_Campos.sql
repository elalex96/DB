-- =============================================
-- Author:		Manuel CD
-- Create date: 01-11-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_Campos] 
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             SELECT C.IdCampo,
                    C.CvCampo,
                    C.DescripcionCampo
             FROM PC_Campo AS C
                  LEFT OUTER JOIN PC_ContratoCampo AS CC ON C.IdCampo = CC.IdCampo
             WHERE CC.IdCampo IS NULL;
	        
	    /*WHERE NOT EXISTS
         (
             SELECT *
             FROM PC_ContratoCampo CC
             WHERE C.IdCampo = CC.IdCampo AND C.IdCampo IS NULL
         );*/

         END;