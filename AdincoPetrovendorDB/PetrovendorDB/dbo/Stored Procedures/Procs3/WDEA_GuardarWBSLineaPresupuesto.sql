CREATE PROCEDURE [dbo].[WDEA_GuardarWBSLineaPresupuesto]
@IdWBS int,
@IdLineaPresupuesto int,
@IdContrato int,
@IdUsuario int
AS
BEGIN
	DECLARE @MENSAJE VARCHAR (300);
	DECLARE @RESPONSE VARCHAR (300);

	IF (0 = isnull(@IdLineaPresupuesto,0) OR  0=isnull(@IdWBS,0))
	BEGIN 
		SET @MENSAJE = 'El WBS y la Línea Presupuesto son requeridos para continuar'
		SET @RESPONSE = 'ERROR'
		SELECT @MENSAJE as MENSAJE,@RESPONSE as RESPONSE
		RETURN
	END 

	IF EXISTS (SELECT * FROM WDEA_WBSLineaPresupuesto 
	WHERE IdLineaPresupuesto = @IdLineaPresupuesto and IdContrato = @IdContrato AND IdWBS=@IdWBS and Activo = 1)
	BEGIN
		SET @MENSAJE = 'Esta relación de WBS y la Línea Presupuesto ya se encuentra en el sistema'
		SET @RESPONSE = 'SUCCESS'
		SELECT @MENSAJE as MENSAJE,@RESPONSE as RESPONSE
		RETURN
	END

	IF EXISTS (SELECT * FROM WDEA_WBSLineaPresupuesto 
	WHERE IdLineaPresupuesto = @IdLineaPresupuesto AND IdWBS<>@IdWBS and IdContrato = @IdContrato and Activo = 1)
	BEGIN
		SET @MENSAJE = 'La Línea Presupuesto ya está relacionada a un WBS'
		SET @RESPONSE = 'ERROR'
		SELECT @MENSAJE as MENSAJE,@RESPONSE as RESPONSE
		RETURN
	END

	IF EXISTS (SELECT * FROM WDEA_WBSLineaPresupuesto 
	WHERE IdLineaPresupuesto <> @IdLineaPresupuesto AND IdWBS=@IdWBS and IdContrato = @IdContrato and Activo = 1)
	BEGIN
		SET @MENSAJE = 'El WBS ya está relacionada a otra Línea Presupuesto '
		SET @RESPONSE = 'ERROR'
		SELECT @MENSAJE as MENSAJE,@RESPONSE as RESPONSE
		RETURN
	END

	IF EXISTS (SELECT * FROM WDEA_WBSLineaPresupuesto 
	WHERE IdLineaPresupuesto = @IdLineaPresupuesto and IdContrato = @IdContrato AND IdWBS=@IdWBS and Activo = 0)
	BEGIN

			UPDATE WDEA_WBSLineaPresupuesto
			SET ACTIVO = 1,
			ModificadoEl=GETDATE(),
			ModificadoPor=@IdUsuario
			WHERE 
			IdContrato = @IdContrato
			AND IdWBS=@IdWBS
			AND IdLineaPresupuesto = @IdLineaPresupuesto

		SET @MENSAJE = 'La información se guardó exitosamente'
		SET @RESPONSE = 'SUCCESS'

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

	SELECT @MENSAJE as MENSAJE,@RESPONSE as RESPONSE
END