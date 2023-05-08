-- =============================================
-- Author:		Marcos Garcia
-- Create date: 02-01-2020
-- Description:	Actualiza Mes de Presentacion de 
--				un Gasto a el Requerido por el
--				Cliente asi como inserta en una 
--				tabla para el historico del cambio 
--				de mes
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ActualizarMesGasto] 
-- Add the parameters for the stored procedure here
@IdRegistro      INT, 
@FechaAntigua    DATE, 
@MesPresentacion DATE, 
@IdContrato      INT, 
@IdUsuario       INT
AS
     BEGIN
         SET NOCOUNT ON;
		 --============================
         INSERT INTO dbo.CO_ActMesGasto
         (IdRegistro, 
          AnteriorMesPresentacion, 
          NuevoMesPresentacion, 
          FechaModificacion, 
          ModificadoPor
         )
         VALUES
         (@IdRegistro,  
          @FechaAntigua, 
          @MesPresentacion, 
          GETDATE(), 
          @IdUsuario   
         );
		 --============================
         UPDATE dbo.CO_Registro
           SET 
               MesPresentacion = @MesPresentacion
         WHERE IdRegistro = @IdRegistro;
		 --============================
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;