-- =============================================
-- Author:		Manuel Cruz
-- Create date: 20-04-2018
-- Description:	
-- =============================================
CREATE PROCEDURE SP_CO_ActualizarMesPresentacion 
	-- Add the parameters for the stored procedure here
@IdContrato      INT,
@IdUsuario       INT,
@MesPresentacion DATE
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             UPDATE dbo.CO_Contrato
               SET
                   MesPresentacionCGI = @MesPresentacion
             WHERE IdContrato = @IdContrato;
             IF @@ERROR <> 0
                 SELECT 'false' AS msj;
                 ELSE
             SELECT 'true' AS msj;
         END;
