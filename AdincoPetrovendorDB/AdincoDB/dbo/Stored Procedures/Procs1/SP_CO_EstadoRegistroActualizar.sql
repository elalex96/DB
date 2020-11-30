-- =============================================
-- Author:		Manuel CD
-- Create date: 27-09-17
-- Description:	
-- =============================================
CREATE PROCEDURE SP_CO_EstadoRegistroActualizar 
	-- Add the parameters for the stored procedure here
@IdRegistro INT,
@IdEstado   INT,
@IdUsuario  INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
         SET NOCOUNT ON;

    -- Insert statements for procedure here
         UPDATE CO_Registro
           SET
               IdEstado = @IdEstado,
               IdUsuarioModPor = @IdUsuario
         WHERE IdRegistro = @IdRegistro;

	    --
         IF @@ERROR <> 0
             SELECT 'false' AS msj
             ELSE
         SELECT 'true' AS msj
     END

