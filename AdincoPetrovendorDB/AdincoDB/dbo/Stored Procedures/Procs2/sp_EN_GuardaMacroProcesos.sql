-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Guarda Macro-Procesos
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_GuardaMacroProcesos] --3,10061,'MacroprocesoCalculo','MacroprocesoCalculo',10001,1
    @idContrato INT,
    @idUsuario INT,
    @NombreProceso NVARCHAR(150),
    @Descripcion NVARCHAR(300),
    @idTipoProceso INT,
	@IsProcesoEvento INT,
	@IsMacroprocesoCalculo INT
AS
BEGIN

    SET NOCOUNT ON;
    DECLARE @count INT,@Error NVARCHAR(MAX), @idProceso INT, @IdRonda   INT;

IF(@IsMacroprocesoCalculo=0)BEGIN SET @idTipoProceso=10001 END ELSE BEGIN SET @idTipoProceso=10002 END

    SELECT @count = COUNT(*)
      FROM EN_Procesos P
	    JOIN EN_ProcesosContrato PC
            ON P.IdProceso   = PC.idProceso
           AND PC.idContrato = @idContrato
         WHERE NombreProceso = @NombreProceso
           AND PC.idContrato   = @idContrato
		   AND idTipoProceso = @idTipoProceso;

	SELECT @IdRonda = IdRonda
      FROM dbo.CO_Contrato
     WHERE IdContrato = @idContrato;

    IF (@count = 0)
    BEGIN
	 IF (@IdRonda IS NOT NULL)
        BEGIN
        INSERT INTO dbo.EN_Procesos (NombreProceso,
                                     Descripcion,
                                     CreadoPor,
                                     CreadoEl,
                                     ModificadoPor,
                                     ModificadoEl,
                                     Activo,
                                     idTipoProceso,IsProcesoEvento)
        VALUES (@NombreProceso, -- NombreProceso - nvarchar(150)
                @Descripcion, -- Descripcion - nvarchar(500)
                @idUsuario, -- CreadoPor - int
                GETDATE(), -- CreadoEl - datetime
                NULL, -- ModificadoPor - int
                NULL, -- ModificadoEl - datetime
                1, -- Activo - bit
                @idTipoProceso,@IsProcesoEvento);

		SELECT @IdProceso = @@IDENTITY; --El que acaba de insertar

        INSERT INTO EN_ProcesosContrato (idContrato,
                                         idProceso,
                                         CreadoPor,
                                         CreadoEn,
                                         ModificadoPor,
                                         ModificadoEn,
                                         Activo)
        VALUES (@idContrato, @IdProceso, @idUsuario, GETDATE(), @idUsuario, GETDATE(), 1);

		INSERT INTO dbo.EN_ProcesosRondas (IdProceso,
                                               IdRonda,
                                               CreadoPor,
                                               CreadoEl,
                                               ModificadoPor,
											   ModificadoEl,
                                               Activo)
            VALUES (@IdProceso, -- IdProceso - int
                    @IdRonda, -- IdRonda - int
                    @idUsuario, -- CreadoPor - int
                    GETDATE(), -- CreadoEl - datetime
					@idUsuario, -- ModificadoPor - int
                    GETDATE(), -- ModificadoEl - datetime
                    1 -- Activo - bit
                );
		END
		ELSE
        BEGIN
            SET @Error = N'El contrato no tiene una ronda asignada';
            SELECT @Error;
        END;
    END;
    ELSE
    BEGIN
        SET @Error = 'Ya existe un Macroproceso con ese nombre';
        SELECT @Error;
    END;


END;

