-- =============================================
-- Author:		Reyna Olvera
-- Create date: 2019
-- Description:Crea excepciones para los responsables de una instancia
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_RegistraExcepciones]--3,10061,59072,10001,10090,10086
    @idContrato                  INT,
    @idUsuario                   INT,
    @idInstanciaentregable       INT,
    @EstadoID                    INT,
    @idUsuarioNuevo              INT,
    @idUsuarioContratoEntregable INT --Definido en la configuración
AS
    BEGIN

        DECLARE
            @IdContratoEntregable INT,
            @ActividadID          INT=0;

        SELECT
            @IdContratoEntregable = IdContratoEntregable
        FROM
            dbo.EN_InstanciasEntregable
        WHERE
            idInstanciaEntregable = @idInstanciaentregable;
        ------------------------------------------------------------------------------
        --Revisores
        IF (@idUsuarioContratoEntregable <> 0)
            BEGIN
                SELECT
                    @ActividadID = ISNULL(ActividadID,0)
                FROM
                    dbo.EN_Actividad
                WHERE
                    idUsuario = @idUsuarioContratoEntregable
                    AND IdContratoEntregable = @IdContratoEntregable
                    AND EstadoID = @EstadoID;
			IF (@ActividadID = 0)
            BEGIN
                SELECT
                    @ActividadID = ISNULL(ActividadIDExcepcion,1)
                FROM
                    dbo.EN_ExcepcionesActividad
                WHERE
                    IdInstanciasEntregables = @idInstanciaentregable
                    AND EstadoID = @EstadoID AND idUsuario=@idUsuarioContratoEntregable;
            END;
            END;
        ELSE
            BEGIN
                SELECT
                    @ActividadID = ActividadID
                FROM
                    dbo.EN_Actividad
                WHERE
                    IdContratoEntregable = @IdContratoEntregable
                    AND EstadoID = @EstadoID;
            END;

        ------------------------------------------------------------------------------
        

		DELETE FROM EN_ExcepcionesActividad WHERE IdInstanciasEntregables=@idInstanciaentregable AND EstadoID=@EstadoID 
		 AND ActividadIDExcepcion=@ActividadID

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
        VALUES
            (
                @ActividadID,           -- ActividadID - int
                @EstadoID,              -- EstadoID - int
                @idUsuarioNuevo,        -- idUsuario - int
                @idInstanciaentregable, -- IdInstanciasEntregables - int
                @idUsuario,             -- CreadoPor - int
                GETDATE(),              -- CreadoEn - datetime
                @idUsuario,             -- ModificadoPor - int
                GETDATE(),              -- ModificadoEn - datetime
                1                       -- Activo - bit
            );

			SELECT '' AS error 
    END;
	--truncate table EN_ExcepcionesActividad
	--Select * from  EN_ExcepcionesActividad where IdInstanciasEntregables=59072 59094
	--SELECT * FROM dbo.EN_Estado
	--11345	10001	10068	59072	10061	2019-04-29 21:42:55.933	10061	2019-04-29 21:42:55.933	1
	