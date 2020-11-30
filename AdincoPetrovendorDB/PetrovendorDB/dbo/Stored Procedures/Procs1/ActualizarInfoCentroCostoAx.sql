CREATE PROCEDURE ActualizarInfoCentroCostoAx
@IdProveedor INT,
@IdCentroCostoAx NVARCHAR(MAX),
@CentroCosto NVARCHAR(MAX),
@IdUsuario INT,
@IdCentroCosto INT
AS
BEGIN

	UPDATE c
	SET c.CentroCosto = @CentroCosto
	FROM dbo.AX_CENTROCOSTO ax INNER JOIN dbo.CC_CentroCosto c ON ax.IdCentroCostoPetrov = c.IdCentroCosto
	WHERE c.IdProveedor = @IdProveedor AND ax.IdCentroCostoAx = @IdCentroCostoAx AND c.IdCentroCosto = @IdCentroCosto

	
	INSERT INTO dbo.AX_HistoricoCentroCosto (IdCentroCostoAx, CentroCosto, FechaModificado, UsuarioModifico)
	SELECT @IdCentroCostoAx, @CentroCosto, GETDATE(), @IdUsuario

  
END







