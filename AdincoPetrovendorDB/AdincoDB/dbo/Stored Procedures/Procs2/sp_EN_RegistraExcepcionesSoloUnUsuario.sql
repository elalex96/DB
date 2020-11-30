-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019
-- Description:Crea excepciones para los responsables de una instancia
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_RegistraExcepcionesSoloUnUsuario]--3,10061,59072,10001,10090,10086
    @idContrato                  INT,
    @idUsuario                   INT,
    @idInstanciaentregable       INT,
    @idUsuarioNuevo              INT
AS
    BEGIN

        DECLARE
            @IdContratoEntregable INT,
			@error VARCHAR(max)='';

        SELECT
            @IdContratoEntregable = 
			IdContratoEntregable
        FROM
            dbo.EN_InstanciasEntregable
        WHERE
            idInstanciaEntregable = @idInstanciaentregable;
      
		DELETE FROM EN_ExcepcionesActividad WHERE IdInstanciasEntregables=@idInstanciaentregable

        INSERT INTO dbo.EN_ExcepcionesActividad
            (
                ActividadIDExcepcion,
                EstadoID,
                idUsuario,
                IdInstanciasEntregables,
                CreadoPor,
                CreadoEn,
                ModificadoPor,
                ModificadoEn,
                Activo
            )
          Select ActividadID,EstadoID,@idUsuarioNuevo,@idInstanciaentregable,@idUsuario,GETDATE(),@idUsuario,GETDATE(),1 from EN_Actividad where IdContratoEntregable=@IdContratoEntregable;

		   IF @@ERROR <> 0 
			BEGIN 
				SELECT @error =  Cast(@@ERROR AS NVARCHAR(8)); 
			END 

			SELECT  @error AS error
			
    END;
	