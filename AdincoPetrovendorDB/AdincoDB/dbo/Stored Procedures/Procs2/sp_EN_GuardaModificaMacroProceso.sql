-- =============================================
-- Author:  	Reyna Olvera
-- Create date: 20181023
-- Description:	Guarda Macro-Procesos
-- =============================================
CREATE PROCEDURE [dbo].[sp_EN_GuardaModificaMacroProceso] --3,10061,'hola','hi'
@idContrato int,
@idUsuario int,
@NombreProceso varchar(max),
@Descripcion varchar(max),
--@IdInstalacion int,
@idMacroProceso int
AS
BEGIN
  DECLARE @error varchar(max)--, @nombreInstalacionAnterior varchar(max);
  IF (@idMacroProceso = 0)
  BEGIN

    INSERT INTO dbo.EN_Procesos (NombreProceso,
    Descripcion,
    CreadoPor,
    CreadoEl,
    Activo,
    idTipoProceso,
    IsProcesoEvento
    --,IdInstalacion
	)
      VALUES (@NombreProceso, -- NombreProceso - nvarchar(150)
      @Descripcion, -- Descripcion - nvarchar(500)
      @idUsuario, -- CreadoPor - int
      GETDATE(), -- CreadoEl - datetime
      1, -- Activo - bit
      10001, 
	  1--, CASE @IdInstalacion WHEN 0 THEN NULL ELSE @IdInstalacion END
	  );

    SET @error = LTRIM(@@IDENTITY);

    INSERT INTO EN_ProcesosContrato (idContrato,
    idProceso,
    CreadoPor,
    CreadoEn,
    Activo)
      VALUES (@idContrato, @@IDENTITY, @idUsuario, GETDATE(), 1);
  END
  ELSE
  BEGIN

    UPDATE EN_Procesos
    SET NombreProceso = @NombreProceso,
        Descripcion = @Descripcion
    WHERE IdProceso = @idMacroProceso

    SET @error = LTRIM(@idMacroProceso)
  END
  SELECT
    @error AS error;
END