-- =============================================
-- Author:		Manuel CD
-- Create date: 31-10-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_PC_ContratoCampos] 
	-- Add the parameters for the stored procedure here
@IdContrato INT,
@IdUsuario  INT
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here

             SELECT CC.IdContratoCampo,
                    CC.IdCampo,
                    C.CvCampo,
                    C.DescripcionCampo
             FROM PC_ContratoCampo AS CC
                  INNER JOIN PC_Campo AS C ON CC.IdCampo = C.IdCampo
             WHERE CC.IdContrato = @IdContrato;
         END;