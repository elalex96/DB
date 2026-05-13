-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_FrecuenciasPorRegulador] 
	-- Add the parameters for the stored procedure here
@IdRegulador INT = 0,
@IdContrato  INT = 0,
@IdUsuario   INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
         IF @IdRegulador <> 5
	    begin
             SELECT DISTINCT
                    EN_FrecuenciaEntregable.IdFrecuenciaEntregable,
                    EN_FrecuenciaEntregable.FrecuenciaEntregable
             FROM EN_FrecuenciaEntregable
                  INNER JOIN EN_Entregable ON EN_FrecuenciaEntregable.IdFrecuenciaEntregable = EN_Entregable.IdFrecuenciaEntregable
             WHERE(EN_Entregable.IdRegulador = @IdRegulador);
		   end
		   else
		   begin
		    SELECT DISTINCT
                    EN_FrecuenciaEntregable.IdFrecuenciaEntregable,
                    EN_FrecuenciaEntregable.FrecuenciaEntregable
             FROM EN_FrecuenciaEntregable
		   where IdFrecuenciaEntregable= 10014
		   end
     END;
