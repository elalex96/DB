-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Guarda Procesos
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 21/06/2022
-- Description:	Agregado del campo de la etapa
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_GuardaProcesos] --10045,10061,'Manifiesto de impacto ambiental','Manifiesto de impacto ambiental',0
    @idContrato INT,
    @idUsuario INT,
    @NombreProceso VARCHAR(1000),
    --@DescripcionProceso NVARCHAR(300)
    @Descripcion VARCHAR(3000),
    @idTipoProceso INT,
    @IdInstalacion INT,
    --@IdContratoCb INT
    @IsProcesoEvento INT,
	@isSerie int,
	@EtapaPozoId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @count     INT,
            @count1    INT,
            @count2    INT,
            @Error     NVARCHAR(MAX),
            @IdProceso INT,
            @IdRonda   INT;

    SELECT @IdRonda = IdRonda
      FROM dbo.CO_Contrato
     WHERE IdContrato = @idContrato;
    IF (@IdInstalacion = 0 OR @IdInstalacion IS NULL)
    BEGIN
        SET @IdInstalacion = NULL;
        SELECT @count = COUNT(*)
          FROM EN_Procesos P
          JOIN EN_ProcesosContrato PC
            ON P.IdProceso   = PC.idProceso
           AND PC.idContrato = @idContrato
         WHERE NombreProceso LIKE '%' + @NombreProceso + '%'
           AND PC.idContrato = @idContrato;
    END;
    ELSE
    BEGIN
        SELECT @count = COUNT(*)
          FROM EN_Procesos P
          JOIN EN_ProcesosContrato PC
            ON P.IdProceso   = PC.idProceso
           AND PC.idContrato = @idContrato
         WHERE NombreProceso LIKE '%' + @NombreProceso + '%'
           AND PC.idContrato   = @idContrato
           AND P.IdInstalacion = @IdInstalacion;
    END;
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
                                         idTipoProceso,
                                         IdInstalacion,
                                         IsProcesoEvento,
										 IsSerie,
										 EtapaPozoId)
            VALUES (@NombreProceso, -- NombreProceso - nvarchar(150)
                    @Descripcion, -- Descripcion - nvarchar(500)
                    @idUsuario, -- CreadoPor - int
                    GETDATE(), -- CreadoEl - datetime
                    @idUsuario, -- ModificadoPor - int
                    GETDATE(), -- ModificadoEl - datetime
                    1, -- Activo - bit
                    @idTipoProceso, @IdInstalacion, @IsProcesoEvento,@IsSerie,@EtapaPozoId);

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
        END;
        ELSE
        BEGIN
            SET @Error = N'El contrato no tiene una ronda asignada';
            SELECT @Error;
        END;
    END;
    ELSE
    BEGIN
        SET @Error = N'Ya existe un proceso con ese nombre';
        SELECT @Error;
    END;

END;
