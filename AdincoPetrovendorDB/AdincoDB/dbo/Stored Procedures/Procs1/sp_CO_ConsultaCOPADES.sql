-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaCOPADES] 
	-- Add the parameters for the stored procedure here
@IdContrato INT = 0,
@IdUsuario  INT,
@IdCopade int = 0
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here

         SELECT IdCopade,
                IdContrato,
                NumeroCOPADE,
                FechaEmision,
                Archivo,
				Adjunto
         FROM CO_COPADE
         WHERE(IdContrato = @IdContrato) and
		 @IdCopade in (0,IdCopade)
         ORDER BY NumeroCOPADE;
     END;
