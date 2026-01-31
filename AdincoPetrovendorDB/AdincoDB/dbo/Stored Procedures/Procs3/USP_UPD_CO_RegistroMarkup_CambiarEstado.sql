use adinco
go
IF EXISTS (
		SELECT 1
		FROM dbo.sysobjects
		WHERE name = 'USP_UPD_CO_RegistroMarkup_CambiarEstado'
		)
	DROP PROCEDURE USP_UPD_CO_RegistroMarkup_CambiarEstado;
GO
CREATE PROCEDURE dbo.USP_UPD_CO_RegistroMarkup_CambiarEstado
  @IdUsuario INT,
  @IdContrato INT,
  @GastoId INT,
  @IdEstadoDestino INT,
  @Justificacion NVARCHAR(500)
AS
BEGIN
  SET NOCOUNT ON;

  DECLARE @IdEstadoOrigen INT;

  SELECT @IdEstadoOrigen = IdEstadoPemex
  FROM CO_RegistroMarkup
  WHERE GastoId = @GastoId;

  IF @IdEstadoOrigen IS NULL
  BEGIN
    RAISERROR('El gasto no tiene estado actual.', 16, 1);
    RETURN;
  END

  INSERT INTO dbo.CO_RegistroMarkup_Bitacora
  (
      IdContrato,
      GastoId,
      IdEstadoOrigen,
      IdEstadoDestino,
      Justificacion,
      UsuarioId,
      FechaMovimiento
  )
  VALUES
  (
      @IdContrato,
      @GastoId,
      @IdEstadoOrigen,
      @IdEstadoDestino,
      @Justificacion,
      @IdUsuario,
      GETDATE()
  );


  UPDATE CO_RegistroMarkup
  SET IdEstadoPemex = @IdEstadoDestino,
      ModificadoPor = @IdUsuario,
      ModificadoEn = GETDATE()
  WHERE GastoId = @GastoId;
END
GO
