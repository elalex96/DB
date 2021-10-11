DROP PROCEDURE IF EXISTS WDEA_SP_InsertaCentroCostos
GO
CREATE PROCEDURE WDEA_SP_InsertaCentroCostos
@IdCentroCosto int,
@AcronimoSAP varchar(200),
@WBS_Element varchar(200) = NULL,
@IdUsuario Int = NULL,
@IdContrato Int = NULL,
@IdProveedor Int = NULL
AS
BEGIN
DECLARE @CountIdCentroCosto INT,
		@CountAcronimoSap INT,
		@CountDesactivaos INT,
		@Mensaje varchar(200);
	SET @CountIdCentroCosto = (SELECT COUNT(1) FROM WDEA_SAP_CentroCostos WHERE IdCentroCostosADINCO = @IdCentroCosto AND Activo = 1)
	SET @CountIdCentroCosto = (SELECT COUNT(1) FROM WDEA_SAP_CentroCostos WHERE AcronimoSAP = @AcronimoSAP AND Activo = 1)

	IF @CountIdCentroCosto = 0 OR @CountAcronimoSap = 0
	BEGIN
	set @CountDesactivaos = (SELECT COUNT(1) FROM WDEA_SAP_CentroCostos WHERE AcronimoSAP = @AcronimoSAP AND IdCentroCostosADINCO = @IdCentroCosto AND Activo = 0)
	If @CountDesactivaos > 0
		BEGIN
			UPDATE WDEA_SAP_CentroCostos
			SET Activo = 1,
			ModificadoEl = GETDATE(),
			ModificadoPor = @IdUsuario,
			IdContrato = @IdProveedor
			WHERE AcronimoSAP = @AcronimoSAP
			AND
			IdCentroCostosADINCO = @IdCentroCosto 
			SET @Mensaje = ('Se agregó correctamente la información')
		END
		ELSE
		BEGIN
			INSERT INTO 
			WDEA_SAP_CentroCostos(
			IdCentroCostosADINCO,AcronimoSAP,WBS_Element,IdContrato,IdProveedor,Activo,CreadoPor,CreadoEl)
			VALUES
			(@IdCentroCosto,@AcronimoSAP,@WBS_Element,@IdContrato,@IdProveedor,1,@IdUsuario,GETDATE())
			SET @Mensaje = ('Se agregó correctamente la información')
		END
	END
	ELSE 
	BEGIN
		SET @Mensaje = ('El centro de costos o el acrónimo ya está en uso')
	END
	SELECT @Mensaje AS MENSAJE
END