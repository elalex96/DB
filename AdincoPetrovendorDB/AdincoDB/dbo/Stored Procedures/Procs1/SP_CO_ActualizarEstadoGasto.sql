-- =============================================
-- Author:		Marcos Neri
-- Create date: 10-01-2020
-- Description:	* Inserta Historico de Cambio de Estado en CO_ActMesGasto 
--				* Modifica el Estado en el Registro del Gasto
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ActualizarEstadoGasto] 
-- Add the parameters for the stored procedure here
@IdRegistro       INT, 
@IdEstadoAnterior INT, 
@IdEstadoNuevo    INT, 
@IdContrato       INT, 
@IdUsuario        INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
		 -- ============================
         INSERT INTO dbo.CO_ActMesGasto
         (IdRegistro, 
          FechaModificacion, 
          ModificadoPor, 
          IdEstadoAnterior, 
          IdEstadoNuevo
         )
         VALUES
         (@IdRegistro, 
          GETDATE(), 
          @IdUsuario, 
          @IdEstadoAnterior, 
          @IdEstadoNuevo
         );
		 -- ============================
         UPDATE dbo.CO_Registro
           SET 
               IdEstado = @IdEstadoNuevo
         WHERE IdRegistro = @IdRegistro;
		 --============================
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;