USE Petrovendor
GO
DROP PROCEDURE IF EXISTS WDEA_GuardarWBSLineaPresupuesto
GO
CREATE PROCEDURE WDEA_GuardarWBSLineaPresupuesto
@IdWBS int,
@IdLineaPresupuesto int,
@IdContrato int,
@IdUsuario int
AS
BEGIN
	DECLARE @MENSAJE VARCHAR (300);
	DECLARE @RESPONSE VARCHAR (300);
	IF EXISTS (SELECT * FROM WDEA_WBSLineaPresupuesto 
	WHERE IdLineaPresupuesto = @IdLineaPresupuesto and IdContrato = @IdContrato and Activo = 0)
	BEGIN
			UPDATE WDEA_WBSLineaPresupuesto
			SET ACTIVO = 1
			WHERE 
			IdContrato = @IdContrato
			AND IdLineaPresupuesto = @IdLineaPresupuesto
		SET @MENSAJE = 'La información se guardó exitosamente'
		SET @RESPONSE = 'SUCCESS'
	END
	ELSE
	BEGIN
		IF EXISTS (SELECT * FROM WDEA_WBSLineaPresupuesto 
		WHERE IdLineaPresupuesto = @IdLineaPresupuesto and IdContrato = @IdContrato and Activo = 1)
		BEGIN
			SET @MENSAJE = 'La Línea Presupuesto ya está relacionada a un WBS'
			SET @RESPONSE = 'ERROR'
		END
		ELSE
		BEGIN
			INSERT INTO WDEA_WBSLineaPresupuesto
			(IdWBS,	IdLineaPresupuesto,	IdContrato,Activo,CreadoEl,CreadoPor)
			VALUES 
			(@IdWBS,@IdLineaPresupuesto,@IdContrato,1,GETDATE(),@IdUsuario)									
			SET @MENSAJE =  'La información se guardó exitosamente'
			SET @RESPONSE = 'SUCCESS'
		END
	END
	SELECT @MENSAJE as MENSAJE,@RESPONSE as RESPONSE
END
